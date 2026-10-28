-- =============================================================================
-- Paymob card payments (TEST / sandbox ready)
--
-- Design notes
-- ------------
-- * `payment_attempts` is the server-side record of every card payment try.
--   The Flutter apps may only SELECT their own safe columns; all writes go
--   through the SECURITY DEFINER functions below, which are executable only by
--   the `service_role` used by the Edge Functions.
-- * `paymob_webhook_events` deduplicates Paymob transaction callbacks by the
--   Paymob transaction id. It is server-only (RLS on, no policies).
-- * `orders.payment_status` / `orders.paid_at` are trusted, server-written
--   fields. A trigger stops a customer from changing trusted order fields when
--   they cancel an order (the existing cancel policy only allowed CANCELED, but
--   RLS cannot restrict which columns change).
-- * Amounts are always read from `orders.total` inside the database, converted
--   EGP -> piastres (`* 100`). The client never supplies an amount.
-- * Multiple attempts per order are supported. A partial unique index allows
--   only one *active* attempt per order, so concurrent double taps reuse the
--   same attempt instead of creating two live Paymob intentions.
--
-- Idempotent - safe to run with `supabase db push` or re-run in the SQL editor.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1) Trusted payment state on orders
-- -----------------------------------------------------------------------------
ALTER TABLE public.orders
  ADD COLUMN IF NOT EXISTS payment_status text NOT NULL DEFAULT 'unpaid',
  ADD COLUMN IF NOT EXISTS paid_at timestamptz;

ALTER TABLE public.orders
  DROP CONSTRAINT IF EXISTS orders_payment_status_check;

ALTER TABLE public.orders
  ADD CONSTRAINT orders_payment_status_check
  CHECK (
    payment_status IN (
      'unpaid',
      'pending',
      'paid',
      'failed',
      'refund_pending',
      'refunded'
    )
  );

CREATE INDEX IF NOT EXISTS orders_payment_status_idx
  ON public.orders (payment_status);

-- Customers may only create unpaid orders. The default already satisfies this,
-- but an explicit policy check prevents a crafted insert from claiming "paid".
DROP POLICY IF EXISTS "customers insert own orders" ON public.orders;
CREATE POLICY "customers insert own orders"
  ON public.orders FOR INSERT
  TO authenticated
  WITH CHECK (
    user_id = auth.uid()
    AND status = 'PENDING'
    AND payment_status = 'unpaid'
    AND paid_at IS NULL
  );

-- A customer cancel is the only order UPDATE the app allows. Compare every
-- column except status/updated_at, then validate payment_status separately so
-- future columns are protected but a paid cancellation can become a refund.
CREATE OR REPLACE FUNCTION public.enforce_customer_order_update()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  -- Service role / SQL editor: auth.uid() is null and RLS is bypassed.
  IF auth.uid() IS NULL THEN
    RETURN NEW;
  END IF;

  -- Admins keep full update access.
  IF public.is_admin() THEN
    RETURN NEW;
  END IF;

  -- A customer may still cancel an order after a late card success. Reflect
  -- that in payment state so support sees the refund obligation; this is the
  -- only trusted field the trigger writes on the customer's behalf.
  IF OLD.payment_status = 'paid'
     AND NEW.status = 'CANCELED'::public.order_status THEN
    NEW.payment_status := 'refund_pending';
  END IF;

  IF (to_jsonb(NEW) - 'status' - 'updated_at' - 'payment_status')
     IS DISTINCT FROM
     (to_jsonb(OLD) - 'status' - 'updated_at' - 'payment_status') THEN
    RAISE EXCEPTION 'customers may only cancel their own orders'
      USING ERRCODE = '42501';
  END IF;

  IF NEW.status IS DISTINCT FROM 'CANCELED'::public.order_status THEN
    RAISE EXCEPTION 'customers may only cancel their own orders'
      USING ERRCODE = '42501';
  END IF;

  IF NEW.payment_status IS DISTINCT FROM OLD.payment_status
     AND NOT (
       OLD.payment_status = 'paid'
       AND NEW.status = 'CANCELED'::public.order_status
       AND NEW.payment_status = 'refund_pending'
     ) THEN
    RAISE EXCEPTION 'customers cannot change payment state'
      USING ERRCODE = '42501';
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS enforce_customer_order_update ON public.orders;
CREATE TRIGGER enforce_customer_order_update
  BEFORE UPDATE ON public.orders
  FOR EACH ROW
  EXECUTE FUNCTION public.enforce_customer_order_update();

-- -----------------------------------------------------------------------------
-- 2) Payment attempts
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.payment_attempts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id uuid NOT NULL
    REFERENCES public.orders (id) ON DELETE CASCADE,
  user_id uuid NOT NULL
    REFERENCES auth.users (id) ON DELETE CASCADE,
  provider text NOT NULL DEFAULT 'paymob'
    CHECK (provider = 'paymob'),
  method text NOT NULL DEFAULT 'card'
    CHECK (method = 'card'),
  status text NOT NULL DEFAULT 'created'
    CHECK (
      status IN (
        'created',
        'pending',
        'succeeded',
        'failed',
        'expired',
        'cancelled',
        'disputed'
      )
    ),
  amount_cents bigint NOT NULL
    CHECK (amount_cents > 0),
  currency text NOT NULL DEFAULT 'EGP'
    CHECK (currency = 'EGP'),
  paymob_intention_id text UNIQUE,
  paymob_order_id text,
  -- Contains the Unified Checkout client secret. Server-only via column grants.
  checkout_url text,
  failure_reason text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  completed_at timestamptz
);

-- At most one live Paymob intention per order. Failed/expired attempts are
-- kept for audit and a new attempt can then be created.
CREATE UNIQUE INDEX IF NOT EXISTS payment_attempts_one_active_per_order
  ON public.payment_attempts (order_id)
  WHERE status IN ('created', 'pending');

CREATE INDEX IF NOT EXISTS payment_attempts_order_created_idx
  ON public.payment_attempts (order_id, created_at DESC);

CREATE INDEX IF NOT EXISTS payment_attempts_user_idx
  ON public.payment_attempts (user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS payment_attempts_status_idx
  ON public.payment_attempts (status);

CREATE UNIQUE INDEX IF NOT EXISTS payment_attempts_paymob_order_idx
  ON public.payment_attempts (paymob_order_id)
  WHERE paymob_order_id IS NOT NULL;

-- A customer may still delete an abandoned order, but never one that has a
-- live or successful payment attached: deleting it would cascade-delete the
-- attempt and lose the record needed to reconcile a late Paymob callback.
CREATE OR REPLACE FUNCTION public.enforce_customer_order_delete()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  -- Service role / SQL editor / admin can clean up.
  IF auth.uid() IS NULL OR public.is_admin() THEN
    RETURN OLD;
  END IF;

  IF OLD.payment_status IN ('paid', 'pending', 'refund_pending')
     OR EXISTS (
       SELECT 1
       FROM public.payment_attempts
       WHERE order_id = OLD.id
         AND status IN ('created', 'pending', 'succeeded')
     ) THEN
    RAISE EXCEPTION 'orders with a payment in progress cannot be deleted'
      USING ERRCODE = '42501';
  END IF;

  RETURN OLD;
END;
$$;

DROP TRIGGER IF EXISTS enforce_customer_order_delete ON public.orders;
CREATE TRIGGER enforce_customer_order_delete
  BEFORE DELETE ON public.orders
  FOR EACH ROW
  EXECUTE FUNCTION public.enforce_customer_order_delete();

-- -----------------------------------------------------------------------------
-- 3) Webhook event deduplication / audit (server only)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.paymob_webhook_events (
  id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  paymob_transaction_id text NOT NULL UNIQUE,
  paymob_order_id text,
  attempt_id uuid
    REFERENCES public.payment_attempts (id) ON DELETE SET NULL,
  order_id uuid
    REFERENCES public.orders (id) ON DELETE SET NULL,
  event_type text,
  success boolean,
  pending boolean,
  amount_cents bigint,
  currency text,
  result text,
  payload jsonb,
  received_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS paymob_webhook_events_order_idx
  ON public.paymob_webhook_events (order_id, received_at DESC);

-- -----------------------------------------------------------------------------
-- 4) RLS / grants
-- -----------------------------------------------------------------------------
ALTER TABLE public.payment_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.paymob_webhook_events ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "customers read own payment attempts"
  ON public.payment_attempts;
CREATE POLICY "customers read own payment attempts"
  ON public.payment_attempts FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- No INSERT / UPDATE / DELETE policies: customers cannot write payment state.
-- Column grants hide checkout_url (which embeds the client secret) even from
-- the owner. The status screen only needs the safe columns below.
REVOKE ALL ON TABLE public.payment_attempts FROM anon, authenticated;
GRANT SELECT (
  id,
  order_id,
  user_id,
  provider,
  method,
  status,
  amount_cents,
  currency,
  failure_reason,
  created_at,
  updated_at,
  completed_at
) ON public.payment_attempts TO authenticated;

-- Webhook events have RLS enabled and no policies: only service_role can read.
REVOKE ALL ON TABLE public.paymob_webhook_events FROM anon, authenticated;
GRANT ALL ON TABLE public.payment_attempts TO service_role;
GRANT ALL ON TABLE public.paymob_webhook_events TO service_role;
GRANT USAGE, SELECT ON SEQUENCE public.paymob_webhook_events_id_seq
  TO service_role;

-- -----------------------------------------------------------------------------
-- 5) Start / attach / fail a payment attempt (service_role only)
-- -----------------------------------------------------------------------------

-- Verifies ownership and eligibility, locks the order, and reuses an active
-- attempt (including its checkout URL) so double taps cannot open two Paymob
-- payments for the same order. Stale attempts are expired after 45 minutes.
DROP FUNCTION IF EXISTS public.begin_paymob_attempt(uuid, uuid);
CREATE OR REPLACE FUNCTION public.begin_paymob_attempt(
  p_order_id uuid,
  p_user_id uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_order public.orders%ROWTYPE;
  v_attempt public.payment_attempts%ROWTYPE;
  v_amount_cents bigint;
  v_items_total numeric;
BEGIN
  IF p_order_id IS NULL OR p_user_id IS NULL THEN
    RAISE EXCEPTION 'missing order or user'
      USING ERRCODE = '22023';
  END IF;

  -- Serialize initiation for this order (double taps / concurrent retries).
  SELECT * INTO v_order
  FROM public.orders
  WHERE id = p_order_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'order not found'
      USING ERRCODE = 'P0002';
  END IF;

  IF v_order.user_id <> p_user_id THEN
    RAISE EXCEPTION 'order does not belong to this user'
      USING ERRCODE = '42501';
  END IF;

  IF v_order.status <> 'PENDING'::public.order_status THEN
    RAISE EXCEPTION 'order is not payable'
      USING ERRCODE = '22023';
  END IF;

  IF v_order.payment_method IS DISTINCT FROM 'card' THEN
    RAISE EXCEPTION 'order is not a card order'
      USING ERRCODE = '22023';
  END IF;

  IF v_order.payment_status IN ('paid', 'refund_pending', 'refunded')
     OR EXISTS (
       SELECT 1 FROM public.payment_attempts
       WHERE order_id = p_order_id AND status = 'succeeded'
     ) THEN
    RAISE EXCEPTION 'order is already paid'
      USING ERRCODE = '22023';
  END IF;

  -- The amount comes from the persisted order, never from the client.
  -- This also catches a half-written order whose total does not match items.
  SELECT coalesce(
           sum(round(price_snapshot * quantity)::bigint),
           0
         )
  INTO v_items_total
  FROM public.order_items
  WHERE order_id = p_order_id;

  IF v_items_total + v_order.delivery_fee + v_order.service_fee
     <> v_order.total THEN
    RAISE EXCEPTION 'order total is inconsistent'
      USING ERRCODE = '22023';
  END IF;

  v_amount_cents := round(v_order.total * 100)::bigint;
  IF v_amount_cents <= 0 THEN
    RAISE EXCEPTION 'order total is invalid'
      USING ERRCODE = '22023';
  END IF;

  -- Paymob checkout sessions are short-lived. Let a very old attempt expire so
  -- the customer can retry without waiting forever.
  UPDATE public.payment_attempts
  SET status = 'expired',
      failure_reason = 'Checkout timed out',
      updated_at = now(),
      completed_at = now()
  WHERE order_id = p_order_id
    AND status IN ('created', 'pending')
    AND updated_at < now() - interval '45 minutes';

  SELECT * INTO v_attempt
  FROM public.payment_attempts
  WHERE order_id = p_order_id
    AND status IN ('created', 'pending')
  ORDER BY created_at DESC
  LIMIT 1
  FOR UPDATE;

  IF FOUND THEN
    IF v_attempt.checkout_url IS NOT NULL THEN
      RETURN jsonb_build_object(
        'attempt_id', v_attempt.id,
        'order_id', v_attempt.order_id,
        'amount_cents', v_attempt.amount_cents,
        'currency', v_attempt.currency,
        'status', v_attempt.status,
        'checkout_url', v_attempt.checkout_url,
        'reused', true
      );
    END IF;

    -- Another request is mid-flight creating the Paymob intention.
    IF v_attempt.updated_at > now() - interval '2 minutes' THEN
      RAISE EXCEPTION 'payment is already starting'
        USING ERRCODE = 'P0001';
    END IF;

    UPDATE public.payment_attempts
    SET status = 'expired',
        failure_reason = 'Payment initiation timed out',
        updated_at = now(),
        completed_at = now()
    WHERE id = v_attempt.id;
  END IF;

  INSERT INTO public.payment_attempts (
    order_id,
    user_id,
    status,
    amount_cents,
    currency
  )
  VALUES (
    p_order_id,
    p_user_id,
    'created',
    v_amount_cents,
    'EGP'
  )
  RETURNING * INTO v_attempt;

  RETURN jsonb_build_object(
    'attempt_id', v_attempt.id,
    'order_id', v_attempt.order_id,
    'amount_cents', v_attempt.amount_cents,
    'currency', v_attempt.currency,
    'status', v_attempt.status,
    'checkout_url', null,
    'reused', false
  );
END;
$$;

REVOKE ALL ON FUNCTION public.begin_paymob_attempt(uuid, uuid) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.begin_paymob_attempt(uuid, uuid)
  FROM anon, authenticated;
GRANT EXECUTE ON FUNCTION public.begin_paymob_attempt(uuid, uuid)
  TO service_role;

-- Stores the Paymob intention identifiers and returns the checkout URL. The
-- URL contains the client secret and is only exposed by the Edge Function,
-- never by a direct table read.
DROP FUNCTION IF EXISTS public.attach_paymob_intention(
  uuid, uuid, text, text, text
);
CREATE OR REPLACE FUNCTION public.attach_paymob_intention(
  p_attempt_id uuid,
  p_user_id uuid,
  p_intention_id text,
  p_paymob_order_id text,
  p_checkout_url text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_attempt public.payment_attempts%ROWTYPE;
  v_order public.orders%ROWTYPE;
BEGIN
  IF p_intention_id IS NULL OR p_intention_id = ''
     OR p_checkout_url IS NULL OR p_checkout_url = '' THEN
    RAISE EXCEPTION 'missing Paymob intention data'
      USING ERRCODE = '22023';
  END IF;

  -- Lock the order before exposing the live checkout URL. If a webhook or a
  -- customer cancellation won the race while Paymob was being called, the URL
  -- must not be handed to the app.
  SELECT o.* INTO v_order
  FROM public.orders o
  JOIN public.payment_attempts a ON a.order_id = o.id
  WHERE a.id = p_attempt_id
    AND a.user_id = p_user_id
  FOR UPDATE OF o;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'payment attempt is not open'
      USING ERRCODE = 'P0001';
  END IF;

  IF v_order.payment_status IN ('paid', 'refund_pending', 'refunded')
     OR v_order.status <> 'PENDING'::public.order_status
     OR v_order.payment_method IS DISTINCT FROM 'card' THEN
    UPDATE public.payment_attempts
    SET status = 'failed',
        failure_reason = 'Order is no longer payable',
        updated_at = now(),
        completed_at = now()
    WHERE id = p_attempt_id
      AND status = 'created';

    RAISE EXCEPTION 'order is no longer payable'
      USING ERRCODE = '22023';
  END IF;

  UPDATE public.payment_attempts
  SET status = 'pending',
      paymob_intention_id = p_intention_id,
      paymob_order_id = p_paymob_order_id,
      checkout_url = p_checkout_url,
      failure_reason = NULL,
      updated_at = now()
  WHERE id = p_attempt_id
    AND user_id = p_user_id
    AND status = 'created'
  RETURNING * INTO v_attempt;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'payment attempt is not open'
      USING ERRCODE = 'P0001';
  END IF;

  UPDATE public.orders
  SET payment_status = 'pending',
      updated_at = now()
  WHERE id = v_attempt.order_id
    AND payment_status <> 'paid'
    AND status = 'PENDING'::public.order_status;

  RETURN jsonb_build_object(
    'attempt_id', v_attempt.id,
    'order_id', v_attempt.order_id,
    'amount_cents', v_attempt.amount_cents,
    'currency', v_attempt.currency,
    'status', v_attempt.status,
    'checkout_url', v_attempt.checkout_url
  );
END;
$$;

REVOKE ALL ON FUNCTION public.attach_paymob_intention(
  uuid, uuid, text, text, text
) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.attach_paymob_intention(
  uuid, uuid, text, text, text
) FROM anon, authenticated;
GRANT EXECUTE ON FUNCTION public.attach_paymob_intention(
  uuid, uuid, text, text, text
) TO service_role;

-- Called when Paymob rejected the intention request or the Edge Function could
-- not persist the response. Never downgrades a succeeded attempt.
DROP FUNCTION IF EXISTS public.fail_paymob_attempt(uuid, uuid, text);
CREATE OR REPLACE FUNCTION public.fail_paymob_attempt(
  p_attempt_id uuid,
  p_user_id uuid,
  p_reason text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_attempt public.payment_attempts%ROWTYPE;
BEGIN
  UPDATE public.payment_attempts
  SET status = 'failed',
      failure_reason = left(
        coalesce(nullif(btrim(p_reason), ''), 'Payment could not be started'),
        500
      ),
      updated_at = now(),
      completed_at = now()
  WHERE id = p_attempt_id
    AND user_id = p_user_id
    AND status IN ('created', 'pending')
  RETURNING * INTO v_attempt;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('updated', false);
  END IF;

  UPDATE public.orders
  SET payment_status = 'failed',
      updated_at = now()
  WHERE id = v_attempt.order_id
    AND payment_status <> 'paid'
    AND NOT EXISTS (
      SELECT 1 FROM public.payment_attempts
      WHERE order_id = v_attempt.order_id
        AND id <> v_attempt.id
        AND status IN ('created', 'pending', 'succeeded')
    );

  RETURN jsonb_build_object(
    'updated', true,
    'attempt_id', v_attempt.id,
    'order_id', v_attempt.order_id,
    'status', v_attempt.status
  );
END;
$$;

REVOKE ALL ON FUNCTION public.fail_paymob_attempt(uuid, uuid, text)
  FROM PUBLIC;
REVOKE ALL ON FUNCTION public.fail_paymob_attempt(uuid, uuid, text)
  FROM anon, authenticated;
GRANT EXECUTE ON FUNCTION public.fail_paymob_attempt(uuid, uuid, text)
  TO service_role;

-- -----------------------------------------------------------------------------
-- 6) Webhook processing (service_role only)
-- -----------------------------------------------------------------------------

-- Called only after the Edge Function has verified the SHA-512 HMAC. The first
-- insert of the Paymob transaction id wins; duplicates are acknowledged without
-- touching order state. Row locks serialize concurrent callbacks for one order
-- and a late success after another success is recorded as `disputed` instead of
-- charging the order twice.
DROP FUNCTION IF EXISTS public.process_paymob_callback(
  text, text, text, text, boolean, boolean, bigint, text, jsonb
);
CREATE OR REPLACE FUNCTION public.process_paymob_callback(
  p_transaction_id text,
  p_paymob_order_id text,
  p_merchant_order_id text,
  p_event_type text,
  p_success boolean,
  p_pending boolean,
  p_amount_cents bigint,
  p_currency text,
  p_payload jsonb
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_attempt public.payment_attempts%ROWTYPE;
  v_order public.orders%ROWTYPE;
  v_event_id bigint;
  v_result text;
  v_order_id uuid;
  v_attempt_id uuid;
BEGIN
  IF p_transaction_id IS NULL OR btrim(p_transaction_id) = '' THEN
    RAISE EXCEPTION 'missing Paymob transaction id'
      USING ERRCODE = '22023';
  END IF;

  -- Resolve by the Paymob order id we stored at intention creation. The
  -- merchant reference is only a race fallback for a callback that arrives
  -- before `attach_paymob_intention`; it is never used as a trusted amount.
  SELECT * INTO v_attempt
  FROM public.payment_attempts
  WHERE paymob_order_id = p_paymob_order_id
  ORDER BY created_at DESC
  LIMIT 1;

  IF NOT FOUND
     AND p_merchant_order_id IS NOT NULL
     AND p_merchant_order_id ~
       '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$' THEN
    SELECT * INTO v_attempt
    FROM public.payment_attempts
    WHERE id = p_merchant_order_id::uuid
      AND paymob_order_id IS NULL
      AND status = 'created';
  END IF;

  v_attempt_id := v_attempt.id;
  v_order_id := v_attempt.order_id;

  INSERT INTO public.paymob_webhook_events (
    paymob_transaction_id,
    paymob_order_id,
    attempt_id,
    order_id,
    event_type,
    success,
    pending,
    amount_cents,
    currency,
    payload
  )
  VALUES (
    p_transaction_id,
    p_paymob_order_id,
    v_attempt_id,
    v_order_id,
    p_event_type,
    p_success,
    p_pending,
    p_amount_cents,
    p_currency,
    coalesce(p_payload, '{}'::jsonb)
  )
  ON CONFLICT (paymob_transaction_id) DO NOTHING
  RETURNING id INTO v_event_id;

  IF v_event_id IS NULL THEN
    RETURN jsonb_build_object(
      'duplicate', true,
      'result', 'duplicate',
      'attempt_id', v_attempt_id,
      'order_id', v_order_id
    );
  END IF;

  IF v_attempt_id IS NULL THEN
    UPDATE public.paymob_webhook_events
    SET result = 'unknown_attempt'
    WHERE id = v_event_id;

    RETURN jsonb_build_object(
      'duplicate', false,
      'result', 'unknown_attempt',
      'attempt_id', null,
      'order_id', null
    );
  END IF;

  SELECT * INTO v_attempt
  FROM public.payment_attempts
  WHERE id = v_attempt_id
  FOR UPDATE;

  -- Pending transaction: keep the attempt open, a later callback will settle it.
  IF p_pending IS TRUE THEN
    UPDATE public.paymob_webhook_events
    SET result = 'pending'
    WHERE id = v_event_id;

    RETURN jsonb_build_object(
      'duplicate', false,
      'result', 'pending',
      'attempt_id', v_attempt_id,
      'order_id', v_order_id
    );
  END IF;

  -- The verified callback must match the server-side amount and currency.
  IF p_amount_cents IS DISTINCT FROM v_attempt.amount_cents
     OR upper(coalesce(p_currency, '')) <> v_attempt.currency THEN
    UPDATE public.payment_attempts
    SET status = 'disputed',
        failure_reason = 'Amount or currency mismatch in Paymob callback',
        updated_at = now(),
        completed_at = now()
    WHERE id = v_attempt_id
      AND status <> 'succeeded';

    UPDATE public.orders
    SET payment_status = 'failed',
        updated_at = now()
    WHERE id = v_order_id
      AND payment_status <> 'paid'
      AND NOT EXISTS (
        SELECT 1 FROM public.payment_attempts
        WHERE order_id = v_order_id
          AND id <> v_attempt_id
          AND status IN ('created', 'pending', 'succeeded')
      );

    UPDATE public.paymob_webhook_events
    SET result = 'amount_mismatch'
    WHERE id = v_event_id;

    RETURN jsonb_build_object(
      'duplicate', false,
      'result', 'amount_mismatch',
      'attempt_id', v_attempt_id,
      'order_id', v_order_id
    );
  END IF;

  IF p_success IS NOT TRUE THEN
    IF v_attempt.status = 'succeeded' THEN
      UPDATE public.paymob_webhook_events
      SET result = 'already_succeeded'
      WHERE id = v_event_id;

      RETURN jsonb_build_object(
        'duplicate', false,
        'result', 'already_succeeded',
        'attempt_id', v_attempt_id,
        'order_id', v_order_id
      );
    END IF;

    UPDATE public.payment_attempts
    SET status = 'failed',
        failure_reason = 'Paymob reported a failed transaction',
        updated_at = now(),
        completed_at = now()
    WHERE id = v_attempt_id
      AND status <> 'succeeded';

    UPDATE public.orders
    SET payment_status = 'failed',
        updated_at = now()
    WHERE id = v_order_id
      AND payment_status <> 'paid'
      AND NOT EXISTS (
        SELECT 1 FROM public.payment_attempts
        WHERE order_id = v_order_id
          AND id <> v_attempt_id
          AND status IN ('created', 'pending', 'succeeded')
      );

    UPDATE public.paymob_webhook_events
    SET result = 'failed'
    WHERE id = v_event_id;

    RETURN jsonb_build_object(
      'duplicate', false,
      'result', 'failed',
      'attempt_id', v_attempt_id,
      'order_id', v_order_id
    );
  END IF;

  -- Success: lock the order before deciding, so two concurrent callbacks for
  -- different attempts cannot both mark it paid.
  SELECT * INTO v_order
  FROM public.orders
  WHERE id = v_order_id
  FOR UPDATE;

  IF v_order.payment_status = 'paid'
     OR EXISTS (
       SELECT 1 FROM public.payment_attempts
       WHERE order_id = v_order_id
         AND id <> v_attempt_id
         AND status = 'succeeded'
     ) THEN
    UPDATE public.payment_attempts
    SET status = 'disputed',
        failure_reason = 'Duplicate payment for an already-paid order',
        paymob_order_id = coalesce(paymob_order_id, p_paymob_order_id),
        updated_at = now(),
        completed_at = now()
    WHERE id = v_attempt_id
      AND status <> 'succeeded';

    UPDATE public.paymob_webhook_events
    SET result = 'duplicate_payment'
    WHERE id = v_event_id;

    RETURN jsonb_build_object(
      'duplicate', false,
      'result', 'duplicate_payment',
      'attempt_id', v_attempt_id,
      'order_id', v_order_id
    );
  END IF;

  UPDATE public.payment_attempts
  SET status = 'succeeded',
      failure_reason = NULL,
      paymob_order_id = coalesce(paymob_order_id, p_paymob_order_id),
      updated_at = now(),
      completed_at = now()
  WHERE id = v_attempt_id;

  -- Close any other live attempts; late callbacks for them are caught as
  -- duplicate_payment above.
  UPDATE public.payment_attempts
  SET status = 'expired',
      failure_reason = 'Another payment attempt succeeded',
      updated_at = now(),
      completed_at = now()
  WHERE order_id = v_order_id
    AND id <> v_attempt_id
    AND status IN ('created', 'pending');

  IF v_order.status = 'CANCELED'::public.order_status THEN
    UPDATE public.orders
    SET payment_status = 'refund_pending',
        updated_at = now()
    WHERE id = v_order_id;

    v_result := 'paid_on_canceled_order';
  ELSE
    UPDATE public.orders
    SET payment_status = 'paid',
        paid_at = now(),
        payment_method = 'card',
        updated_at = now()
    WHERE id = v_order_id;

    v_result := 'paid';
  END IF;

  UPDATE public.paymob_webhook_events
  SET result = v_result
  WHERE id = v_event_id;

  RETURN jsonb_build_object(
    'duplicate', false,
    'result', v_result,
    'attempt_id', v_attempt_id,
    'order_id', v_order_id
  );
END;
$$;

REVOKE ALL ON FUNCTION public.process_paymob_callback(
  text, text, text, text, boolean, boolean, bigint, text, jsonb
) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.process_paymob_callback(
  text, text, text, text, boolean, boolean, bigint, text, jsonb
) FROM anon, authenticated;
GRANT EXECUTE ON FUNCTION public.process_paymob_callback(
  text, text, text, text, boolean, boolean, bigint, text, jsonb
) TO service_role;

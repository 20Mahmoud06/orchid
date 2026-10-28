-- =============================================================================
-- Paymob hardening: trusted order pricing, uncertain-attempt quarantine,
-- cancellation cleanup and replay-safe webhook settlement.
--
-- Run AFTER 20261028000000_paymob_payments.sql. This migration does not edit
-- that file, so an environment that already applied it keeps its history.
--
-- Why this migration exists
-- -------------------------
-- * The first Paymob migration trusted `orders.total`, but the Flutter apps
--   wrote `price_snapshot`, fees and `total` themselves. A modified client
--   could therefore declare low prices and pass `begin_paymob_attempt`.
-- * A Paymob request that timed out was treated as a definite failure, then a
--   second intention could be created after two minutes. Paymob does NOT
--   document provider-side idempotency for Intention creation, so an unknown
--   request must be quarantined, not retried blindly.
-- * Webhook deduplication by transaction id dropped a later terminal callback
--   that reused an id first seen as pending / unknown_attempt.
--
-- New state vocabulary
-- --------------------
--   created   - local row claimed, Paymob has not answered yet.
--   pending   - Paymob returned an intention and a checkout URL.
--   unknown   - Paymob may have accepted the request, but we have no verified
--               outcome. New attempts are blocked until a verified callback
--               or an explicit operator reconciliation.
--   succeeded / failed / expired / cancelled / disputed
--
-- Lock order (all functions below follow it):
--   orders row -> payment_attempts row -> paymob_webhook_events row.
-- The webhook locks its event row first only to deduplicate the delivery; it
-- then takes the same order -> attempt locks as every other function.
--
-- Idempotent - safe to run with `supabase db push` or re-run in the SQL editor.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- 1) Attempt state + columns
-- -----------------------------------------------------------------------------
ALTER TABLE public.payment_attempts
  ADD COLUMN IF NOT EXISTS unknown_since timestamptz,
  ADD COLUMN IF NOT EXISTS expires_at timestamptz;

ALTER TABLE public.payment_attempts
  DROP CONSTRAINT IF EXISTS payment_attempts_status_check;

ALTER TABLE public.payment_attempts
  ADD CONSTRAINT payment_attempts_status_check
  CHECK (
    status IN (
      'created',
      'pending',
      'unknown',
      'succeeded',
      'failed',
      'expired',
      'cancelled',
      'disputed'
    )
  );

-- An uncertain attempt is still "live": it must block a second chargeable
-- intention for the same order until it is reconciled.
DROP INDEX IF EXISTS public.payment_attempts_one_active_per_order;
CREATE UNIQUE INDEX payment_attempts_one_active_per_order
  ON public.payment_attempts (order_id)
  WHERE status IN ('created', 'pending', 'unknown');

CREATE INDEX IF NOT EXISTS payment_attempts_unknown_idx
  ON public.payment_attempts (unknown_since)
  WHERE status = 'unknown';


-- -----------------------------------------------------------------------------
-- 2) Webhook delivery audit columns
-- -----------------------------------------------------------------------------
ALTER TABLE public.paymob_webhook_events
  ADD COLUMN IF NOT EXISTS delivery_count integer NOT NULL DEFAULT 1,
  ADD COLUMN IF NOT EXISTS last_received_at timestamptz;

UPDATE public.paymob_webhook_events
SET last_received_at = received_at
WHERE last_received_at IS NULL;


-- -----------------------------------------------------------------------------
-- 3) Trusted pricing helpers
-- -----------------------------------------------------------------------------

-- EGP amounts are displayed and charged in whole pounds by the apps.
CREATE OR REPLACE FUNCTION public.orchid_price_round(p_price numeric)
RETURNS numeric
LANGUAGE sql
IMMUTABLE
SET search_path = public, pg_temp
AS $$
  SELECT round(coalesce(p_price, 0));
$$;

CREATE OR REPLACE FUNCTION public.orchid_delivery_fee()
RETURNS numeric
LANGUAGE sql
IMMUTABLE
SET search_path = public, pg_temp
AS $$
  SELECT 30::numeric;
$$;

CREATE OR REPLACE FUNCTION public.orchid_service_fee()
RETURNS numeric
LANGUAGE sql
IMMUTABLE
SET search_path = public, pg_temp
AS $$
  SELECT 10::numeric;
$$;

CREATE OR REPLACE FUNCTION public.orchid_generate_order_code()
RETURNS text
LANGUAGE plpgsql
VOLATILE
SET search_path = public, pg_temp
AS $$
DECLARE
  v_chars constant text := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  v_code text := '';
  i integer;
BEGIN
  FOR i IN 1..8 LOOP
    v_code := v_code || substr(
      v_chars,
      1 + floor(random() * length(v_chars))::integer,
      1
    );
  END LOOP;
  RETURN v_code;
END;
$$;

-- Recomputes an *existing* order from the trusted catalog and the persisted
-- custom-bouquet components. It returns the trusted items subtotal and raises
-- when a line is missing, malformed or was written with client-authored
-- prices. Used by begin_paymob_attempt for both new and legacy orders.
CREATE OR REPLACE FUNCTION public.orchid_verify_order_pricing(p_order_id uuid)
RETURNS numeric
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_item public.order_items%ROWTYPE;
  v_product public.products%ROWTYPE;
  v_component jsonb;
  v_component_id_text text;
  v_component_id uuid;
  v_component_qty numeric;
  v_component_total numeric;
  v_custom_qty numeric;
  v_line numeric;
  v_total numeric := 0;
  v_count integer := 0;
BEGIN
  FOR v_item IN
    SELECT * FROM public.order_items WHERE order_id = p_order_id
  LOOP
    IF v_item.quantity IS NULL
       OR v_item.quantity < 1
       OR v_item.quantity > 99 THEN
      RAISE EXCEPTION 'order item quantity is invalid'
        USING ERRCODE = '22023';
    END IF;

    v_line := 0;

    IF v_item.product_id IS NOT NULL THEN
      SELECT * INTO v_product
      FROM public.products
      WHERE id = v_item.product_id;

      IF NOT FOUND THEN
        RAISE EXCEPTION 'order item is no longer available'
          USING ERRCODE = '22023';
      END IF;

      v_line := public.orchid_price_round(v_product.price)
        * v_item.quantity;
    ELSE
      IF v_item.custom_components IS NULL
         OR jsonb_typeof(v_item.custom_components -> 'flowers')
            IS DISTINCT FROM 'array'
         OR jsonb_array_length(v_item.custom_components -> 'flowers') = 0 THEN
        RAISE EXCEPTION 'custom bouquet is invalid'
          USING ERRCODE = '22023';
      END IF;

      IF v_item.quantity <> 1 THEN
        RAISE EXCEPTION 'custom bouquet quantity is invalid'
          USING ERRCODE = '22023';
      END IF;

      v_custom_qty := 0;

      FOR v_component IN
        SELECT value
        FROM jsonb_array_elements(v_item.custom_components -> 'flowers')
      LOOP
        IF jsonb_typeof(v_component) IS DISTINCT FROM 'object' THEN
          RAISE EXCEPTION 'custom bouquet component is invalid'
            USING ERRCODE = '22023';
        END IF;

        v_component_id_text := nullif(
          btrim(coalesce(v_component ->> 'product_id', '')),
          ''
        );
        v_component_qty := nullif(
          btrim(coalesce(v_component ->> 'quantity', '')),
          ''
        )::numeric;

        IF v_component_id_text IS NULL
           OR v_component_id_text !~*
             '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
           OR v_component_qty IS NULL
           OR v_component_qty <> trunc(v_component_qty)
           OR v_component_qty < 1
           OR v_component_qty > 99 THEN
          RAISE EXCEPTION 'custom bouquet component is invalid'
            USING ERRCODE = '22023';
        END IF;

        v_component_id := v_component_id_text::uuid;

        SELECT * INTO v_product
        FROM public.products
        WHERE id = v_component_id;

        IF NOT FOUND
           OR coalesce(v_product.type, 'flower') <> 'flower' THEN
          RAISE EXCEPTION 'custom bouquet flower is no longer available'
            USING ERRCODE = '22023';
        END IF;

        v_component_total := public.orchid_price_round(v_product.price)
          * v_component_qty::integer;
        v_line := v_line + v_component_total;
        v_custom_qty := v_custom_qty + v_component_qty;

        IF v_custom_qty > 15 THEN
          RAISE EXCEPTION 'custom bouquet has too many flowers'
            USING ERRCODE = '22023';
        END IF;
      END LOOP;
    END IF;

    -- The snapshot must equal the trusted current price. This rejects legacy
    -- under-priced orders instead of silently charging a different amount.
    IF abs(
      public.orchid_price_round(
        coalesce(v_item.price_snapshot, 0) * v_item.quantity
      ) - v_line
    ) > 0.01 THEN
      RAISE EXCEPTION 'order pricing is inconsistent'
        USING ERRCODE = '22023';
    END IF;

    v_total := v_total + v_line;
    v_count := v_count + 1;
  END LOOP;

  IF v_count = 0 THEN
    RAISE EXCEPTION 'order has no items'
      USING ERRCODE = '22023';
  END IF;

  RETURN v_total;
END;
$$;


-- -----------------------------------------------------------------------------
-- 4) Trusted order creation (the only INSERT path for customers)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.create_order(
  p_message text,
  p_notes text,
  p_delivery_address text,
  p_delivery_date timestamptz,
  p_order_time timestamptz,
  p_payment_method text,
  p_items jsonb
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_user_id uuid := auth.uid();
  v_items jsonb := coalesce(p_items, '[]'::jsonb);
  v_item jsonb;
  v_component jsonb;
  v_product public.products%ROWTYPE;
  v_rows jsonb := '[]'::jsonb;
  v_flowers jsonb;
  v_components jsonb;
  v_components_out jsonb;
  v_qty numeric;
  v_qty_int integer;
  v_component_qty numeric;
  v_custom_qty integer;
  v_line numeric;
  v_subtotal numeric := 0;
  v_declared numeric;
  v_product_id_text text;
  v_product_id uuid;
  v_message text;
  v_name text;
  v_image text;
  v_description text;
  v_code text;
  v_order_id uuid;
  v_try integer;
  v_total numeric;
  v_count integer := 0;
  v_payment_method text := lower(btrim(coalesce(p_payment_method, '')));
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'authentication required'
      USING ERRCODE = '42501';
  END IF;

  IF v_payment_method NOT IN ('cash', 'card') THEN
    RAISE EXCEPTION 'payment method is invalid'
      USING ERRCODE = '22023';
  END IF;

  IF p_delivery_date IS NULL THEN
    RAISE EXCEPTION 'delivery date is required'
      USING ERRCODE = '22023';
  END IF;

  IF p_delivery_date < now() - interval '1 day'
     OR p_delivery_date > now() + interval '60 days' THEN
    RAISE EXCEPTION 'delivery date is invalid'
      USING ERRCODE = '22023';
  END IF;

  IF coalesce(btrim(p_delivery_address), '') = '' THEN
    RAISE EXCEPTION 'delivery address is required'
      USING ERRCODE = '22023';
  END IF;

  IF jsonb_typeof(v_items) IS DISTINCT FROM 'array'
     OR jsonb_array_length(v_items) = 0
     OR jsonb_array_length(v_items) > 50 THEN
    RAISE EXCEPTION 'order items are invalid'
      USING ERRCODE = '22023';
  END IF;

  -- Build and validate every line before writing the order. The transaction is
  -- atomic, but this also keeps the NOT NULL / total columns meaningful for the
  -- duration of the request.
  FOR v_item IN SELECT value FROM jsonb_array_elements(v_items)
  LOOP
    IF jsonb_typeof(v_item) IS DISTINCT FROM 'object' THEN
      RAISE EXCEPTION 'order item is invalid'
        USING ERRCODE = '22023';
    END IF;

    v_qty := nullif(btrim(coalesce(v_item ->> 'quantity', '')), '')::numeric;
    IF v_qty IS NULL
       OR v_qty <> trunc(v_qty)
       OR v_qty < 1
       OR v_qty > 99 THEN
      RAISE EXCEPTION 'order item quantity is invalid'
        USING ERRCODE = '22023';
    END IF;
    v_qty_int := v_qty::integer;

    v_message := nullif(
      btrim(coalesce(v_item -> 'custom_components' ->> 'message', '')),
      ''
    );
    IF v_message IS NOT NULL THEN
      v_message := left(v_message, 500);
    END IF;

    v_product_id_text := nullif(
      btrim(coalesce(v_item ->> 'product_id', '')),
      ''
    );

    IF v_product_id_text IS NOT NULL THEN
      -- Catalog line (a flower or a ready bouquet).
      IF v_product_id_text !~*
         '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' THEN
        RAISE EXCEPTION 'order item product is invalid'
          USING ERRCODE = '22023';
      END IF;

      v_product_id := v_product_id_text::uuid;

      SELECT * INTO v_product
      FROM public.products
      WHERE id = v_product_id
        AND is_active = true;

      IF NOT FOUND THEN
        RAISE EXCEPTION 'item is no longer available'
          USING ERRCODE = '22023';
      END IF;

      v_declared := nullif(
        btrim(coalesce(v_item ->> 'price_snapshot', '')),
        ''
      )::numeric;

      IF v_declared IS NULL
         OR abs(
           public.orchid_price_round(v_declared)
           - public.orchid_price_round(v_product.price)
         ) > 0.01 THEN
        RAISE EXCEPTION 'price changed while you were shopping'
          USING ERRCODE = '22023';
      END IF;

      v_line := public.orchid_price_round(v_product.price) * v_qty_int;
      v_components := CASE
        WHEN v_message IS NULL THEN NULL
        ELSE jsonb_build_object('message', v_message)
      END;

      v_rows := v_rows || jsonb_build_array(
        jsonb_build_object(
          'item_type', coalesce(nullif(v_product.type, ''), 'flower'),
          'product_id', v_product.id,
          'name_snapshot', left(
            coalesce(nullif(v_product.name, ''), 'Item'),
            200
          ),
          'image_snapshot', left(
            coalesce(
              nullif(v_item ->> 'image_snapshot', ''),
              nullif(v_product.image_path, ''),
              ''
            ),
            2000
          ),
          'price_snapshot', public.orchid_price_round(v_product.price),
          'quantity', v_qty_int,
          'custom_components', v_components
        )
      );
    ELSE
      -- Custom bouquet line. The catalog decides every flower price; the
      -- client only supplies composition and display text.
      v_components := v_item -> 'custom_components';

      IF v_components IS NULL
         OR jsonb_typeof(v_components -> 'flowers')
            IS DISTINCT FROM 'array'
         OR jsonb_array_length(v_components -> 'flowers') = 0 THEN
        RAISE EXCEPTION 'custom bouquet is invalid'
          USING ERRCODE = '22023';
      END IF;

      IF v_qty_int <> 1 THEN
        RAISE EXCEPTION 'custom bouquet quantity is invalid'
          USING ERRCODE = '22023';
      END IF;

      v_flowers := '[]'::jsonb;
      v_custom_qty := 0;
      v_line := 0;

      FOR v_component IN
        SELECT value FROM jsonb_array_elements(v_components -> 'flowers')
      LOOP
        IF jsonb_typeof(v_component) IS DISTINCT FROM 'object' THEN
          RAISE EXCEPTION 'custom bouquet component is invalid'
            USING ERRCODE = '22023';
        END IF;

        v_product_id_text := nullif(
          btrim(coalesce(v_component ->> 'product_id', '')),
          ''
        );
        v_component_qty := nullif(
          btrim(coalesce(v_component ->> 'quantity', '')),
          ''
        )::numeric;

        IF v_product_id_text IS NULL
           OR v_product_id_text !~*
             '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
           OR v_component_qty IS NULL
           OR v_component_qty <> trunc(v_component_qty)
           OR v_component_qty < 1
           OR v_component_qty > 99 THEN
          RAISE EXCEPTION 'custom bouquet component is invalid'
            USING ERRCODE = '22023';
        END IF;

        v_product_id := v_product_id_text::uuid;

        SELECT * INTO v_product
        FROM public.products
        WHERE id = v_product_id
          AND is_active = true;

        IF NOT FOUND
           OR coalesce(v_product.type, 'flower') <> 'flower' THEN
          RAISE EXCEPTION 'custom bouquet flower is no longer available'
            USING ERRCODE = '22023';
        END IF;

        v_custom_qty := v_custom_qty + v_component_qty::integer;
        IF v_custom_qty > 15 THEN
          RAISE EXCEPTION 'custom bouquet has too many flowers'
            USING ERRCODE = '22023';
        END IF;

        v_line := v_line
          + (public.orchid_price_round(v_product.price)
             * v_component_qty::integer);

        v_flowers := v_flowers || jsonb_build_array(
          jsonb_build_object(
            'product_id', v_product.id,
            'name', left(coalesce(nullif(v_product.name, ''), 'Flower'), 200),
            'quantity', v_component_qty::integer,
            'unit_price', public.orchid_price_round(v_product.price),
            'image_path', left(
              coalesce(
                nullif(v_component ->> 'image_path', ''),
                nullif(v_product.image_path, ''),
                ''
              ),
              2000
            )
          )
        );
      END LOOP;

      v_declared := nullif(
        btrim(coalesce(v_item ->> 'price_snapshot', '')),
        ''
      )::numeric;

      IF v_declared IS NULL
         OR abs(public.orchid_price_round(v_declared) - v_line) > 0.01 THEN
        RAISE EXCEPTION 'price changed while you were shopping'
          USING ERRCODE = '22023';
      END IF;

      v_description := left(
        coalesce(v_components ->> 'description', ''),
        1000
      );

      v_components_out := jsonb_build_object(
        'description', v_description,
        'flowers', v_flowers
      );
      IF v_message IS NOT NULL THEN
        v_components_out := v_components_out
          || jsonb_build_object('message', v_message);
      END IF;

      v_name := left(
        coalesce(
          nullif(btrim(v_item ->> 'name_snapshot'), ''),
          'Custom Bouquet'
        ),
        200
      );
      v_image := coalesce(
        nullif(v_item ->> 'image_snapshot', ''),
        v_flowers -> 0 ->> 'image_path',
        ''
      );

      v_rows := v_rows || jsonb_build_array(
        jsonb_build_object(
          'item_type', 'ready_bouquet',
          'product_id', null,
          'name_snapshot', v_name,
          'image_snapshot', left(v_image, 2000),
          'price_snapshot', v_line,
          'quantity', 1,
          'custom_components', v_components_out
        )
      );
    END IF;

    v_subtotal := v_subtotal + v_line;
    v_count := v_count + 1;
  END LOOP;

  IF v_count = 0 THEN
    RAISE EXCEPTION 'order items are invalid'
      USING ERRCODE = '22023';
  END IF;

  v_total := v_subtotal
    + public.orchid_delivery_fee()
    + public.orchid_service_fee();

  -- The order code is server-generated. The client never chooses it.
  FOR v_try IN 1..20 LOOP
    v_code := public.orchid_generate_order_code();
    EXIT WHEN NOT EXISTS (
      SELECT 1 FROM public.orders WHERE order_code = v_code
    );
  END LOOP;

  IF v_code IS NULL OR EXISTS (
    SELECT 1 FROM public.orders WHERE order_code = v_code
  ) THEN
    RAISE EXCEPTION 'could not allocate an order code'
      USING ERRCODE = 'P0001';
  END IF;

  INSERT INTO public.orders (
    order_code,
    status,
    user_id,
    message,
    additional_notes,
    delivery_address,
    delivery_date,
    order_time,
    delivery_fee,
    service_fee,
    total,
    payment_method,
    payment_status,
    created_at,
    updated_at
  )
  VALUES (
    v_code,
    'PENDING'::public.order_status,
    v_user_id,
    nullif(left(coalesce(p_message, ''), 1000), ''),
    nullif(left(coalesce(p_notes, ''), 1000), ''),
    left(btrim(p_delivery_address), 500),
    p_delivery_date,
    coalesce(p_order_time, p_delivery_date),
    public.orchid_delivery_fee(),
    public.orchid_service_fee(),
    v_total,
    v_payment_method,
    'unpaid',
    now(),
    now()
  )
  RETURNING id INTO v_order_id;

  FOR v_item IN SELECT value FROM jsonb_array_elements(v_rows)
  LOOP
    INSERT INTO public.order_items (
      order_id,
      item_type,
      product_id,
      name_snapshot,
      image_snapshot,
      price_snapshot,
      quantity,
      custom_components
    )
    VALUES (
      v_order_id,
      v_item ->> 'item_type',
      nullif(v_item ->> 'product_id', '')::uuid,
      v_item ->> 'name_snapshot',
      v_item ->> 'image_snapshot',
      (v_item ->> 'price_snapshot')::numeric,
      (v_item ->> 'quantity')::integer,
      CASE
        WHEN jsonb_typeof(v_item -> 'custom_components') = 'null'
          THEN NULL
        ELSE v_item -> 'custom_components'
      END
    );
  END LOOP;

  RETURN jsonb_build_object(
    'order_id', v_order_id,
    'order_code', v_code,
    'subtotal', v_subtotal,
    'delivery_fee', public.orchid_delivery_fee(),
    'service_fee', public.orchid_service_fee(),
    'total', v_total,
    'payment_method', v_payment_method,
    'items_count', v_count
  );
END;
$$;

REVOKE ALL ON FUNCTION public.create_order(
  text, text, text, timestamptz, timestamptz, text, jsonb
) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.create_order(
  text, text, text, timestamptz, timestamptz, text, jsonb
) FROM anon;
GRANT EXECUTE ON FUNCTION public.create_order(
  text, text, text, timestamptz, timestamptz, text, jsonb
) TO authenticated;

-- Internal helpers must never be callable directly.
REVOKE ALL ON FUNCTION public.orchid_price_round(numeric) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.orchid_delivery_fee() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.orchid_service_fee() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.orchid_generate_order_code() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.orchid_verify_order_pricing(uuid) FROM PUBLIC, anon, authenticated;


-- -----------------------------------------------------------------------------
-- 5) Close the direct customer INSERT path
-- -----------------------------------------------------------------------------
-- Order creation now goes through create_order(), which owns the price and
-- total. Keeping INSERT on the tables would leave the original hole open.
REVOKE INSERT ON public.orders FROM anon, authenticated;
REVOKE INSERT, UPDATE ON public.order_items FROM anon, authenticated;

DROP POLICY IF EXISTS "customers insert own orders" ON public.orders;
DROP POLICY IF EXISTS "customers insert own order items" ON public.order_items;

-- Keep DELETE so a customer can still remove an unpaid abandoned order; the
-- FK cascade to order_items requires DELETE on the child table.
GRANT DELETE ON public.order_items TO authenticated;


-- -----------------------------------------------------------------------------
-- 6) Attempt lifecycle
-- -----------------------------------------------------------------------------

-- Verifies ownership/pricing, reuses a live checkout, expires sessions past
-- Paymob's documented one-hour client-secret lifetime, and quarantines an
-- unfinished `created` row instead of treating it as a failure.
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
  v_items_total numeric;
  v_amount_cents bigint;
BEGIN
  IF p_order_id IS NULL OR p_user_id IS NULL THEN
    RAISE EXCEPTION 'missing order or user'
      USING ERRCODE = '22023';
  END IF;

  -- Order first: the same order lock is used by attach/fail/unknown/webhook.
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

  -- An uncertain Paymob submission blocks every new chargeable intention.
  IF EXISTS (
    SELECT 1 FROM public.payment_attempts
    WHERE order_id = p_order_id AND status = 'unknown'
  ) THEN
    RAISE EXCEPTION 'payment outcome is unknown'
      USING ERRCODE = 'P0001';
  END IF;

  -- A `created` row older than two minutes means the Edge Function died (or
  -- the request was lost) without recording an outcome. Quarantine it.
  UPDATE public.payment_attempts
  SET status = 'unknown',
      unknown_since = now(),
      failure_reason = 'Payment initiation did not complete',
      updated_at = now()
  WHERE order_id = p_order_id
    AND status = 'created'
    AND updated_at < now() - interval '2 minutes';

  IF FOUND THEN
    UPDATE public.orders
    SET payment_status = 'pending',
        updated_at = now()
    WHERE id = p_order_id
      AND payment_status NOT IN ('paid', 'refund_pending', 'refunded');

    RAISE EXCEPTION 'payment outcome is unknown'
      USING ERRCODE = 'P0001';
  END IF;

  -- Paymob documents that the checkout client secret expires in one hour.
  -- Keep a five-minute safety margin before allowing a fresh session.
  UPDATE public.payment_attempts
  SET status = 'expired',
      failure_reason = 'Paymob checkout session expired',
      updated_at = now(),
      completed_at = now()
  WHERE order_id = p_order_id
    AND status = 'pending'
    AND coalesce(expires_at, updated_at + interval '55 minutes')
        < now() - interval '5 minutes';

  SELECT * INTO v_attempt
  FROM public.payment_attempts
  WHERE order_id = p_order_id
    AND status IN ('created', 'pending')
  ORDER BY created_at DESC
  LIMIT 1
  FOR UPDATE;

  IF FOUND THEN
    IF v_attempt.checkout_url IS NOT NULL THEN
      UPDATE public.orders
      SET payment_status = 'pending',
          updated_at = now()
      WHERE id = p_order_id
        AND payment_status NOT IN ('paid', 'refund_pending', 'refunded');

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

    -- Still inside the two-minute initiation window.
    RAISE EXCEPTION 'payment is already starting'
      USING ERRCODE = 'P0001';
  END IF;

  -- Recompute from the catalog, never from the client-authored order row.
  v_items_total := public.orchid_verify_order_pricing(p_order_id);

  IF v_order.delivery_fee IS DISTINCT FROM public.orchid_delivery_fee()
     OR v_order.service_fee IS DISTINCT FROM public.orchid_service_fee()
     OR v_items_total
        + public.orchid_delivery_fee()
        + public.orchid_service_fee()
        <> v_order.total THEN
    RAISE EXCEPTION 'order total is inconsistent'
      USING ERRCODE = '22023';
  END IF;

  v_amount_cents := round(v_order.total * 100)::bigint;
  IF v_amount_cents <= 0 THEN
    RAISE EXCEPTION 'order total is invalid'
      USING ERRCODE = '22023';
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

  UPDATE public.orders
  SET payment_status = 'pending',
      updated_at = now()
  WHERE id = p_order_id
    AND payment_status NOT IN ('paid', 'refund_pending', 'refunded');

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

REVOKE ALL ON FUNCTION public.begin_paymob_attempt(uuid, uuid)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.begin_paymob_attempt(uuid, uuid)
  TO service_role;

-- Stores the Paymob intention identifiers. It also accepts an `unknown`
-- attempt: if Paymob answered after the local request was quarantined, this is
-- the verified evidence needed to reopen the checkout safely.
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
  IF p_intention_id IS NULL OR btrim(p_intention_id) = ''
     OR p_checkout_url IS NULL OR btrim(p_checkout_url) = '' THEN
    RAISE EXCEPTION 'missing Paymob intention data'
      USING ERRCODE = '22023';
  END IF;

  SELECT * INTO v_attempt
  FROM public.payment_attempts
  WHERE id = p_attempt_id
    AND user_id = p_user_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'payment attempt is not open'
      USING ERRCODE = 'P0001';
  END IF;

  -- Order first, then attempt, matching every other lifecycle function.
  SELECT * INTO v_order
  FROM public.orders
  WHERE id = v_attempt.order_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'payment attempt is not open'
      USING ERRCODE = 'P0001';
  END IF;

  SELECT * INTO v_attempt
  FROM public.payment_attempts
  WHERE id = p_attempt_id
  FOR UPDATE;

  IF v_order.payment_status IN ('paid', 'refund_pending', 'refunded')
     OR v_order.status <> 'PENDING'::public.order_status
     OR v_order.payment_method IS DISTINCT FROM 'card' THEN
    UPDATE public.payment_attempts
    SET status = 'cancelled',
        failure_reason = 'Order is no longer payable',
        updated_at = now(),
        completed_at = now()
    WHERE id = p_attempt_id
      AND status IN ('created', 'unknown');

    RAISE EXCEPTION 'order is no longer payable'
      USING ERRCODE = '22023';
  END IF;

  IF v_attempt.status NOT IN ('created', 'unknown') THEN
    RAISE EXCEPTION 'payment attempt is not open'
      USING ERRCODE = 'P0001';
  END IF;

  UPDATE public.payment_attempts
  SET status = 'pending',
      paymob_intention_id = p_intention_id,
      paymob_order_id = p_paymob_order_id,
      checkout_url = p_checkout_url,
      failure_reason = NULL,
      unknown_since = NULL,
      expires_at = now() + interval '55 minutes',
      updated_at = now()
  WHERE id = p_attempt_id
  RETURNING * INTO v_attempt;

  UPDATE public.orders
  SET payment_status = 'pending',
      updated_at = now()
  WHERE id = v_attempt.order_id
    AND payment_status NOT IN ('paid', 'refund_pending', 'refunded');

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
) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.attach_paymob_intention(
  uuid, uuid, text, text, text
) TO service_role;

-- A definite local validation failure or a Paymob 4xx rejection. Never use this
-- for a timeout, a 5xx, a parse error or any other uncertain outcome.
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
  SELECT * INTO v_attempt
  FROM public.payment_attempts
  WHERE id = p_attempt_id
    AND user_id = p_user_id;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('updated', false);
  END IF;

  -- Order first, then attempt.
  PERFORM 1 FROM public.orders WHERE id = v_attempt.order_id FOR UPDATE;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('updated', false);
  END IF;

  UPDATE public.payment_attempts
  SET status = 'failed',
      failure_reason = left(
        coalesce(nullif(btrim(p_reason), ''), 'Payment could not be started'),
        500
      ),
      updated_at = now(),
      completed_at = now()
  WHERE id = p_attempt_id
    AND status = 'created'
  RETURNING * INTO v_attempt;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('updated', false);
  END IF;

  UPDATE public.orders
  SET payment_status = 'failed',
      updated_at = now()
  WHERE id = v_attempt.order_id
    AND payment_status NOT IN ('paid', 'refund_pending', 'refunded')
    AND NOT EXISTS (
      SELECT 1 FROM public.payment_attempts
      WHERE order_id = v_attempt.order_id
        AND id <> v_attempt.id
        AND status IN ('created', 'pending', 'unknown', 'succeeded')
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
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.fail_paymob_attempt(uuid, uuid, text)
  TO service_role;

-- Quarantines an uncertain Paymob submission. The order stays `pending`, and
-- the partial unique index prevents any new chargeable attempt for this order.
CREATE OR REPLACE FUNCTION public.mark_paymob_attempt_unknown(
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
  SELECT * INTO v_attempt
  FROM public.payment_attempts
  WHERE id = p_attempt_id
    AND user_id = p_user_id;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('updated', false);
  END IF;

  PERFORM 1 FROM public.orders WHERE id = v_attempt.order_id FOR UPDATE;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('updated', false);
  END IF;

  UPDATE public.payment_attempts
  SET status = 'unknown',
      unknown_since = now(),
      failure_reason = left(
        coalesce(
          nullif(btrim(p_reason), ''),
          'Paymob did not confirm whether the payment started'
        ),
        500
      ),
      updated_at = now()
  WHERE id = p_attempt_id
    AND status IN ('created', 'pending')
  RETURNING * INTO v_attempt;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('updated', false);
  END IF;

  UPDATE public.orders
  SET payment_status = 'pending',
      updated_at = now()
  WHERE id = v_attempt.order_id
    AND payment_status NOT IN ('paid', 'refund_pending', 'refunded');

  RETURN jsonb_build_object(
    'updated', true,
    'attempt_id', v_attempt.id,
    'order_id', v_attempt.order_id,
    'status', v_attempt.status
  );
END;
$$;

REVOKE ALL ON FUNCTION public.mark_paymob_attempt_unknown(uuid, uuid, text)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.mark_paymob_attempt_unknown(uuid, uuid, text)
  TO service_role;

-- Operator-only reconciliation after checking the Paymob dashboard or the
-- Transaction Inquiry API. Only a verified no-charge outcome may release the
-- quarantine; never call this just because the customer is waiting.
CREATE OR REPLACE FUNCTION public.resolve_paymob_attempt(
  p_attempt_id uuid,
  p_outcome text,
  p_note text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_attempt public.payment_attempts%ROWTYPE;
  v_outcome text := lower(btrim(coalesce(p_outcome, '')));
BEGIN
  IF v_outcome NOT IN ('failed', 'expired') THEN
    RAISE EXCEPTION 'reconciliation outcome must be failed or expired'
      USING ERRCODE = '22023';
  END IF;

  SELECT * INTO v_attempt
  FROM public.payment_attempts
  WHERE id = p_attempt_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'payment attempt not found'
      USING ERRCODE = 'P0002';
  END IF;

  PERFORM 1 FROM public.orders WHERE id = v_attempt.order_id FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'order not found'
      USING ERRCODE = 'P0002';
  END IF;

  UPDATE public.payment_attempts
  SET status = v_outcome,
      failure_reason = left(
        'Manually reconciled: '
          || coalesce(nullif(btrim(p_note), ''), 'no Paymob charge found'),
        500
      ),
      unknown_since = NULL,
      updated_at = now(),
      completed_at = now()
  WHERE id = p_attempt_id
    AND status = 'unknown'
  RETURNING * INTO v_attempt;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'payment attempt is not awaiting reconciliation'
      USING ERRCODE = 'P0001';
  END IF;

  UPDATE public.orders
  SET payment_status = 'failed',
      updated_at = now()
  WHERE id = v_attempt.order_id
    AND payment_status NOT IN ('paid', 'refund_pending', 'refunded')
    AND NOT EXISTS (
      SELECT 1 FROM public.payment_attempts
      WHERE order_id = v_attempt.order_id
        AND id <> v_attempt.id
        AND status IN ('created', 'pending', 'unknown', 'succeeded')
    );

  RETURN jsonb_build_object(
    'updated', true,
    'attempt_id', v_attempt.id,
    'order_id', v_attempt.order_id,
    'status', v_attempt.status
  );
END;
$$;

REVOKE ALL ON FUNCTION public.resolve_paymob_attempt(uuid, text, text)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.resolve_paymob_attempt(uuid, text, text)
  TO service_role;


-- -----------------------------------------------------------------------------
-- 7) Cancellation / deletion cleanup
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.cancel_payment_attempts_on_order_cancel()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  -- A customer cancel closes only not-yet-settled attempts. `unknown` stays
  -- quarantined so a late charge can still be reconciled, and `succeeded`
  -- is never downgraded.
  UPDATE public.payment_attempts
  SET status = 'cancelled',
      failure_reason = 'Order was canceled',
      updated_at = now(),
      completed_at = now()
  WHERE order_id = NEW.id
    AND status IN ('created', 'pending');

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS cancel_payment_attempts_on_order_cancel
  ON public.orders;
CREATE TRIGGER cancel_payment_attempts_on_order_cancel
  AFTER UPDATE OF status ON public.orders
  FOR EACH ROW
  WHEN (
    NEW.status = 'CANCELED'::public.order_status
    AND OLD.status IS DISTINCT FROM 'CANCELED'::public.order_status
  )
  EXECUTE FUNCTION public.cancel_payment_attempts_on_order_cancel();

-- An order with an uncertain attempt must not be deleted: the attempt row is
-- the only local evidence needed to reconcile a possibly-created charge.
CREATE OR REPLACE FUNCTION public.enforce_customer_order_delete()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  IF auth.uid() IS NULL OR public.is_admin() THEN
    RETURN OLD;
  END IF;

  IF OLD.payment_status IN ('paid', 'pending', 'refund_pending')
     OR EXISTS (
       SELECT 1
       FROM public.payment_attempts
       WHERE order_id = OLD.id
         AND status IN ('created', 'pending', 'unknown', 'succeeded')
     ) THEN
    RAISE EXCEPTION 'orders with a payment in progress cannot be deleted'
      USING ERRCODE = '42501';
  END IF;

  RETURN OLD;
END;
$$;


-- -----------------------------------------------------------------------------
-- 8) Replay-safe webhook settlement
-- -----------------------------------------------------------------------------
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
  v_delivery_count integer;
  v_attempt_id uuid;
  v_order_id uuid;
  v_result text;
  v_duplicate boolean;
BEGIN
  IF p_transaction_id IS NULL OR btrim(p_transaction_id) = '' THEN
    RAISE EXCEPTION 'missing Paymob transaction id'
      USING ERRCODE = '22023';
  END IF;

  -- Refuse a malformed callback instead of turning "no outcome" into a
  -- failure. The Edge Function also validates these fields.
  IF p_success IS NULL AND p_pending IS NULL THEN
    RAISE EXCEPTION 'missing Paymob transaction outcome'
      USING ERRCODE = '22023';
  END IF;

  -- Correlate by the Paymob order id stored at attach time. The merchant
  -- reference (our attempt id) is only a fallback for a callback that arrives
  -- before attach. Neither value is used as a trusted amount.
  IF p_paymob_order_id IS NOT NULL AND btrim(p_paymob_order_id) <> '' THEN
    SELECT id INTO v_attempt_id
    FROM public.payment_attempts
    WHERE paymob_order_id = p_paymob_order_id
    ORDER BY created_at DESC
    LIMIT 1;
  END IF;

  IF v_attempt_id IS NULL
     AND p_merchant_order_id IS NOT NULL
     AND p_merchant_order_id ~*
       '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' THEN
    SELECT id INTO v_attempt_id
    FROM public.payment_attempts
    WHERE id = p_merchant_order_id::uuid
      AND (
        paymob_order_id IS NULL
        OR p_paymob_order_id IS NULL
        OR paymob_order_id = p_paymob_order_id
      );
  END IF;

  -- Every delivery is recorded. A repeated transaction id updates the existing
  -- audit row and is processed again: a pending/unknown first delivery must be
  -- allowed to become terminal.
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
    payload,
    delivery_count,
    last_received_at
  )
  VALUES (
    p_transaction_id,
    p_paymob_order_id,
    v_attempt_id,
    NULL,
    p_event_type,
    p_success,
    p_pending,
    p_amount_cents,
    p_currency,
    coalesce(p_payload, '{}'::jsonb),
    1,
    now()
  )
  ON CONFLICT (paymob_transaction_id) DO UPDATE
  SET paymob_order_id = coalesce(
        excluded.paymob_order_id,
        public.paymob_webhook_events.paymob_order_id
      ),
      attempt_id = coalesce(
        public.paymob_webhook_events.attempt_id,
        excluded.attempt_id
      ),
      order_id = coalesce(
        public.paymob_webhook_events.order_id,
        excluded.order_id
      ),
      event_type = excluded.event_type,
      success = excluded.success,
      pending = excluded.pending,
      amount_cents = excluded.amount_cents,
      currency = excluded.currency,
      payload = excluded.payload,
      delivery_count =
        public.paymob_webhook_events.delivery_count + 1,
      last_received_at = now(),
      result = NULL
  RETURNING id, delivery_count, attempt_id
  INTO v_event_id, v_delivery_count, v_attempt_id;

  v_duplicate := v_delivery_count > 1;

  IF v_attempt_id IS NULL THEN
    UPDATE public.paymob_webhook_events
    SET result = 'unknown_attempt'
    WHERE id = v_event_id;

    RETURN jsonb_build_object(
      'duplicate', v_duplicate,
      'result', 'unknown_attempt',
      'attempt_id', null,
      'order_id', null
    );
  END IF;

  SELECT order_id INTO v_order_id
  FROM public.payment_attempts
  WHERE id = v_attempt_id;

  IF v_order_id IS NULL THEN
    UPDATE public.paymob_webhook_events
    SET result = 'unknown_attempt'
    WHERE id = v_event_id;

    RETURN jsonb_build_object(
      'duplicate', v_duplicate,
      'result', 'unknown_attempt',
      'attempt_id', v_attempt_id,
      'order_id', null
    );
  END IF;

  -- Same lock order as every lifecycle function: order, then attempt.
  SELECT * INTO v_order
  FROM public.orders
  WHERE id = v_order_id
  FOR UPDATE;

  IF NOT FOUND THEN
    UPDATE public.paymob_webhook_events
    SET result = 'unknown_attempt'
    WHERE id = v_event_id;

    RETURN jsonb_build_object(
      'duplicate', v_duplicate,
      'result', 'unknown_attempt',
      'attempt_id', v_attempt_id,
      'order_id', null
    );
  END IF;

  SELECT * INTO v_attempt
  FROM public.payment_attempts
  WHERE id = v_attempt_id
  FOR UPDATE;

  IF NOT FOUND OR v_attempt.order_id <> v_order.id THEN
    UPDATE public.paymob_webhook_events
    SET result = 'unknown_attempt'
    WHERE id = v_event_id;

    RETURN jsonb_build_object(
      'duplicate', v_duplicate,
      'result', 'unknown_attempt',
      'attempt_id', v_attempt_id,
      'order_id', v_order.id
    );
  END IF;

  UPDATE public.paymob_webhook_events
  SET order_id = v_order.id,
      attempt_id = v_attempt.id
  WHERE id = v_event_id;

  -- Pending callback: keep/reopen the attempt, but never downgrade a success.
  IF p_pending IS TRUE THEN
    IF v_attempt.status = 'succeeded' THEN
      v_result := 'already_succeeded';
    ELSIF v_attempt.status NOT IN ('created', 'pending', 'unknown') THEN
      -- A delayed pending delivery must not reopen a terminal attempt.
      v_result := 'already_' || v_attempt.status;
    ELSE
      UPDATE public.payment_attempts
      SET status = 'pending',
          paymob_order_id = coalesce(
            paymob_order_id,
            nullif(p_paymob_order_id, '')
          ),
          unknown_since = NULL,
          expires_at = coalesce(
            expires_at,
            now() + interval '55 minutes'
          ),
          failure_reason = NULL,
          updated_at = now()
      WHERE id = v_attempt_id;

      IF v_order.payment_status NOT IN ('paid', 'refund_pending', 'refunded')
         AND v_order.status = 'PENDING'::public.order_status THEN
        UPDATE public.orders
        SET payment_status = 'pending',
            updated_at = now()
        WHERE id = v_order.id;
      END IF;

      v_result := 'pending';
    END IF;

    UPDATE public.paymob_webhook_events
    SET result = v_result
    WHERE id = v_event_id;

    RETURN jsonb_build_object(
      'duplicate', v_duplicate,
      'result', v_result,
      'attempt_id', v_attempt_id,
      'order_id', v_order_id
    );
  END IF;

  -- A terminal callback must match the server-side amount/currency.
  IF p_amount_cents IS DISTINCT FROM v_attempt.amount_cents
     OR upper(coalesce(p_currency, '')) <> v_attempt.currency THEN
    IF v_attempt.status <> 'succeeded' THEN
      UPDATE public.payment_attempts
      SET status = 'disputed',
          failure_reason = 'Amount or currency mismatch in Paymob callback',
          unknown_since = NULL,
          updated_at = now(),
          completed_at = now()
      WHERE id = v_attempt_id;

      IF v_order.payment_status NOT IN ('paid', 'refund_pending', 'refunded')
         AND NOT EXISTS (
           SELECT 1 FROM public.payment_attempts
           WHERE order_id = v_order_id
             AND id <> v_attempt_id
             AND status IN ('created', 'pending', 'unknown', 'succeeded')
         ) THEN
        UPDATE public.orders
        SET payment_status = 'failed',
            updated_at = now()
        WHERE id = v_order_id;
      END IF;
    END IF;

    UPDATE public.paymob_webhook_events
    SET result = 'amount_mismatch'
    WHERE id = v_event_id;

    RETURN jsonb_build_object(
      'duplicate', v_duplicate,
      'result', 'amount_mismatch',
      'attempt_id', v_attempt_id,
      'order_id', v_order_id
    );
  END IF;

  -- Failure callback.
  IF p_success IS NOT TRUE THEN
    IF v_attempt.status = 'disputed' THEN
      v_result := 'disputed';
    ELSIF v_attempt.status = 'succeeded' THEN
      -- A verified success is terminal for this attempt. Repair a missing order
      -- flag if an older deployment left it inconsistent.
      UPDATE public.orders
      SET payment_status = CASE
            WHEN status = 'CANCELED'::public.order_status
              THEN 'refund_pending'
            ELSE 'paid'
          END,
          paid_at = coalesce(paid_at, now()),
          updated_at = now()
      WHERE id = v_order_id
        AND payment_status NOT IN ('paid', 'refund_pending', 'refunded');

      v_result := 'already_succeeded';
    ELSE
      UPDATE public.payment_attempts
      SET status = 'failed',
          failure_reason = 'Paymob reported a failed transaction',
          paymob_order_id = coalesce(
            paymob_order_id,
            nullif(p_paymob_order_id, '')
          ),
          unknown_since = NULL,
          updated_at = now(),
          completed_at = now()
      WHERE id = v_attempt_id;

      IF v_order.payment_status NOT IN ('paid', 'refund_pending', 'refunded')
         AND NOT EXISTS (
           SELECT 1 FROM public.payment_attempts
           WHERE order_id = v_order_id
             AND id <> v_attempt_id
             AND status IN ('created', 'pending', 'unknown', 'succeeded')
         ) THEN
        UPDATE public.orders
        SET payment_status = 'failed',
            updated_at = now()
        WHERE id = v_order_id;
      END IF;

      v_result := 'failed';
    END IF;

    UPDATE public.paymob_webhook_events
    SET result = v_result
    WHERE id = v_event_id;

    RETURN jsonb_build_object(
      'duplicate', v_duplicate,
      'result', v_result,
      'attempt_id', v_attempt_id,
      'order_id', v_order_id
    );
  END IF;

  -- Success callback. A repeated success for the same attempt is idempotent.
  IF v_attempt.status = 'succeeded' THEN
    UPDATE public.orders
    SET payment_status = CASE
          WHEN status = 'CANCELED'::public.order_status
            THEN 'refund_pending'
          ELSE 'paid'
        END,
        paid_at = coalesce(paid_at, now()),
        updated_at = now()
    WHERE id = v_order_id
      AND payment_status NOT IN ('paid', 'refund_pending', 'refunded');

    v_result := 'already_succeeded';
  ELSIF v_order.payment_status IN ('paid', 'refund_pending', 'refunded')
        OR EXISTS (
          SELECT 1 FROM public.payment_attempts
          WHERE order_id = v_order_id
            AND id <> v_attempt_id
            AND status = 'succeeded'
        ) THEN
    -- A second, real charge for an already-paid order. Record it for support;
    -- never mark the order paid twice and never silently discard the callback.
    UPDATE public.payment_attempts
    SET status = 'disputed',
        failure_reason = 'Duplicate payment for an already-paid order',
        paymob_order_id = coalesce(
          paymob_order_id,
          nullif(p_paymob_order_id, '')
        ),
        unknown_since = NULL,
        updated_at = now(),
        completed_at = now()
    WHERE id = v_attempt_id
      AND status <> 'succeeded';

    v_result := 'duplicate_payment';
  ELSE
    UPDATE public.payment_attempts
    SET status = 'succeeded',
        failure_reason = NULL,
        paymob_order_id = coalesce(
          paymob_order_id,
          nullif(p_paymob_order_id, '')
        ),
        unknown_since = NULL,
        updated_at = now(),
        completed_at = now()
    WHERE id = v_attempt_id;

    -- Close every other live/quarantined attempt. A late charge for one of
    -- them is still caught above as duplicate_payment.
    UPDATE public.payment_attempts
    SET status = 'expired',
        failure_reason = 'Another payment attempt succeeded',
        unknown_since = NULL,
        updated_at = now(),
        completed_at = now()
    WHERE order_id = v_order_id
      AND id <> v_attempt_id
      AND status IN ('created', 'pending', 'unknown');

    IF v_order.status = 'CANCELED'::public.order_status THEN
      UPDATE public.orders
      SET payment_status = 'refund_pending',
          updated_at = now()
      WHERE id = v_order_id;

      v_result := 'paid_on_canceled_order';
    ELSE
      UPDATE public.orders
      SET payment_status = 'paid',
          paid_at = coalesce(paid_at, now()),
          payment_method = 'card',
          updated_at = now()
      WHERE id = v_order_id;

      v_result := 'paid';
    END IF;
  END IF;

  UPDATE public.paymob_webhook_events
  SET result = v_result
  WHERE id = v_event_id;

  RETURN jsonb_build_object(
    'duplicate', v_duplicate,
    'result', v_result,
    'attempt_id', v_attempt_id,
    'order_id', v_order_id
  );
END;
$$;

REVOKE ALL ON FUNCTION public.process_paymob_callback(
  text, text, text, text, boolean, boolean, bigint, text, jsonb
) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.process_paymob_callback(
  text, text, text, text, boolean, boolean, bigint, text, jsonb
) TO service_role;


-- -----------------------------------------------------------------------------
-- 9) Keep existing safe grants explicit
-- -----------------------------------------------------------------------------
-- Do NOT grant table-level SELECT on payment_attempts: checkout_url embeds the
-- Paymob client secret. The existing column-level grant from
-- 20261028000000_paymob_payments.sql remains in force.
GRANT ALL ON TABLE public.payment_attempts TO service_role;
GRANT ALL ON TABLE public.paymob_webhook_events TO service_role;
GRANT USAGE, SELECT ON SEQUENCE public.paymob_webhook_events_id_seq
  TO service_role;

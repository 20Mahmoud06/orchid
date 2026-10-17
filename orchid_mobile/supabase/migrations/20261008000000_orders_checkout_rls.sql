-- =============================================================================
-- Checkout phase: mobile order placement + PENDING status + RLS lockdown
--
-- IMPORTANT: `orders.status` is a PostgreSQL ENUM type (order_status), so the
-- new PENDING value must be added to the type itself — and a new enum value
-- cannot be used in the same transaction it was added.
--
-- Run this file in TWO steps (Dashboard -> SQL -> New query):
--   1) Run ONLY section A below, by itself. Wait for success.
--   2) Then run the rest of the file (sections B and C).
-- Both steps are idempotent (safe to re-run).
-- =============================================================================


-- -----------------------------------------------------------------------------
-- SECTION A - run this alone first
-- -----------------------------------------------------------------------------
ALTER TYPE public.order_status ADD VALUE IF NOT EXISTS 'PENDING';


-- -----------------------------------------------------------------------------
-- SECTION B - structural fixes (run after A)
-- The status vocabulary is enforced by the enum itself; no CHECK constraint
-- is needed.
-- -----------------------------------------------------------------------------

-- Deleting an order removes its items; product_id stays optional
-- (the mobile app inserts a custom-bouquet row with no product_id).
DO $$
DECLARE
  fk RECORD;
BEGIN
  FOR fk IN
    SELECT conname
    FROM pg_constraint
    WHERE conrelid = 'public.order_items'::regclass
      AND confrelid = 'public.orders'::regclass
      AND contype = 'f'
  LOOP
    EXECUTE format(
      'ALTER TABLE public.order_items DROP CONSTRAINT %I',
      fk.conname
    );
    EXECUTE format(
      'ALTER TABLE public.order_items ADD CONSTRAINT %I '
      'FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE',
      fk.conname
    );
  END LOOP;
END $$;

ALTER TABLE public.order_items ALTER COLUMN product_id DROP NOT NULL;


-- -----------------------------------------------------------------------------
-- SECTION C - row level security (run after B)
-- -----------------------------------------------------------------------------
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;

-- orders: customers see and place their own orders; admins see and manage all
DROP POLICY IF EXISTS "customers read own orders" ON public.orders;
CREATE POLICY "customers read own orders"
  ON public.orders FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

DROP POLICY IF EXISTS "admins read all orders" ON public.orders;
CREATE POLICY "admins read all orders"
  ON public.orders FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

DROP POLICY IF EXISTS "customers insert own orders" ON public.orders;
CREATE POLICY "customers insert own orders"
  ON public.orders FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid() AND status = 'PENDING');

DROP POLICY IF EXISTS "customers delete own orders" ON public.orders;
CREATE POLICY "customers delete own orders"
  ON public.orders FOR DELETE
  TO authenticated
  USING (user_id = auth.uid());

DROP POLICY IF EXISTS "admins update orders" ON public.orders;
CREATE POLICY "admins update orders"
  ON public.orders FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- order_items: same ownership rules, checked through the parent order
DROP POLICY IF EXISTS "customers read own order items" ON public.order_items;
CREATE POLICY "customers read own order items"
  ON public.order_items FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.orders o
      WHERE o.id = order_id AND o.user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "admins read all order items" ON public.order_items;
CREATE POLICY "admins read all order items"
  ON public.order_items FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

DROP POLICY IF EXISTS "customers insert own order items" ON public.order_items;
CREATE POLICY "customers insert own order items"
  ON public.order_items FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.orders o
      WHERE o.id = order_id AND o.user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "customers delete own order items" ON public.order_items;
CREATE POLICY "customers delete own order items"
  ON public.order_items FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.orders o
      WHERE o.id = order_id AND o.user_id = auth.uid()
    )
  );

-- products / categories: shoppers can browse, only admins can change
DROP POLICY IF EXISTS "authenticated read products" ON public.products;
CREATE POLICY "authenticated read products"
  ON public.products FOR SELECT
  TO authenticated
  USING (true);

DROP POLICY IF EXISTS "admins write products" ON public.products;
CREATE POLICY "admins write products"
  ON public.products FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

DROP POLICY IF EXISTS "authenticated read categories" ON public.categories;
CREATE POLICY "authenticated read categories"
  ON public.categories FOR SELECT
  TO authenticated
  USING (true);

DROP POLICY IF EXISTS "admins write categories" ON public.categories;
CREATE POLICY "admins write categories"
  ON public.categories FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

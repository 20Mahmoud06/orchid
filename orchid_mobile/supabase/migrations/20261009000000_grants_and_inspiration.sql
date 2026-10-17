-- =============================================================================
-- Fix: missing table privileges + curated Inspiration
--
-- Background: the checkout RLS migration (20261008000000) created RLS policies
-- but never granted table privileges. Without GRANT, every mobile request fails
-- with
--     42501 permission denied for table <x>
-- even though the rows and the policies are fine. That is why the mobile Home
-- (popular flowers/bouquets), Choose screens, profile and order history all come
-- back empty. GRANT lets a role *attempt* an operation; RLS still decides which
-- rows it actually sees, so granting SELECT broadly is safe.
--
-- Idempotent: safe to re-run.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- 1) Table privileges
-- -----------------------------------------------------------------------------
GRANT USAGE ON SCHEMA public TO anon, authenticated;

-- Catalog is readable without or with a session (shoppers browse).
GRANT SELECT ON public.products TO anon, authenticated;
GRANT SELECT ON public.categories TO anon, authenticated;

-- Everything a signed-in customer does with their own data.
GRANT SELECT, INSERT, UPDATE, DELETE ON public.orders TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.order_items TO authenticated;
GRANT SELECT, INSERT, UPDATE ON public.profiles TO authenticated;


-- -----------------------------------------------------------------------------
-- 2) Public (anon) read policies for the catalog
-- (the existing policies only target `authenticated`)
-- -----------------------------------------------------------------------------
DROP POLICY IF EXISTS "anyone read active products" ON public.products;
CREATE POLICY "anyone read active products"
  ON public.products FOR SELECT
  TO anon
  USING (is_active = true);

DROP POLICY IF EXISTS "anyone read categories" ON public.categories;
CREATE POLICY "anyone read categories"
  ON public.categories FOR SELECT
  TO anon
  USING (true);


-- -----------------------------------------------------------------------------
-- 3) profiles: self access + admin access
-- Admin checks go through a SECURITY DEFINER function to avoid the infinite
-- recursion of a profiles policy that queries profiles.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = 'admin'
  );
$$;

GRANT EXECUTE ON FUNCTION public.is_admin() TO anon, authenticated;

DROP POLICY IF EXISTS "users read own profile" ON public.profiles;
CREATE POLICY "users read own profile"
  ON public.profiles FOR SELECT
  TO authenticated
  USING (id = auth.uid());

DROP POLICY IF EXISTS "users insert own profile" ON public.profiles;
CREATE POLICY "users insert own profile"
  ON public.profiles FOR INSERT
  TO authenticated
  WITH CHECK (id = auth.uid());

DROP POLICY IF EXISTS "users update own profile" ON public.profiles;
CREATE POLICY "users update own profile"
  ON public.profiles FOR UPDATE
  TO authenticated
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());

DROP POLICY IF EXISTS "admins read all profiles" ON public.profiles;
CREATE POLICY "admins read all profiles"
  ON public.profiles FOR SELECT
  TO authenticated
  USING (public.is_admin());


-- -----------------------------------------------------------------------------
-- 4) Curated Inspiration
-- The admin features a real custom bouquet that a customer ordered; the mobile
-- app shows the most recent featured ones, rendered with the existing UI.
-- `ingredients` is a snapshot so later catalog/profile changes never affect it:
--   [{ "product_id": "<uuid>", "name": "pink rose", "unit_price": 30, "quantity": 2 }]
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.inspiration_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  display_name text,
  image_snapshot text,
  description text,
  ingredients jsonb NOT NULL DEFAULT '[]'::jsonb,
  source_order_item_id uuid,
  created_at timestamptz NOT NULL DEFAULT now()
);

GRANT SELECT ON public.inspiration_items TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON public.inspiration_items TO authenticated;

ALTER TABLE public.inspiration_items ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anyone read inspiration" ON public.inspiration_items;
CREATE POLICY "anyone read inspiration"
  ON public.inspiration_items FOR SELECT
  TO anon, authenticated
  USING (true);

DROP POLICY IF EXISTS "admins write inspiration" ON public.inspiration_items;
CREATE POLICY "admins write inspiration"
  ON public.inspiration_items FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

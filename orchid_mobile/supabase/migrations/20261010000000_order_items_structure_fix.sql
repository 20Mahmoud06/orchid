-- =============================================================================
-- Fix: `order_items` check constraint rejected legitimate mobile orders.
--
-- The pre-existing constraint named `order_item_structure` does not match the
-- rows the mobile app writes:
--   * a product line may carry an optional per-item message inside
--     `custom_components`, and
--   * a custom bouquet line has a NULL `product_id` but populated
--     `custom_components`.
--
-- Replace it with a rule every valid order item satisfies: a line is either a
-- reference to a catalog product, or an inline custom arrangement.
--
-- Idempotent - safe to re-run. Run in the Supabase SQL editor like the other
-- migrations.
-- =============================================================================

ALTER TABLE public.order_items
  DROP CONSTRAINT IF EXISTS order_item_structure;

ALTER TABLE public.order_items
  ADD CONSTRAINT order_item_structure
  CHECK (product_id IS NOT NULL OR custom_components IS NOT NULL);

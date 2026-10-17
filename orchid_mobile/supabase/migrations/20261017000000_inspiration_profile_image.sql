-- =============================================================================
-- Inspiration: show the creator's profile picture on the mobile inspiration
-- tab.
--
-- `inspiration_items` currently only stores the creator's display name, so the
-- app can never render their real avatar (profiles are RLS-protected and only
-- readable by their owner/admins). Add a `profile_image` snapshot column and
-- fill it automatically from the source order item's customer profile.
--
-- The trigger runs as SECURITY DEFINER so it can read `orders`/`profiles`
-- regardless of the caller, and the snapshot keeps working even if the
-- profile image changes later (same philosophy as the other snapshots).
--
-- Idempotent - safe to re-run. Run in the Supabase SQL editor like the other
-- migrations.
-- =============================================================================

ALTER TABLE public.inspiration_items
  ADD COLUMN IF NOT EXISTS profile_image text;

-- Copies the creator's profile image path (or NULL when the order item cannot
-- be resolved / the customer has no picture) onto the inspiration row.
CREATE OR REPLACE FUNCTION public.fill_inspiration_profile_image()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF (NEW.profile_image IS NULL OR NEW.profile_image = '')
     AND NEW.source_order_item_id IS NOT NULL THEN
    SELECT p.profile_image
      INTO NEW.profile_image
      FROM public.order_items oi
      JOIN public.orders o ON o.id = oi.order_id
      JOIN public.profiles p ON p.id = o.user_id
     WHERE oi.id = NEW.source_order_item_id;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS fill_inspiration_profile_image
  ON public.inspiration_items;
CREATE TRIGGER fill_inspiration_profile_image
  BEFORE INSERT OR UPDATE OF source_order_item_id
  ON public.inspiration_items
  FOR EACH ROW
  EXECUTE FUNCTION public.fill_inspiration_profile_image();

-- Backfill the already featured bouquets.
UPDATE public.inspiration_items i
   SET profile_image = p.profile_image
  FROM public.order_items oi
  JOIN public.orders o ON o.id = oi.order_id
  JOIN public.profiles p ON p.id = o.user_id
 WHERE oi.id = i.source_order_item_id
   AND (i.profile_image IS NULL OR i.profile_image = '');

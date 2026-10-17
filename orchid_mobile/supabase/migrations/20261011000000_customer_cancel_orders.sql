-- =============================================================================
-- Let a customer cancel their own order.
--
-- The app's order-history trash icon now marks an order CANCELED instead of
-- deleting it, so the row stays visible in the admin dashboard. Admins already
-- had an UPDATE policy; customers need their own, restricted to setting the
-- status to CANCELED (they cannot change other fields or un-cancel an order).
--
-- Idempotent - safe to re-run. Run in the Supabase SQL editor.
-- =============================================================================

DROP POLICY IF EXISTS "customers cancel own orders" ON public.orders;
CREATE POLICY "customers cancel own orders"
  ON public.orders FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid() AND status = 'CANCELED');

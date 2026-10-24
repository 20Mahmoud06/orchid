-- =============================================================================
-- Dashboard order aggregates with Egypt business-day buckets.
--
-- The admin dashboard needs counts and completed-order revenue for arbitrary
-- date ranges, including All Time. Fetching every order just to sum it in the
-- Flutter client would download the full order history as it grows, so this
-- read-only function aggregates in Postgres instead.
--
-- * `p_start` / `p_end` are UTC timestamptz boundaries supplied by the admin
--   app (inclusive start, exclusive end). They are already converted from
--   Africa/Cairo wall-clock dates by the client.
-- * `p_bucket` is 'hour', 'day', or 'month'. Buckets are truncated in Cairo
--   time so business days match the timestamps shown in the dashboard.
-- * Revenue follows the existing business rule: sum of `total` for COMPLETED
--   orders only.
-- * SECURITY INVOKER keeps the existing orders RLS policies in force; the
--   function is not a security bypass.
--
-- No table, column, or RLS changes are required.
-- Idempotent - safe to re-run. Run in the Supabase SQL editor.
-- =============================================================================

CREATE OR REPLACE FUNCTION public.dashboard_order_buckets(
  p_start timestamptz DEFAULT NULL,
  p_end timestamptz DEFAULT NULL,
  p_bucket text DEFAULT 'day'
)
RETURNS TABLE (
  bucket_start timestamp,
  total_orders bigint,
  completed_orders bigint,
  pending_orders bigint,
  preparing_orders bigint,
  canceled_orders bigint,
  revenue numeric
)
LANGUAGE sql
STABLE
SECURITY INVOKER
SET search_path = public
AS $$
  SELECT
    date_trunc(
      CASE p_bucket
        WHEN 'hour' THEN 'hour'
        WHEN 'month' THEN 'month'
        ELSE 'day'
      END,
      o.created_at AT TIME ZONE 'Africa/Cairo'
    ) AS bucket_start,
    count(*) AS total_orders,
    count(*) FILTER (WHERE o.status = 'COMPLETED') AS completed_orders,
    count(*) FILTER (WHERE o.status = 'PENDING') AS pending_orders,
    count(*) FILTER (WHERE o.status = 'PREPARING') AS preparing_orders,
    count(*) FILTER (WHERE o.status = 'CANCELED') AS canceled_orders,
    coalesce(
      sum(o.total) FILTER (WHERE o.status = 'COMPLETED'),
      0::numeric
    ) AS revenue
  FROM public.orders o
  WHERE (p_start IS NULL OR o.created_at >= p_start)
    AND (p_end IS NULL OR o.created_at < p_end)
  GROUP BY 1
  ORDER BY 1;
$$;

REVOKE ALL ON FUNCTION
  public.dashboard_order_buckets(timestamptz, timestamptz, text)
FROM PUBLIC;

GRANT EXECUTE ON FUNCTION
  public.dashboard_order_buckets(timestamptz, timestamptz, text)
TO authenticated;

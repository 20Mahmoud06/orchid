import { createClient } from "jsr:@supabase/supabase-js@2";

import {
  asInt,
  asString,
  json,
  readCallbackBody,
  requireEnv,
  verifyPaymobHmac,
} from "../_shared/paymob.ts";

// Paymob transaction callback.
//
// This endpoint is called by Paymob's servers, not by the apps, so it is
// deployed WITHOUT Supabase JWT verification:
//
//   supabase functions deploy paymob-webhook --no-verify-jwt
//
// Security properties:
// * SHA-512 HMAC is verified with PAYMOB_HMAC_SECRET using Paymob's exact field
//   order and a constant-time comparison.
// * The database function deduplicates by Paymob transaction id, locks the
//   attempt/order, and is the only writer of trusted payment state.
// * Amounts/currency are checked against the server-side payment attempt.
// * Nothing sensitive or personally identifiable is logged.

interface CallbackObject {
  id?: unknown;
  amount_cents?: unknown;
  currency?: unknown;
  success?: unknown;
  pending?: unknown;
  order?: {
    id?: unknown;
    merchant_order_id?: unknown;
  };
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    // Paymob does not call OPTIONS, but this keeps manual probes harmless.
    return new Response("ok", { status: 200 });
  }
  if (req.method !== "POST") {
    return json({ error: "method not allowed" }, 405);
  }

  let hmacSecret: string;
  let supabaseUrl: string;
  let serviceKey: string;
  try {
    hmacSecret = requireEnv("PAYMOB_HMAC_SECRET");
    supabaseUrl = requireEnv("SUPABASE_URL");
    serviceKey = requireEnv("SUPABASE_SERVICE_ROLE_KEY");
  } catch (error) {
    console.error(
      "paymob-webhook: configuration error",
      error instanceof Error ? error.message : "unknown",
    );
    return json({ error: "payment callback is not configured" }, 503);
  }

  let body: Awaited<ReturnType<typeof readCallbackBody>>;
  try {
    body = await readCallbackBody(req);
  } catch (_) {
    return json({ error: "invalid callback body" }, 400);
  }

  const eventType = typeof body.type === "string" ? body.type : null;
  if (eventType && eventType.toUpperCase() !== "TRANSACTION") {
    return json({ received: true, ignored: true }, 200);
  }

  const obj = body.obj;
  if (!obj || typeof obj !== "object") {
    return json({ error: "missing transaction object" }, 400);
  }

  const url = new URL(req.url);
  const receivedHmac = url.searchParams.get("hmac") ??
    url.searchParams.get("HMAC") ?? "";

  let validHmac = false;
  try {
    validHmac = await verifyPaymobHmac(obj, receivedHmac, hmacSecret);
  } catch (error) {
    console.error(
      "paymob-webhook: HMAC verification error",
      error instanceof Error ? error.name : "unknown",
    );
    return json({ error: "invalid callback signature" }, 401);
  }

  if (!validHmac) {
    console.error("paymob-webhook: invalid HMAC");
    return json({ error: "invalid callback signature" }, 401);
  }

  const transactionId = asString(obj.id);
  if (!transactionId) {
    return json({ error: "missing transaction id" }, 400);
  }

  const callback = obj as CallbackObject;

  // Never convert a malformed callback into "failed". If neither outcome flag
  // is present, acknowledge nothing and ask Paymob to retry.
  if (
    typeof callback.success !== "boolean" &&
    typeof callback.pending !== "boolean"
  ) {
    return json({ error: "missing transaction outcome" }, 400);
  }

  const paymobOrderId = asString(callback.order?.id);
  const merchantOrderId = asString(callback.order?.merchant_order_id);
  const amountCents = asInt(callback.amount_cents);
  const currency = asString(callback.currency);
  const success = callback.success === true;
  const pending = success ? false : callback.pending === true;

  const admin = createClient(supabaseUrl, serviceKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });

  const { data, error } = await admin.rpc("process_paymob_callback", {
    p_transaction_id: transactionId,
    p_paymob_order_id: paymobOrderId,
    p_merchant_order_id: merchantOrderId,
    p_event_type: eventType ?? "TRANSACTION",
    p_success: success,
    p_pending: pending,
    p_amount_cents: amountCents,
    p_currency: currency,
    p_payload: body,
  });

  if (error) {
    // Return a non-2xx so Paymob retries; the whole SQL function is atomic, so
    // a retry can safely process the same transaction.
    console.error(
      "paymob-webhook: process_paymob_callback failed",
      error.code,
      error.message,
    );
    return json({ error: "could not process callback" }, 500);
  }

  const result = (data as Record<string, unknown> | null)?.result;
  // Transaction id is safe to log; card data and customer details are not.
  console.log(
    "paymob-webhook: processed",
    `txn=${transactionId}`,
    `result=${result ?? "unknown"}`,
  );

  // A callback that arrives before the local attempt is attached must be
  // retried. A forever-unknown transaction eventually stops on Paymob's side.
  if (result === "unknown_attempt") {
    return json({ received: true, ...(data as Record<string, unknown>) }, 503);
  }

  return json({ received: true, ...(data as Record<string, unknown>) }, 200);
});

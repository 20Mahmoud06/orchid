import { createClient } from "jsr:@supabase/supabase-js@2";

import {
  asInt,
  assertHttpsUrl,
  asString,
  buildUnifiedCheckoutUrl,
  corsHeaders,
  corsJson,
  digitsOnly,
  isUuid,
  optionalEnv,
  requireEnv,
  splitName,
} from "../_shared/paymob.ts";

// Creates a Paymob Intention for the signed-in customer's order, then persists
// the intention id / checkout URL on the server-side payment attempt.
//
// Deploy with the normal JWT check (do NOT use --no-verify-jwt):
//   supabase functions deploy paymob-create-intention
//
// Required function secrets (TEST credentials while sandboxing):
//   PAYMOB_SECRET_KEY, PAYMOB_PUBLIC_KEY, PAYMOB_HMAC_SECRET,
//   PAYMOB_CARD_INTEGRATION_ID
//
// The client only receives the checkout URL (which contains the public key and
// the short-lived client secret). Paymob's secret key never leaves this
// function.

interface OrderRow {
  id: string;
  order_code: string | null;
  user_id: string;
  status: string;
  payment_method: string | null;
  payment_status: string | null;
  total: number | string | null;
  delivery_address: string | null;
}

interface ProfileRow {
  username: string | null;
  phone: string | null;
  address: string | null;
}

interface IntentionResponse {
  id?: unknown;
  client_secret?: unknown;
  intention_order_id?: unknown;
}

function mapRpcError(message: string): { status: number; error: string } {
  if (message.includes("payment outcome is unknown")) {
    return {
      status: 409,
      error:
        "Paymob has not confirmed your previous payment yet. Check this order in your history before trying again.",
    };
  }
  if (message.includes("payment is already starting")) {
    return {
      status: 409,
      error: "A payment is already being started. Please wait a moment.",
    };
  }
  if (
    message.includes("order total is inconsistent") ||
    message.includes("order pricing is inconsistent") ||
    message.includes("order item") ||
    message.includes("custom bouquet")
  ) {
    return {
      status: 409,
      error:
        "This order's price could not be verified. Please place the order again.",
    };
  }
  if (message.includes("order is already paid")) {
    return { status: 409, error: "This order has already been paid." };
  }
  if (message.includes("order is not payable")) {
    return {
      status: 409,
      error: "This order can no longer be paid online.",
    };
  }
  if (message.includes("order is no longer payable")) {
    return {
      status: 409,
      error: "This order can no longer be paid online.",
    };
  }
  if (message.includes("not a card order")) {
    return {
      status: 409,
      error: "This order is not set up for card payment.",
    };
  }
  if (message.includes("does not belong")) {
    return { status: 403, error: "This order is not available." };
  }
  if (message.includes("order not found") || message.includes("missing order")) {
    return { status: 404, error: "This order is not available." };
  }
  return {
    status: 500,
    error: "Could not start the card payment. Please try again.",
  };
}

function normalizeEgyptPhone(raw: string): string {
  const digits = digitsOnly(raw);
  if (digits.startsWith("20") && digits.length === 12) return `+${digits}`;
  if (digits.startsWith("0") && digits.length === 11) {
    return `+20${digits.slice(1)}`;
  }
  return digits.startsWith("+") ? digits : `+${digits}`;
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return corsJson({ error: "method not allowed" }, 405);
  }

  const authHeader = req.headers.get("Authorization") ?? "";
  const token = authHeader.startsWith("Bearer ")
    ? authHeader.slice("Bearer ".length)
    : "";
  if (!token) {
    return corsJson({ error: "Please sign in to pay by card." }, 401);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  if (!supabaseUrl || !serviceKey) {
    console.error("paymob-create-intention: missing Supabase environment");
    return corsJson({ error: "Card payments are not configured yet." }, 503);
  }

  const admin = createClient(supabaseUrl, serviceKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });

  const {
    data: { user },
    error: userError,
  } = await admin.auth.getUser(token);
  if (userError || !user) {
    return corsJson({ error: "Please sign in again to pay by card." }, 401);
  }

  let body: unknown;
  try {
    body = await req.json();
  } catch (_) {
    return corsJson({ error: "A valid request body is required." }, 400);
  }

  const orderId = body !== null && typeof body === "object"
    ? (body as Record<string, unknown>).order_id
    : undefined;
  if (!isUuid(orderId)) {
    return corsJson({ error: "A valid order id is required." }, 400);
  }

  // --------------------------------------------------------------------------
  // Configuration (fail closed; never reveal which secret is missing)
  // --------------------------------------------------------------------------
  let secretKey: string;
  let publicKey: string;
  let integrationId: number;
  let baseUrl: string;
  let notificationUrl: string;
  let redirectionUrl: string | undefined;
  try {
    secretKey = requireEnv("PAYMOB_SECRET_KEY");
    publicKey = requireEnv("PAYMOB_PUBLIC_KEY");
    requireEnv("PAYMOB_HMAC_SECRET");
    const rawIntegrationId = requireEnv("PAYMOB_CARD_INTEGRATION_ID");
    integrationId = Number(rawIntegrationId);
    if (!Number.isInteger(integrationId) || integrationId <= 0) {
      throw new Error("PAYMOB_CARD_INTEGRATION_ID must be a positive integer");
    }

    baseUrl = optionalEnv("PAYMOB_BASE_URL") ?? "https://accept.paymob.com";
    assertHttpsUrl(baseUrl, "PAYMOB_BASE_URL");
    notificationUrl = optionalEnv("PAYMOB_NOTIFICATION_URL") ??
      `${supabaseUrl}/functions/v1/paymob-webhook`;
    assertHttpsUrl(notificationUrl, "PAYMOB_NOTIFICATION_URL");
    redirectionUrl = optionalEnv("PAYMOB_REDIRECTION_URL");
    if (redirectionUrl) {
      assertHttpsUrl(redirectionUrl, "PAYMOB_REDIRECTION_URL");
    }
  } catch (error) {
    console.error(
      "paymob-create-intention: configuration error",
      error instanceof Error ? error.message : "unknown",
    );
    return corsJson({ error: "Card payments are not configured yet." }, 503);
  }

  // --------------------------------------------------------------------------
  // Atomic server-side eligibility check + attempt claim
  // --------------------------------------------------------------------------
  const { data: attemptData, error: attemptError } = await admin.rpc(
    "begin_paymob_attempt",
    { p_order_id: orderId, p_user_id: user.id },
  );
  if (attemptError) {
    const mapped = mapRpcError(attemptError.message ?? "");
    if (mapped.status >= 500) {
      console.error(
        "paymob-create-intention: begin_paymob_attempt failed",
        attemptError.code,
        attemptError.message,
      );
    }
    return corsJson({ error: mapped.error }, mapped.status);
  }

  const attempt = attemptData as Record<string, unknown> | null;
  const attemptId = asString(attempt?.attempt_id);
  const amountCents = asInt(attempt?.amount_cents);
  const currency = asString(attempt?.currency) ?? "EGP";
  const existingCheckoutUrl = asString(attempt?.checkout_url);
  if (!attemptId || amountCents === null || amountCents <= 0) {
    console.error("paymob-create-intention: invalid attempt payload");
    return corsJson(
      { error: "Could not start the card payment. Please try again." },
      500,
    );
  }

  if (existingCheckoutUrl) {
    return corsJson(
      {
        attempt_id: attemptId,
        order_id: orderId,
        checkout_url: existingCheckoutUrl,
        amount_cents: amountCents,
        currency,
        status: "pending",
        reused: true,
      },
      200,
    );
  }

  // Use ONLY for a definite local validation failure or a Paymob 4xx
  // rejection. A timeout, 5xx, parse error or lost response means Paymob may
  // have created a chargeable intention, so it must be quarantined instead.
  const failAttempt = async (reason: string) => {
    const { error } = await admin.rpc("fail_paymob_attempt", {
      p_attempt_id: attemptId,
      p_user_id: user.id,
      p_reason: reason,
    });
    if (error) {
      console.error(
        "paymob-create-intention: fail_paymob_attempt failed",
        error.code,
      );
    }
  };

  // The Paymob outcome is ambiguous. Block any new intention for this order
  // until a verified callback or an operator reconciliation resolves it.
  const markAttemptUnknown = async (reason: string) => {
    const { error } = await admin.rpc("mark_paymob_attempt_unknown", {
      p_attempt_id: attemptId,
      p_user_id: user.id,
      p_reason: reason,
    });
    if (error) {
      console.error(
        "paymob-create-intention: mark_paymob_attempt_unknown failed",
        error.code,
      );
    }
  };

  // --------------------------------------------------------------------------
  // Billing data comes from the order + profile, never from the request body
  // --------------------------------------------------------------------------
  const { data: orderData, error: orderError } = await admin
    .from("orders")
    .select(
      "id, order_code, user_id, status, payment_method, payment_status, total, delivery_address",
    )
    .eq("id", orderId)
    .maybeSingle();

  if (orderError || !orderData) {
    console.error(
      "paymob-create-intention: order lookup failed",
      orderError?.code ?? "not_found",
    );
    await failAttempt("Order lookup failed");
    return corsJson({ error: "This order is not available." }, 404);
  }

  const order = orderData as OrderRow;
  if (order.user_id !== user.id) {
    await failAttempt("Order ownership changed");
    return corsJson({ error: "This order is not available." }, 403);
  }

  const { data: profileData, error: profileError } = await admin
    .from("profiles")
    .select("username, phone, address")
    .eq("id", user.id)
    .maybeSingle();

  if (profileError) {
    console.error(
      "paymob-create-intention: profile lookup failed",
      profileError.code,
    );
  }

  const profile = (profileData ?? {}) as ProfileRow;
  const email = user.email?.trim();
  const phone = normalizeEgyptPhone(profile.phone ?? user.phone ?? "");
  const street = (order.delivery_address ?? profile.address ?? "").trim();
  const { firstName, lastName } = splitName(
    profile.username ?? (user.user_metadata?.full_name as string | undefined) ??
      null,
  );

  if (!email) {
    await failAttempt("Customer has no email for billing data");
    return corsJson(
      {
        error: "Add an email address to your account before paying by card.",
      },
      400,
    );
  }
  if (phone.replace(/\D/g, "").length < 8) {
    await failAttempt("Customer has no valid phone for billing data");
    return corsJson(
      {
        error: "Add a phone number to your profile before paying by card.",
      },
      400,
    );
  }
  if (!street) {
    await failAttempt("Customer has no delivery address for billing data");
    return corsJson(
      {
        error: "Add a delivery address before paying by card.",
      },
      400,
    );
  }

  const billingData = {
    first_name: firstName,
    last_name: lastName,
    email,
    phone_number: phone,
    street: street.slice(0, 200),
    building: "NA",
    floor: "NA",
    apartment: "NA",
    city: "Cairo",
    state: "Cairo",
    country: "EG",
    postal_code: "00000",
  };

  const intentionPayload: Record<string, unknown> = {
    amount: amountCents,
    currency,
    payment_methods: [integrationId],
    items: [
      {
        name: `Orchid order ${order.order_code ?? order.id}`,
        amount: amountCents,
        description: "Flowers and delivery",
        quantity: 1,
      },
    ],
    billing_data: billingData,
    customer: {
      first_name: firstName,
      last_name: lastName,
      email,
      phone_number: phone,
    },
    special_reference: attemptId,
    // Paymob documents that the checkout client secret expires in one hour.
    // Keep this slightly below the database's expiry guard.
    expiration: 3300,
    notification_url: notificationUrl,
    extras: {
      order_id: order.id,
      order_code: order.order_code,
    },
  };
  if (redirectionUrl) {
    intentionPayload.redirection_url = redirectionUrl;
  }

  // --------------------------------------------------------------------------
  // Paymob Intention API
  // --------------------------------------------------------------------------
  const intentionUrl = new URL(
    "v1/intention/",
    baseUrl.endsWith("/") ? baseUrl : `${baseUrl}/`,
  );

  let paymobResponse: Response;
  try {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 20_000);
    try {
      paymobResponse = await fetch(intentionUrl, {
        method: "POST",
        headers: {
          Authorization: `Token ${secretKey}`,
          "Content-Type": "application/json",
          Accept: "application/json",
        },
        body: JSON.stringify(intentionPayload),
        signal: controller.signal,
      });
    } finally {
      clearTimeout(timeout);
    }
  } catch (error) {
    console.error(
      "paymob-create-intention: Paymob request failed",
      error instanceof Error ? error.name : "unknown",
    );
    await markAttemptUnknown("Could not confirm the Paymob response");
    return corsJson(
      {
        error:
          "We could not confirm whether Paymob started the payment. Check this order in your history before trying again.",
      },
      502,
    );
  }

  if (!paymobResponse.ok) {
    console.error(
      "paymob-create-intention: Paymob rejected the intention",
      paymobResponse.status,
    );

    const status = paymobResponse.status;
    const definitelyRejected =
      status >= 400 &&
      status < 500 &&
      status !== 408 &&
      status !== 425 &&
      status !== 429;

    if (definitelyRejected) {
      await failAttempt(`Paymob rejected the intention (${status})`);
      return corsJson(
        { error: "Paymob could not start the payment. Please try again." },
        502,
      );
    }

    // Timeouts, throttling and server errors are ambiguous: Paymob may have
    // created the intention before the response was lost.
    await markAttemptUnknown(`Paymob response was uncertain (${status})`);
    return corsJson(
      {
        error:
          "We could not confirm whether Paymob started the payment. Check this order in your history before trying again.",
      },
      502,
    );
  }

  let intention: IntentionResponse;
  try {
    intention = (await paymobResponse.json()) as IntentionResponse;
  } catch (_) {
    await markAttemptUnknown("Paymob returned an unreadable response");
    return corsJson(
      {
        error:
          "We could not confirm whether Paymob started the payment. Check this order in your history before trying again.",
      },
      502,
    );
  }

  const intentionId = asString(intention.id);
  const clientSecret = asString(intention.client_secret);
  const paymobOrderId = asString(intention.intention_order_id);
  if (!intentionId || !clientSecret || !paymobOrderId) {
    console.error("paymob-create-intention: incomplete Paymob response");
    await markAttemptUnknown("Paymob returned an incomplete response");
    return corsJson(
      {
        error:
          "We could not confirm whether Paymob started the payment. Check this order in your history before trying again.",
      },
      502,
    );
  }

  let checkoutUrl: string;
  try {
    checkoutUrl = buildUnifiedCheckoutUrl(baseUrl, publicKey, clientSecret);
  } catch (_) {
    await markAttemptUnknown("Could not build the Paymob checkout URL");
    return corsJson(
      {
        error:
          "We could not confirm whether Paymob started the payment. Check this order in your history before trying again.",
      },
      500,
    );
  }

  const { data: attached, error: attachError } = await admin.rpc(
    "attach_paymob_intention",
    {
      p_attempt_id: attemptId,
      p_user_id: user.id,
      p_intention_id: intentionId,
      p_paymob_order_id: paymobOrderId,
      p_checkout_url: checkoutUrl,
    },
  );

  if (attachError || !attached) {
    if (attachError?.message?.includes("order is no longer payable")) {
      return corsJson(
        { error: "This order can no longer be paid online." },
        409,
      );
    }
    console.error(
      "paymob-create-intention: attach_paymob_intention failed",
      attachError?.code ?? "empty",
    );
    // The intention exists at Paymob even though it could not be persisted
    // locally, so this is uncertain, not a safe failure.
    await markAttemptUnknown("Could not save the Paymob checkout");
    return corsJson(
      {
        error:
          "We could not confirm whether Paymob started the payment. Check this order in your history before trying again.",
      },
      500,
    );
  }

  console.log(
    "paymob-create-intention: ready",
    `attempt=${attemptId}`,
    `order=${orderId}`,
  );

  // Minimal checkout data. No secret key, HMAC secret, API key, or raw Paymob
  // response is returned.
  return corsJson(
    {
      attempt_id: attemptId,
      order_id: orderId,
      checkout_url: checkoutUrl,
      amount_cents: amountCents,
      currency,
      status: "pending",
      reused: false,
    },
    200,
  );
});

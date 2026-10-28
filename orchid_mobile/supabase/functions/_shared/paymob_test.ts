import {
  assertEquals,
  assertFalse,
  assertThrows,
} from "jsr:@std/assert@1";

import {
  asInt,
  assertHttpsUrl,
  buildHmacPayload,
  buildUnifiedCheckoutUrl,
  computeHmacSha512,
  constantTimeEqual,
  type PaymobTransaction,
  readCallbackBody,
  requireEnv,
  splitName,
  verifyPaymobHmac,
} from "./paymob.ts";

// Frozen sample with all 20 signed fields in Paymob's documented order.
const transaction: PaymobTransaction = {
  amount_cents: 12500,
  created_at: "2026-10-28T10:00:00.000000",
  currency: "EGP",
  error_occured: false,
  has_parent_transaction: false,
  id: 987654,
  integration_id: 123456,
  is_3d_secure: true,
  is_auth: false,
  is_capture: false,
  is_refunded: false,
  is_standalone_payment: true,
  is_voided: false,
  order: { id: 456789, merchant_order_id: "attempt-1" },
  owner: 42,
  pending: false,
  source_data: {
    pan: "512345",
    sub_type: "MasterCard",
    type: "card",
  },
  success: true,
};

const payload =
  "125002026-10-28T10:00:00.000000EGPfalsefalse987654123456truefalsefalsefalsetruefalse45678942false512345MasterCardcardtrue";
const secret = "test_hmac_secret";
const expectedHmac =
  "aa143f828a984bdb472734dd7771f9b1503b904d8922f22535475885c049ef7ab54f38119d2cf0ea821cafc2be335b2b92c03e1f68930a842f047783143accd7";

Deno.test("buildHmacPayload follows the exact 20-field order", () => {
  assertEquals(buildHmacPayload(transaction), payload);
});

Deno.test("computeHmacSha512 matches the frozen SHA-512 vector", async () => {
  assertEquals(await computeHmacSha512(payload, secret), expectedHmac);
});

Deno.test("verifyPaymobHmac accepts only the matching signature", async () => {
  assertEquals(await verifyPaymobHmac(transaction, expectedHmac, secret), true);
  assertEquals(
    await verifyPaymobHmac(transaction, expectedHmac.toUpperCase(), secret),
    true,
  );
  assertFalse(await verifyPaymobHmac(transaction, expectedHmac, "wrong"));
  assertFalse(await verifyPaymobHmac(transaction, "", secret));
});

Deno.test("constantTimeEqual compares equal-length strings", () => {
  assertEquals(constantTimeEqual("abcd", "abcd"), true);
  assertFalse(constantTimeEqual("abcd", "abce"));
  assertFalse(constantTimeEqual("abcd", "abcde"));
});

Deno.test("readCallbackBody accepts JSON and form-encoded callbacks", async () => {
  const jsonRequest = new Request("https://example.test/webhook", {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ type: "TRANSACTION", obj: transaction }),
  });
  const jsonBody = await readCallbackBody(jsonRequest);
  assertEquals(jsonBody.type, "TRANSACTION");
  assertEquals(jsonBody.obj?.id, 987654);

  const form = new URLSearchParams();
  form.set("type", "TRANSACTION");
  form.set("obj", JSON.stringify(transaction));
  const formRequest = new Request("https://example.test/webhook", {
    method: "POST",
    headers: { "content-type": "application/x-www-form-urlencoded" },
    body: form,
  });
  const formBody = await readCallbackBody(formRequest);
  assertEquals(formBody.type, "TRANSACTION");
  assertEquals(formBody.obj?.success, true);
});

Deno.test("buildUnifiedCheckoutUrl keeps the public key and client secret", () => {
  const url = new URL(
    buildUnifiedCheckoutUrl(
      "https://accept.paymob.com",
      "pk_test",
      "cs_test",
    ),
  );
  assertEquals(url.pathname, "/unifiedcheckout/");
  assertEquals(url.searchParams.get("publicKey"), "pk_test");
  assertEquals(url.searchParams.get("clientSecret"), "cs_test");
});

Deno.test("splitName provides Paymob billing fallbacks", () => {
  assertEquals(splitName("Mahmoud Ali"), {
    firstName: "Mahmoud",
    lastName: "Ali",
  });
  assertEquals(splitName("Mahmoud"), {
    firstName: "Mahmoud",
    lastName: "Customer",
  });
  assertEquals(splitName(null), {
    firstName: "Orchid",
    lastName: "Customer",
  });
});

Deno.test("verifyPaymobHmac rejects a tampered signed field", async () => {
  assertFalse(
    await verifyPaymobHmac(
      { ...transaction, amount_cents: 1 },
      expectedHmac,
      secret,
    ),
  );
});

Deno.test("requireEnv fails closed for missing and blank values", () => {
  try {
    Deno.env.delete("ORCHID_TEST_MISSING_ENV");
    let message = "";
    try {
      requireEnv("ORCHID_TEST_MISSING_ENV");
    } catch (error) {
      message = error instanceof Error ? error.message : "";
    }
    assertEquals(message.includes("missing environment variable"), true);

    Deno.env.set("ORCHID_TEST_BLANK_ENV", "   ");
    message = "";
    try {
      requireEnv("ORCHID_TEST_BLANK_ENV");
    } catch (error) {
      message = error instanceof Error ? error.message : "";
    }
    assertEquals(message.includes("missing environment variable"), true);
  } finally {
    Deno.env.delete("ORCHID_TEST_MISSING_ENV");
    Deno.env.delete("ORCHID_TEST_BLANK_ENV");
  }
});

Deno.test("assertHttpsUrl rejects non-https and malformed URLs", () => {
  assertThrows(
    () => assertHttpsUrl("http://accept.paymob.com", "PAYMOB_BASE_URL"),
    Error,
    "must use https",
  );
  assertThrows(
    () => assertHttpsUrl("not a url", "PAYMOB_BASE_URL"),
    Error,
    "not a valid URL",
  );
  assertEquals(
    assertHttpsUrl("https://accept.paymob.com", "PAYMOB_BASE_URL").host,
    "accept.paymob.com",
  );
});

Deno.test("asInt rejects missing and non-numeric amounts", () => {
  assertEquals(asInt("12500"), 12500);
  assertEquals(asInt(12500.9), 12500);
  assertEquals(asInt(""), null);
  assertEquals(asInt("abc"), null);
  assertEquals(asInt(null), null);
});

Deno.test("readCallbackBody rejects unsupported content types", async () => {
  const request = new Request("https://example.test/webhook", {
    method: "POST",
    headers: { "content-type": "text/plain" },
    body: "{}",
  });
  let failed = false;
  try {
    await readCallbackBody(request);
  } catch (_) {
    failed = true;
  }
  assertEquals(failed, true);
});

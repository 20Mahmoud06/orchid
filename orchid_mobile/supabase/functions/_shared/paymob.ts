// Shared Paymob helpers used by the intention-creation and webhook functions.
//
// Only public information ever leaves the server. The secret key, HMAC secret,
// and API key are read from the function environment and are never returned,
// logged, or persisted in the database.

export const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

export type JsonBody = Record<string, unknown>;

export function json(
  body: JsonBody,
  status: number,
  headers: Record<string, string> = {},
): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json", ...headers },
  });
}

export function corsJson(body: JsonBody, status: number): Response {
  return json(body, status, corsHeaders);
}

export function requireEnv(name: string): string {
  const value = Deno.env.get(name)?.trim();
  if (!value) {
    throw new Error(`missing environment variable: ${name}`);
  }
  return value;
}

export function optionalEnv(name: string): string | undefined {
  const value = Deno.env.get(name)?.trim();
  return value ? value : undefined;
}

/**
 * Paymob's documented POST-callback HMAC field order. The misspelling
 * `error_occured` is intentional: it is the field name Paymob sends.
 */
export const PAYMOB_HMAC_FIELDS = [
  "amount_cents",
  "created_at",
  "currency",
  "error_occured",
  "has_parent_transaction",
  "id",
  "integration_id",
  "is_3d_secure",
  "is_auth",
  "is_capture",
  "is_refunded",
  "is_standalone_payment",
  "is_voided",
  "order.id",
  "owner",
  "pending",
  "source_data.pan",
  "source_data.sub_type",
  "source_data.type",
  "success",
] as const;

export interface PaymobTransaction {
  amount_cents?: number | string;
  created_at?: string;
  currency?: string;
  error_occured?: boolean;
  has_parent_transaction?: boolean;
  id?: number | string;
  integration_id?: number | string;
  is_3d_secure?: boolean;
  is_auth?: boolean;
  is_capture?: boolean;
  is_refunded?: boolean;
  is_standalone_payment?: boolean;
  is_voided?: boolean;
  order?: {
    id?: number | string;
    merchant_order_id?: string | null;
  };
  owner?: number | string;
  pending?: boolean;
  source_data?: {
    pan?: string;
    sub_type?: string;
    type?: string;
  };
  success?: boolean;
}

export interface PaymobCallbackBody {
  type?: string;
  obj?: PaymobTransaction;
}

function readPath(source: unknown, path: string): unknown {
  let current: unknown = source;
  for (const part of path.split(".")) {
    if (current === null || typeof current !== "object") {
      return undefined;
    }
    current = (current as Record<string, unknown>)[part];
  }
  return current;
}

function hmacValue(value: unknown): string {
  if (value === null || value === undefined) return "";
  return String(value);
}

/**
 * Builds the exact concatenated string Paymob signs. Exported so it can be
 * unit-tested with a frozen callback payload.
 */
export function buildHmacPayload(obj: PaymobTransaction): string {
  return PAYMOB_HMAC_FIELDS.map((field) => hmacValue(readPath(obj, field)))
    .join("");
}

export async function computeHmacSha512(
  payload: string,
  secret: string,
): Promise<string> {
  const encoder = new TextEncoder();
  const key = await crypto.subtle.importKey(
    "raw",
    encoder.encode(secret),
    { name: "HMAC", hash: "SHA-512" },
    false,
    ["sign"],
  );
  const signature = await crypto.subtle.sign(
    "HMAC",
    key,
    encoder.encode(payload),
  );
  return Array.from(new Uint8Array(signature))
    .map((byte) => byte.toString(16).padStart(2, "0"))
    .join("");
}

/** Length-independent comparison for attacker-controlled hex strings. */
export function constantTimeEqual(left: string, right: string): boolean {
  const a = left.toLowerCase();
  const b = right.toLowerCase();
  if (a.length !== b.length) return false;
  let diff = 0;
  for (let index = 0; index < a.length; index += 1) {
    diff |= a.charCodeAt(index) ^ b.charCodeAt(index);
  }
  return diff === 0;
}

export async function verifyPaymobHmac(
  obj: PaymobTransaction,
  receivedHmac: string,
  secret: string,
): Promise<boolean> {
  if (!receivedHmac) return false;
  const expected = await computeHmacSha512(buildHmacPayload(obj), secret);
  return constantTimeEqual(expected, receivedHmac);
}

/**
 * Paymob POSTs JSON, but some accounts send form-urlencoded bodies with the
 * transaction under an `obj` field. Support both without trusting either
 * beyond the HMAC check.
 */
export async function readCallbackBody(
  req: Request,
): Promise<PaymobCallbackBody> {
  const contentType = (req.headers.get("content-type") ?? "").toLowerCase();

  if (contentType.includes("application/json")) {
    const parsed: unknown = await req.json();
    if (parsed === null || typeof parsed !== "object") {
      throw new Error("invalid callback body");
    }
    return parsed as PaymobCallbackBody;
  }

  if (
    contentType.includes("application/x-www-form-urlencoded") ||
    contentType.includes("multipart/form-data")
  ) {
    const form = await req.formData();
    const raw = form.get("obj");
    if (typeof raw !== "string") {
      throw new Error("missing obj field");
    }
    const parsed: unknown = JSON.parse(raw);
    if (parsed === null || typeof parsed !== "object") {
      throw new Error("invalid obj field");
    }
    return {
      type: typeof form.get("type") === "string"
        ? String(form.get("type"))
        : undefined,
      obj: parsed as PaymobTransaction,
    };
  }

  throw new Error("unsupported callback content type");
}

export function asString(value: unknown): string | null {
  if (value === null || value === undefined) return null;
  const text = String(value).trim();
  return text.length > 0 ? text : null;
}

export function asInt(value: unknown): number | null {
  if (value === null || value === undefined || value === "") return null;
  const parsed = Number(value);
  return Number.isFinite(parsed) ? Math.trunc(parsed) : null;
}

export function splitName(username: string | null): {
  firstName: string;
  lastName: string;
} {
  const parts = (username ?? "").trim().split(/\s+/).filter(Boolean);
  if (parts.length === 0) {
    return { firstName: "Orchid", lastName: "Customer" };
  }
  if (parts.length === 1) {
    return { firstName: parts[0], lastName: "Customer" };
  }
  return {
    firstName: parts[0],
    lastName: parts.slice(1).join(" "),
  };
}

export function digitsOnly(value: string | null): string {
  return (value ?? "").replace(/\D/g, "");
}

export function buildUnifiedCheckoutUrl(
  baseUrl: string,
  publicKey: string,
  clientSecret: string,
): string {
  const normalizedBase = baseUrl.endsWith("/") ? baseUrl : `${baseUrl}/`;
  const url = new URL("unifiedcheckout/", normalizedBase);
  url.searchParams.set("publicKey", publicKey);
  url.searchParams.set("clientSecret", clientSecret);
  return url.toString();
}

export function assertHttpsUrl(value: string, label: string): URL {
  let url: URL;
  try {
    url = new URL(value);
  } catch (_) {
    throw new Error(`${label} is not a valid URL`);
  }
  if (url.protocol !== "https:") {
    throw new Error(`${label} must use https`);
  }
  return url;
}

export function isUuid(value: unknown): value is string {
  return typeof value === "string" &&
    /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/
      .test(value);
}

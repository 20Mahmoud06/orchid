// Checks whether an auth account exists for a given email address.
//
// The Flutter app calls this from the login and forgot-password screens, which
// are unauthenticated, so the function must be deployed without JWT
// verification:
//
//   supabase functions deploy check-email --no-verify-jwt
//
// The service role key is read from the function environment and never leaves
// the server. Only a boolean is returned — no account details are exposed.

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

const json = (body: Record<string, unknown>, status: number): Response =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { email } = await req.json().catch(() => ({ email: undefined }))
    if (typeof email !== 'string' || !email.includes('@')) {
      return json({ error: 'a valid email is required' }, 400)
    }

    const target = email.trim().toLowerCase()
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
    const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''

    // The Auth Admin API supports a `filter` query param that matches against
    // email/phone/name. Confirm the exact (case-insensitive) match ourselves so
    // a partial match is never reported as an existing account.
    const url = new URL(`${supabaseUrl}/auth/v1/admin/users`)
    url.searchParams.set('page', '1')
    url.searchParams.set('per_page', '1000')
    url.searchParams.set('filter', target)

    const response = await fetch(url, {
      headers: {
        apikey: serviceKey,
        Authorization: `Bearer ${serviceKey}`,
      },
    })

    if (!response.ok) {
      return json({ error: 'unable to check email' }, 502)
    }

    const payload = (await response.json()) as {
      users?: Array<{ email?: string }>
    }
    const users = Array.isArray(payload.users) ? payload.users : []
    const exists = users.some(
      (user) => (user.email ?? '').toLowerCase() === target,
    )

    return json({ exists }, 200)
  } catch (error) {
    const message = error instanceof Error ? error.message : 'unknown error'
    return json({ error: message }, 500)
  }
})

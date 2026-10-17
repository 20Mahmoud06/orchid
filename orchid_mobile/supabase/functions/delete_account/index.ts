import { createClient } from 'jsr:@supabase/supabase-js@2'

const json = (body: Record<string, unknown>, status: number): Response =>
  new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json' },
  })

// Deletes the currently signed-in user's account.
//
// The Flutter client calls this function with the user's access token in the
// `Authorization` header. The JWT is verified server-side so a user can only
// ever delete their own account — the service role key stays on the server.
Deno.serve(async (req: Request) => {
  try {
    const authHeader = req.headers.get('Authorization') ?? ''
    const token = authHeader.startsWith('Bearer ')
      ? authHeader.slice('Bearer '.length)
      : ''

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
      {
        auth: {
          autoRefreshToken: false,
          persistSession: false,
        },
      },
    )

    const {
      data: { user },
      error: userError,
    } = await supabase.auth.getUser(token)
    if (userError || !user) {
      return json(
        { error: userError?.message ?? 'invalid user' },
        401,
      )
    }

    // Supabase refuses to delete an auth user who owns Storage objects, so
    // remove the user's uploaded profile image first.
    const { data: files, error: listError } = await supabase.storage
      .from('profile-images')
      .list(user.id, { limit: 100 })
    if (listError) {
      return json(
        { error: `failed to list user files: ${listError.message}` },
        500,
      )
    }

    const paths = (files ?? []).map((file) => `${user.id}/${file.name}`)
    if (paths.length > 0) {
      const { error: removeError } = await supabase.storage
        .from('profile-images')
        .remove(paths)
      if (removeError) {
        return json(
          { error: `failed to remove user files: ${removeError.message}` },
          500,
        )
      }
    }

    const { error: deleteError } = await supabase.auth.admin.deleteUser(
      user.id,
    )
    if (deleteError) {
      return json({ error: deleteError.message }, 500)
    }

    return json({ message: `user ${user.id} deleted` }, 200)
  } catch (error) {
    const message =
      error instanceof Error ? error.message : 'unknown error'
    return json({ error: message }, 500)
  }
})
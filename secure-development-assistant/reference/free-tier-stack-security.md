# Free-Tier Stack Security Guide

Specific guidance for the common stack: **Firebase (Auth/Firestore), Cloudflare
(R2/D1/Workers), Vercel, Razorpay/Stripe, Next.js**. General principles from
SKILL.md still apply — this file adds the concrete, provider-specific detail.

---

## Firebase

**Firestore Security Rules — write real rules, don't rely on client checks**
```
// Example: users can only read/write their own document
match /users/{userId} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}

// Example: subscription status is only ever written by a trusted Cloud Function,
// never directly by the client — the client can read it, never write it.
match /subscriptions/{userId} {
  allow read: if request.auth != null && request.auth.uid == userId;
  allow write: if false; // only Cloud Functions (admin SDK) write here
}
```
- Firebase Auth tokens are verified server-side (Cloud Functions / your backend)
  using the Admin SDK before trusting `request.auth.uid` in any privileged logic.
- Never put a Firebase **service account key** (the JSON admin credential) in a
  frontend bundle or client-side code — it belongs only in server
  environments/Cloud Functions config.
- Enable App Check if available for your plan, to reduce abuse from non-app clients.

## Cloudflare (R2 / D1 / Workers)

- **R2 buckets**: default to private; generate short-lived signed URLs
  (presigned) for any user-specific download rather than making a bucket public.
- **D1 (SQLite)**: always use parameterized queries via the D1 client — never
  string-concatenate user input into SQL, even though it "feels" like a small
  embedded DB.
- **Workers secrets**: store API keys/DB credentials with `wrangler secret put`,
  never in `wrangler.toml` committed to git, never in client-side Worker code
  that ships to the browser (Workers can run both server-only and
  client-exposed code depending on setup — double check which is which).
- **CORS on Workers/R2**: restrict `Access-Control-Allow-Origin` to your actual
  frontend domain(s) in production, not `*`, especially for any endpoint that
  requires auth.

## Vercel

- Set secrets via **Vercel Environment Variables** (scoped per environment:
  Production/Preview/Development) — never hardcode, never prefix with
  `NEXT_PUBLIC_` unless the value is genuinely meant to be public (that
  prefix ships it straight into the browser bundle).
- Double-check every `NEXT_PUBLIC_*` variable in the codebase — this is the
  most common place a secret accidentally leaks into client JS.
- API routes / Route Handlers under `app/api/*` or `pages/api/*` run
  server-side — this is where auth checks, entitlement checks, and provider
  secret keys belong; never replicate that logic in a client component.

## Razorpay / Stripe (payments)

- Verify webhook signatures server-side before trusting any payload (see
  `secure-coding-patterns.md` §6) — this is the #1 place SaaS billing gets
  bypassed when skipped "to save time".
- Keep the secret key (`rzp_live_secret_...` / `sk_live_...`) server-only;
  only the publishable/key-id (`rzp_live_key_id` / `pk_live_...`) is safe for
  the frontend.
- Use the provider's own hosted checkout/payment element where possible so
  raw card data never touches your servers (keeps PCI scope minimal).
- Store your own copy of subscription/order status (updated only via
  verified webhook) — don't make every entitlement check call out live to
  the provider API on every request; that's slow and still needs the same
  "don't trust the client" rule underneath.

## Next.js general

- Server Components / Server Actions: still validate and re-check
  authorization inside them — being "server-side" doesn't automatically mean
  "already checked who's calling it".
- Middleware-based auth checks are a good first layer but pair them with
  checks inside the actual route handler/Server Action — middleware can be
  misconfigured to not match every path you think it does.
- Sanitize any user-generated content rendered with `dangerouslySetInnerHTML`
  or similar — Next.js's default JSX escaping protects most output, but this
  explicit escape hatch removes that protection.

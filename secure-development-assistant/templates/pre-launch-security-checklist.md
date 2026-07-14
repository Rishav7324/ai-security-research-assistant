# Pre-Launch Security Checklist

Run through this before shipping any new feature or launching a product.
Check items off honestly — an unchecked item is a known gap, not a failure;
decide consciously whether to fix it now or track it for right after launch.

## Authentication & Passwords
- [ ] Passwords hashed with Argon2id or bcrypt (cost >= 12) — never MD5/SHA1/plain
- [ ] Password reset tokens are single-use, short-lived, high-entropy
- [ ] Login/reset endpoints are rate-limited per account and per IP
- [ ] Generic error messages on auth failure (no user-enumeration leak)
- [ ] MFA available for admin/sensitive accounts

## Sessions & Tokens
- [ ] Cookies set with `Secure`, `HttpOnly`, `SameSite`
- [ ] Tokens not stored in `localStorage`/`sessionStorage` if avoidable
- [ ] Sessions/refresh tokens invalidated on logout and password change
- [ ] JWT algorithm pinned server-side; `alg: none` rejected; `exp`/`aud`/`iss` checked

## API & Authorization
- [ ] Every endpoint has an explicit auth requirement (nothing "assumed public")
- [ ] Object-level ownership checked server-side on every request (no IDOR/BOLA)
- [ ] No privileged secret keys present in any frontend bundle (grep for API keys/tokens)
- [ ] CORS restricted to real frontend origin(s) in production, not `*`
- [ ] Input validated server-side even where the frontend also validates

## Billing / Subscription / Payment
- [ ] Webhook signature verification implemented and tested (with an invalid signature test)
- [ ] Webhook handler is idempotent (duplicate event ID doesn't double-grant)
- [ ] Entitlement checks read current stored plan server-side, not a client-sent flag
- [ ] Prices/discounts computed server-side from stored data, never from client input
- [ ] Coupon/discount redemption uses an atomic conditional update (race-safe)

## File Uploads (if applicable)
- [ ] File type validated by content, not just extension/Content-Type header
- [ ] Max size enforced server-side
- [ ] Uploaded filenames are server-generated, not the client-supplied name
- [ ] Uploads stored with no execute permission / served via signed URLs

## Multi-Tenant Data (if applicable)
- [ ] Every tenant-scoped query includes the tenant/user ID in the query itself
- [ ] Database-level rules (RLS / Firestore rules) present as a second layer
- [ ] No client-supplied tenant/user ID accepted on writes

## Secrets & Environment
- [ ] `.env`/secret files in `.gitignore`; `.env.example` has names only
- [ ] Secrets scoped per environment (dev/staging/prod separate)
- [ ] No secret has ever been pasted in chat/ticket/screen-share without rotation after

## Infra / Config
- [ ] Debug mode off, verbose error pages off, in production
- [ ] Security headers present (CSP, HSTS, X-Content-Type-Options, etc.)
- [ ] Dependencies checked for known-vulnerable versions before launch
- [ ] Cloud storage buckets default-private; IAM/roles scoped to least privilege

## Mobile (if applicable)
- [ ] No API keys/secrets hardcoded in app source
- [ ] Sensitive local data stored via EncryptedSharedPreferences / Keystore
- [ ] Release build uses code obfuscation (R8/ProGuard)

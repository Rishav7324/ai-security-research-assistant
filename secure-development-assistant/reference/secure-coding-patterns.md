# Secure Coding Patterns

Illustrative, defensive code patterns referenced by SKILL.md Sections 3-6.
These are secure-by-default *starting points* — adapt to your actual stack,
but never remove the core protection each pattern provides.

---

## 1. Password Hashing (Node.js example, Argon2id)

```javascript
// npm install argon2
const argon2 = require('argon2');

async function hashPassword(plainPassword) {
  // argon2id is the recommended variant; library handles salt generation.
  return argon2.hash(plainPassword, { type: argon2.argon2id });
}

async function verifyPassword(hash, plainPassword) {
  return argon2.verify(hash, plainPassword);
}

// Never do this:
// const hash = crypto.createHash('md5').update(password).digest('hex'); // NEVER
```

If bcrypt is your stack's standard instead:

```javascript
// npm install bcrypt
const bcrypt = require('bcrypt');
const SALT_ROUNDS = 12; // minimum recommended cost factor

async function hashPassword(plainPassword) {
  return bcrypt.hash(plainPassword, SALT_ROUNDS);
}

async function verifyPassword(hash, plainPassword) {
  return bcrypt.compare(plainPassword, hash);
}
```

## 2. Password Reset Token (single-use, short-lived)

```javascript
const crypto = require('crypto');

function generateResetToken() {
  return crypto.randomBytes(32).toString('hex'); // 256 bits of entropy
}

// When issuing:
// store: { userId, tokenHash: sha256(token), expiresAt: now + 30min, used: false }
// Send the raw token to the user, store only its hash.

async function consumeResetToken(rawToken) {
  const tokenHash = crypto.createHash('sha256').update(rawToken).digest('hex');
  const record = await db.resetTokens.findOne({ tokenHash, used: false });
  if (!record || record.expiresAt < Date.now()) {
    throw new Error('Invalid or expired token'); // generic message
  }
  await db.resetTokens.update({ id: record.id }, { used: true }); // single-use
  return record.userId;
}
```

---

## 3. Session Cookie Configuration (Express example)

```javascript
app.use(session({
  cookie: {
    secure: true,       // only sent over HTTPS
    httpOnly: true,     // not readable by JavaScript (mitigates XSS token theft)
    sameSite: 'lax',    // CSRF mitigation; use 'strict' for highly sensitive apps
    maxAge: 15 * 60 * 1000 // short-lived; refresh as needed
  },
  // ...store config (Redis/DB-backed store, not default MemoryStore in production)
}));
```

## 4. JWT Verification (pin algorithm, check claims)

```javascript
const jwt = require('jsonwebtoken');

function verifyAccessToken(token) {
  return jwt.verify(token, process.env.JWT_PUBLIC_KEY, {
    algorithms: ['RS256'],       // pin exactly one algorithm — never accept 'none'
    audience: 'my-app',
    issuer: 'my-auth-service',
    maxAge: '15m'
  });
}
```

---

## 5. Server-Side Entitlement Check (never trust a client flag)

```javascript
// WRONG — trusts the client
// if (req.body.isPro) { return sendPremiumContent(); }

// RIGHT — backend looks up the real, current entitlement
async function requirePro(req, res, next) {
  const subscription = await db.subscriptions.findOne({ userId: req.user.id });
  if (!subscription || subscription.status !== 'active' || subscription.plan !== 'pro') {
    return res.status(403).json({ error: 'Pro subscription required' });
  }
  next();
}

app.get('/api/premium-report', requireAuth, requirePro, (req, res) => {
  // ...
});
```

## 6. Webhook Signature Verification (Stripe example)

```javascript
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

app.post('/webhooks/stripe', express.raw({ type: 'application/json' }), (req, res) => {
  let event;
  try {
    event = stripe.webhooks.constructEvent(
      req.body,
      req.headers['stripe-signature'],
      process.env.STRIPE_WEBHOOK_SECRET
    );
  } catch (err) {
    // Signature invalid -- do NOT process the payload
    return res.status(400).send(`Webhook signature verification failed`);
  }

  // Idempotency: have we already processed this event ID?
  const alreadyProcessed = await db.processedEvents.exists({ eventId: event.id });
  if (alreadyProcessed) {
    return res.status(200).send(); // ack without reprocessing
  }

  switch (event.type) {
    case 'checkout.session.completed':
      await grantEntitlement(event.data.object); // server-to-server truth
      break;
    case 'customer.subscription.deleted':
      await revokeEntitlement(event.data.object);
      break;
  }

  await db.processedEvents.insert({ eventId: event.id, processedAt: new Date() });
  res.status(200).send();
});
```

Razorpay follows the same shape with `X-Razorpay-Signature` verified via HMAC-SHA256
against your webhook secret — always verify before trusting `req.body`.

## 7. Atomic Coupon Redemption (prevent race-condition double-use)

```javascript
// WRONG — read-then-write allows two parallel requests to both pass the check
// const coupon = await db.coupons.findOne({ code });
// if (!coupon.used) { await db.coupons.update({ code }, { used: true }); grant(); }

// RIGHT — atomic conditional update; only one concurrent request can win
const result = await db.coupons.updateOne(
  { code, used: false },
  { $set: { used: true, usedBy: userId, usedAt: new Date() } }
);
if (result.modifiedCount === 0) {
  return res.status(409).json({ error: 'Coupon already used or invalid' });
}
grantDiscount(userId);
```

## 8. Server-Computed Pricing (never trust client-sent amounts)

```javascript
// WRONG
// const total = req.body.items.reduce((sum, i) => sum + i.price * i.qty, 0);

// RIGHT — look up real prices server-side by product ID only
async function computeOrderTotal(items) {
  let total = 0;
  for (const item of items) {
    const product = await db.products.findOne({ id: item.productId }); // server-known price
    total += product.price * item.qty;
  }
  return total;
}
```

---

## Notes
- These patterns are illustrative starting points, not drop-in production
  code — adapt to your language/framework, add proper error handling and
  logging (without logging secrets), and use your team's standard DB access
  layer instead of the pseudocode `db.*` calls shown here.
- Always keep provider secret keys (Stripe/Razorpay secret key, JWT signing
  key, DB credentials) in backend-only environment variables — never in
  frontend bundles, client-side env files, or committed to version control.

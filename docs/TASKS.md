# Tasks — Name Card Designer

## Sprint 1 — Database & Demo Data
**Goal:** Live schema in Supabase with seed rows; app has data to render on day one.
- [ ] Run migration SQL (all 4 tables: name_card_orders, name_card_designs, purchased_designs, audit_logs)
- [ ] Confirm seed rows visible in Supabase table editor
- [ ] Verify RLS v1 open policies allow anonymous select
- [ ] Document env vars needed: NEXT_PUBLIC_SUPABASE_URL, NEXT_PUBLIC_SUPABASE_ANON_KEY

**Definition of Done:** Supabase dashboard shows all 4 tables with seed data; anonymous `select *` returns rows via Supabase client.

---

## Sprint 2 — Form + Design Generation Engine
**Goal:** Core engine works — user submits details, 10 designs render, order stored.
- [ ] Build `/designer` page with form (name + phone required; company, email, address, back-description optional)
- [ ] Client-side validation: block submit if name or phone empty
- [ ] On submit: POST to `/api/orders` → insert `name_card_orders` row → return order_id
- [ ] Render 10 design components (template_keys: classic-navy, minimal-white, bold-black, gradient-purple, soft-rose, tech-slate, earth-tone, luxury-gold, pastel-sky, corporate-green)
- [ ] All 5 states handled on `/designer`: loading (spinner while inserting), empty (pre-submit prompt card), partial (designs loading one by one), error (insert failed — show retry), ready (all 10 shown)
- [ ] Seed demo designs load for anonymous visitors without submitting

**Definition of Done:** Submitting the form writes a row to `name_card_orders` and renders 10 designs; Supabase shows the new row; empty + error states display correctly.

---

## Sprint 3 — Design Selection & Anti-Copy
**Goal:** Users can select designs and see a price; copying is deterred.
- [ ] Checkbox/select toggle on each design card
- [ ] Running total: `selected_count × SGD $5.00` shown in sticky footer
- [ ] Proceed to Checkout button disabled until ≥1 design selected
- [ ] Apply `user-select:none`, transparent overlay, right-click prevention on all design previews
- [ ] Unselected designs show watermark overlay; selected designs show a check badge

**Definition of Done:** Selecting 3 designs shows "SGD $15.00"; right-click on preview card shows no browser context menu; checkout button is disabled with 0 selections.

---

## Sprint 4 — Stripe Checkout, Webhook & Email ✅ v1 FUNCTIONAL MILESTONE
**Goal:** Real payment works end-to-end; purchased designs stored; email sent.
- [ ] Add env vars: STRIPE_SECRET_KEY, STRIPE_WEBHOOK_SECRET, RESEND_API_KEY, SUPABASE_SERVICE_ROLE_KEY
- [ ] `/api/checkout` POST: validate selected design_ids, create Stripe session with N line items (one per design, SGD $5 each), success_url = `/confirmation?session_id={CHECKOUT_SESSION_ID}`
- [ ] `/api/webhook` POST: verify Stripe signature → insert `purchased_designs` rows → update `name_card_orders.status = paid` → insert `audit_logs` row → call Resend to send confirmation email → set `confirmation_email_sent = true`
- [ ] Idempotency: skip insert if `stripe_session_id` already exists in `purchased_designs`
- [ ] `/confirmation` page: fetch purchased designs by session_id, display design previews + "You own these designs" badge
- [ ] Error state on `/confirmation` if session_id invalid or payment not completed
- [ ] Confirmation email template: lists purchased design names, order date, support email

**Definition of Done:** Using Stripe test card 4242 4242 4242 4242, selecting 2 designs, completing checkout → 2 `purchased_designs` rows in Supabase with correct stripe_session_id → confirmation email received in inbox → `/confirmation` page shows both designs. Payment failure (card 4000 0000 0000 9995) shows error state with retry link.

---

## Sprint 5 — Lock It Down (Auth + Per-User RLS)
**Goal:** Users can log in; data is owner-scoped; demo still works.
- [ ] Enable Supabase Auth (magic link email)
- [ ] Add sign-up / login page at `/auth`
- [ ] On login: update `name_card_orders.user_id` and `purchased_designs.user_id` to `auth.uid()` for orders matching their email
- [ ] Replace v1 open RLS policies with `auth.uid() = user_id` owner-scoped policies on all tables
- [ ] Add `/my-designs` page: shows logged-in user's purchased designs only
- [ ] Seed demo rows remain accessible (user_id = null rows excluded from owner policies — add explicit public demo query)
- [ ] Stop and involve a security reviewer before going live with real user data

**Definition of Done:** Two test users cannot see each other's purchased designs; anonymous user can still view `/designer` with demo seed data; `/my-designs` returns 401 redirect when not logged in.

---

## Sprint 6 — Admin & Audit
**Goal:** Builder can see all orders and revenue; audit trail is complete.
- [ ] `/admin/orders` page listing all orders, status, email, revenue (gated by hardcoded admin check on user email — proper RBAC later)
- [ ] Revenue summary: total paid orders × SGD $5
- [ ] Audit log viewer: filterable by action type
- [ ] Stripe webhook signature enforcement verified in production (not just dev)
- [ ] Final check: `grep -r STRIPE_SECRET .next/` returns nothing

**Definition of Done:** Admin page shows all seed + real orders; audit_logs table has an entry for every purchase and email send; no secret key appears in browser network tab or built JS bundle.

---

## Gantt (Sprint → Weeks)
```
Sprint 1  |██| Week 1
Sprint 2  |████| Week 1–2
Sprint 3  |██| Week 2
Sprint 4  |████| Week 2–3   ← v1 functional
Sprint 5  |████| Week 3–4
Sprint 6  |██| Week 4
```

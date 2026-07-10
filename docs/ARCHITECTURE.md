# Architecture — Name Card Designer

## Stack
- **Frontend:** Next.js 14 (App Router) on Vercel
- **Database:** Supabase (Postgres + RLS)
- **Payments:** Stripe Checkout + Webhooks
- **Email:** Resend (transactional confirmation)
- **Styling:** Tailwind CSS + CSS/SVG for design previews

## What to Build Now vs Later
**Now:** form → generate designs → select → pay → store → email confirm 
**Later:** user login, per-user RLS, PDF export, admin dashboard

## Key User Action — Step by Step
1. User fills the `/designer` form and submits
2. App writes a `name_card_orders` row to Supabase
3. App renders 10 design components using the stored order data (pure CSS/SVG, no external AI needed)
4. User selects ≥1 designs; UI shows running total
5. User clicks "Checkout" → Next.js `/api/checkout` creates a Stripe session with one line item per selected design
6. User completes payment on Stripe-hosted page
7. Stripe fires `checkout.session.completed` webhook → `/api/webhook` verifies signature, inserts `purchased_designs` rows, triggers Resend to send confirmation email
8. User is redirected to `/confirmation?session_id=...` showing their purchased designs

## Layer Plan
1. **Data first** — tables, RLS, seed data
2. **App logic** — form, design renderer, checkout API, webhook handler
3. **Smart features** — design style scoring, personalised layout ranking (later)

## Core Without AI
All 10 designs are deterministic CSS/SVG templates — the app works fully without any AI model.

# Security — Name Card Designer

## Secret Handling
- `STRIPE_SECRET_KEY` and `STRIPE_WEBHOOK_SECRET` stored in Vercel environment variables only — never in client bundle or committed to repo
- `RESEND_API_KEY` server-side only — never referenced in any client component
- `SUPABASE_SERVICE_ROLE_KEY` used only in webhook API route — client uses `SUPABASE_ANON_KEY`
- All API routes are Next.js server routes (`/app/api/...`) — no secret ever reaches the browser

## Permission Model (v1 → lock-down)
- **v1:** RLS open policies allow demo without login; no user data is sensitive at this stage
- **Lock-down sprint:** Replace all `using (true)` policies with `using (auth.uid() = user_id)` — enforced at DB level, not just app code
- DB constraints are the source of truth — bad states are prevented by schema, not by hope

## Stripe Webhook Security
- Every inbound webhook verified with `stripe.webhooks.constructEvent(body, sig, STRIPE_WEBHOOK_SECRET)` before any DB write
- Raw body (not parsed JSON) used for signature check — enforced in middleware
- Idempotency: check for existing `stripe_session_id` before inserting `purchased_designs` to prevent double-processing

## Anti-Copy on Design Previews
- `user-select: none` + `-webkit-touch-callout: none` on all preview containers
- Transparent overlay div blocks right-click and drag
- Designs rendered as CSS/SVG in-browser — no high-res image asset to steal
- Note: CSS-only protection is a deterrent, not a guarantee. Print-ready files are never served until post-purchase server-side route (later sprint)

## Approved Tools Rule
- Agents and API routes may only call the four named tools in AGENTIC_LAYER.md
- No `eval`, no dynamic code execution, no `run_any` patterns
- Every meaningful action (purchase, email send, status update) writes an `audit_logs` row

# Test Plan — Name Card Designer

## Core Success Scenario (manual)
1. Open `/designer` — confirm 10 demo design cards render without logging in
2. Submit form with name="Test User", phone="+65 9000 0000", email="test@example.com" — confirm spinner shows, then 10 personalised designs appear
3. Check Supabase `name_card_orders` table — confirm new row with correct fields
4. Select design cards 1 and 3 — confirm footer shows "SGD $10.00" and Checkout button is active
5. Click Checkout — confirm redirect to Stripe-hosted page with 2 line items at SGD $5 each
6. Enter test card `4242 4242 4242 4242`, any future date, any CVC — complete payment
7. Confirm redirect to `/confirmation?session_id=...` — confirm 2 design previews shown with "You own these" badge
8. Check Supabase `purchased_designs` — confirm 2 rows with correct stripe_session_id and email
9. Check inbox for test@example.com — confirm confirmation email received with design names listed
10. Check `audit_logs` — confirm `purchase_completed` and `email_sent` rows exist

## Empty State Tests
- Open `/designer` before submitting — confirm placeholder prompt "Enter your details to generate 10 designs" shown, no blank/broken cards
- Open `/confirmation?session_id=invalid` — confirm error message "Payment not found. Please contact support."
- Open `/my-designs` without logging in (Sprint 5+) — confirm redirect to `/auth`

## Error State Tests
- Submit form with name empty → client-side error "Name is required" blocks submission
- Stripe test card `4000 0000 0000 9995` (insufficient funds) → Stripe shows decline, user returned to `/designer` with message "Payment was not completed — please try again"
- Simulate webhook with wrong signature → `/api/webhook` returns 400, no DB write occurs, error logged
- Disconnect DB during form submit → error state shown, retry button available

## Anti-Copy Tests
- Right-click a design preview card — confirm no browser context menu appears
- Try to drag a design card image — confirm drag is blocked
- Inspect: confirm no high-res image URLs in network tab — only CSS/SVG in DOM

## Payment Idempotency Test
- Replay the same Stripe webhook event twice → confirm only one `purchased_designs` row per design (no duplicate)

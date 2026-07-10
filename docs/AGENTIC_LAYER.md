# Agentic Layer — Name Card Designer

## Risk Levels & Actions

### Low — Auto-execute (no approval needed)
- Generate 10 design variants from order data (pure template render)
- Compute price total from selected design count
- Tag industry from company name keyword match

### Medium — Light approval (system-triggered, logged)
- Insert `purchased_designs` rows after webhook confirms payment
- Update `name_card_orders.status` to `paid`
- Insert `audit_log` row for the purchase event

### High — Always requires verification before action
- Send confirmation email via Resend (only after Stripe webhook signature verified)
- Any retry of a failed email (check `confirmation_email_sent` flag first to prevent duplicates)

### Critical — Human only
- Issue a Stripe refund
- Delete a purchased_design record
- Any bulk data deletion

## Named Tools (approved)
- `render_design_preview(order_id, template_key)` — deterministic, read-only
- `create_stripe_session(design_ids[], email)` — write, high-risk, logged
- `handle_stripe_webhook(event)` — write, signature-verified, logged
- `send_confirmation_email(purchased_design_ids[], email)` — write, high-risk, logged

## Audit Log Fields
`action | entity_type | entity_id | user_id | metadata (stripe_session_id, design_ids, email_status) | created_at`

## v1 vs Later
- **v1:** webhook handler + email send (human-reviewed Stripe dashboard for refunds)
- **Later:** automated refund tool with dual-approval; re-send email on bounce

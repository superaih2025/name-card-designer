# PRD — Name Card Designer

## Problem
People need professionally designed name cards but lack design tools or skills. They need a fast, self-serve way to generate multiple design options from their contact details and pay only for the designs they want.

## Target User
Individuals and small business owners in Singapore who want print-ready name card designs without hiring a designer.

## Core Objects
- **Name Card Order** — contact details submitted by user (name, phone required; company, email, address, back-description optional)
- **Name Card Design** — one of 10 generated design variants linked to an order
- **Purchased Design** — a design that has been paid for, linked to an email address and Stripe session
- **Audit Log** — every payment event and email sent

## MVP Must-Haves
- [ ] Form accepts name + phone (required) plus optional fields; submits and stores an order
- [ ] 10 visually distinct name card designs rendered from submitted details
- [ ] Multi-select designs; running price total shown (SGD per design)
- [ ] Stripe checkout charges per selected design
- [ ] Webhook confirms payment → stores purchased_designs rows in Supabase
- [ ] Confirmation email sent to user's email after payment
- [ ] Screenshot/copy prevention on design previews (CSS + overlay)
- [ ] Purchased designs retrievable by email address

## Non-Goals (v1)
- User login / accounts (added in lock-down sprint)
- Print-ready PDF export
- Custom colour or font pickers
- Admin dashboard
- Bulk discounts

## Definition of Done
A visitor lands on `/designer`, enters their details, sees 10 generated designs, selects 2, completes Stripe checkout, receives a confirmation email, and the 2 purchased designs appear as `purchased_designs` rows in Supabase — all without creating an account.

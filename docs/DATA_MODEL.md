# Data Model — Name Card Designer

## name_card_orders
| Field | Type | Notes |
|---|---|---|
| id | uuid PK | gen_random_uuid() |
| user_id | uuid | nullable; populated at lock-down sprint |
| full_name | text NOT NULL | required |
| phone | text NOT NULL | required |
| company_name | text | optional |
| email | text | optional at form; required for purchase confirmation |
| address | text | optional |
| back_description | text | optional; printed on card back |
| status | text | draft \| paid |
| created_at | timestamptz | default now() |

## name_card_designs
| Field | Type | Notes |
|---|---|---|
| id | uuid PK | |
| user_id | uuid | nullable |
| order_id | uuid FK → name_card_orders | cascade delete |
| design_index | integer | 1–10 |
| template_key | text | e.g. classic-navy |
| preview_config | jsonb | colours, font, layout params |
| style_summary | text | **AI field** — human-readable description |
| style_summary_source | text | rule-based \| gpt-4o |
| style_summary_confidence | numeric | 0.0–1.0 |
| style_summary_review_status | text | unreviewed \| approved \| rejected |
| price_cents | integer | default 500 (SGD $5.00) |
| created_at | timestamptz | |

## purchased_designs
| Field | Type | Notes |
|---|---|---|
| id | uuid PK | |
| user_id | uuid | nullable; linked at lock-down |
| order_id | uuid FK → name_card_orders | |
| design_id | uuid FK → name_card_designs | |
| stripe_session_id | text | from Stripe webhook |
| stripe_payment_intent_id | text | |
| email | text | email confirmation sent to |
| amount_paid_cents | integer | |
| confirmation_email_sent | boolean | default false |
| created_at | timestamptz | |

## audit_logs
| Field | Type | Notes |
|---|---|---|
| id | uuid PK | |
| user_id | uuid | nullable |
| action | text | e.g. purchase_completed, email_sent |
| entity_type | text | name_card_order, purchased_design |
| entity_id | uuid | |
| metadata | jsonb | stripe_session_id, design_ids, etc. |
| created_at | timestamptz | |

## RLS
- v1: all tables open (select + all) — permissive demo policies
- Lock-down sprint: replace with `auth.uid() = user_id` owner policies

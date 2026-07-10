create table if not exists name_card_orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid,
  full_name text not null,
  phone text not null,
  company_name text,
  email text,
  address text,
  back_description text,
  status text not null default 'draft',
  created_at timestamptz not null default now()
);

alter table name_card_orders enable row level security;
drop policy if exists "name_card_orders_v1_read" on name_card_orders;
create policy "name_card_orders_v1_read" on name_card_orders for select using (true);
drop policy if exists "name_card_orders_v1_write" on name_card_orders;
create policy "name_card_orders_v1_write" on name_card_orders for all using (true) with check (true);

create table if not exists name_card_designs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid,
  order_id uuid references name_card_orders(id) on delete cascade,
  design_index integer not null,
  template_key text not null,
  preview_config jsonb not null default '{}',
  style_summary text,
  style_summary_source text default 'rule-based',
  style_summary_confidence numeric default 1.0,
  style_summary_review_status text default 'unreviewed',
  price_cents integer not null default 500,
  created_at timestamptz not null default now()
);

alter table name_card_designs enable row level security;
drop policy if exists "name_card_designs_v1_read" on name_card_designs;
create policy "name_card_designs_v1_read" on name_card_designs for select using (true);
drop policy if exists "name_card_designs_v1_write" on name_card_designs;
create policy "name_card_designs_v1_write" on name_card_designs for all using (true) with check (true);

create table if not exists purchased_designs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid,
  order_id uuid references name_card_orders(id) on delete cascade,
  design_id uuid references name_card_designs(id) on delete cascade,
  stripe_session_id text,
  stripe_payment_intent_id text,
  email text,
  amount_paid_cents integer not null,
  confirmation_email_sent boolean not null default false,
  created_at timestamptz not null default now()
);

alter table purchased_designs enable row level security;
drop policy if exists "purchased_designs_v1_read" on purchased_designs;
create policy "purchased_designs_v1_read" on purchased_designs for select using (true);
drop policy if exists "purchased_designs_v1_write" on purchased_designs;
create policy "purchased_designs_v1_write" on purchased_designs for all using (true) with check (true);

create table if not exists audit_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid,
  action text not null,
  entity_type text not null,
  entity_id uuid,
  metadata jsonb default '{}',
  created_at timestamptz not null default now()
);

alter table audit_logs enable row level security;
drop policy if exists "audit_logs_v1_read" on audit_logs;
create policy "audit_logs_v1_read" on audit_logs for select using (true);
drop policy if exists "audit_logs_v1_write" on audit_logs;
create policy "audit_logs_v1_write" on audit_logs for all using (true) with check (true);

insert into name_card_orders (id, full_name, phone, company_name, email, address, back_description, status)
values
  ('a1000000-0000-0000-0000-000000000001', 'Sarah Tan', '+65 9123 4567', 'Tan & Associates', 'sarah@tanlaw.sg', '10 Raffles Place, #20-01, Singapore 048633', 'Corporate law specialist with 15 years experience.', 'paid'),
  ('a1000000-0000-0000-0000-000000000002', 'James Lim', '+65 8234 5678', 'JL Creative Studio', 'james@jlcreative.sg', '71 Ayer Rajah Crescent, Singapore 139951', 'Brand identity & motion design.', 'paid'),
  ('a1000000-0000-0000-0000-000000000003', 'Priya Nair', '+65 9345 6789', null, 'priya.nair@gmail.com', null, null, 'draft');

insert into name_card_designs (order_id, design_index, template_key, preview_config, style_summary, style_summary_source, style_summary_confidence, style_summary_review_status, price_cents)
values
  ('a1000000-0000-0000-0000-000000000001', 1, 'classic-navy', '{"bg":"#1a2e4a","text":"#ffffff","accent":"#c9a84c","font":"serif"}', 'Classic navy with gold accent — formal and authoritative', 'rule-based', 1.0, 'unreviewed', 500),
  ('a1000000-0000-0000-0000-000000000001', 2, 'minimal-white', '{"bg":"#ffffff","text":"#111111","accent":"#e63946","font":"sans"}', 'Clean white with red accent — modern minimalist', 'rule-based', 1.0, 'unreviewed', 500),
  ('a1000000-0000-0000-0000-000000000002', 1, 'bold-black', '{"bg":"#111111","text":"#ffffff","accent":"#f4a261","font":"display"}', 'Bold black with orange pop — creative and energetic', 'rule-based', 1.0, 'unreviewed', 500),
  ('a1000000-0000-0000-0000-000000000002', 2, 'gradient-purple', '{"bg":"linear-gradient(135deg,#667eea,#764ba2)","text":"#ffffff","accent":"#ffffff","font":"sans"}', 'Purple gradient — vibrant and contemporary', 'rule-based', 1.0, 'unreviewed', 500);

insert into purchased_designs (order_id, design_id, stripe_session_id, email, amount_paid_cents, confirmation_email_sent)
select
  d.order_id,
  d.id,
  'cs_demo_stripe_session_001',
  'sarah@tanlaw.sg',
  500,
  true
from name_card_designs d
where d.order_id = 'a1000000-0000-0000-0000-000000000001'
  and d.design_index = 1;
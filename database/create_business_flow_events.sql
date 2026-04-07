-- Persistent timeline for CRM/SCM/ERP/Revenue/Competitor demo replay
create table if not exists public.business_flow_events (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  actor_user_id uuid,
  actor_role text not null check (actor_role in ('customer', 'admin', 'system')),
  aspect text not null check (aspect in ('crm', 'scm', 'erp', 'revenue', 'competitor')),
  stage text,
  action text not null,
  metadata jsonb not null default '{}'::jsonb
);

create index if not exists idx_business_flow_events_created_at
  on public.business_flow_events (created_at desc);

create index if not exists idx_business_flow_events_actor_role
  on public.business_flow_events (actor_role);

create index if not exists idx_business_flow_events_aspect
  on public.business_flow_events (aspect);

alter table public.business_flow_events enable row level security;

drop policy if exists "business_flow_events_select_auth" on public.business_flow_events;
create policy "business_flow_events_select_auth"
  on public.business_flow_events
  for select
  to authenticated
  using (true);

drop policy if exists "business_flow_events_insert_auth" on public.business_flow_events;
create policy "business_flow_events_insert_auth"
  on public.business_flow_events
  for insert
  to authenticated
  with check (auth.uid() = actor_user_id or actor_role = 'system');
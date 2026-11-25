-- KrijLens Automotive: shared cloud database (Supabase)
-- Run this entire script in Supabase SQL Editor as project owner.

create table if not exists public.company_members (
  user_id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.company_state (
  id integer primary key check (id = 1),
  version bigint not null default 0,
  data jsonb not null default '{"cars":[],"clients":[],"sales":[],"expenses":[]}'::jsonb,
  updated_at timestamptz not null default now()
);

insert into public.company_state(id, version, data)
values (1, 0, '{"cars":[],"clients":[],"sales":[],"expenses":[]}'::jsonb)
on conflict (id) do nothing;

create table if not exists public.sync_events (
  id bigint generated always as identity primary key,
  version bigint not null,
  created_at timestamptz not null default now()
);

alter table public.company_members enable row level security;
alter table public.company_state enable row level security;
alter table public.sync_events enable row level security;

drop policy if exists "Members can view own membership" on public.company_members;
create policy "Members can view own membership" on public.company_members
for select to authenticated using (user_id = auth.uid());

drop policy if exists "Company members can read state" on public.company_state;
create policy "Company members can read state" on public.company_state
for select to authenticated using (
  exists (select 1 from public.company_members m where m.user_id = auth.uid())
);

drop policy if exists "Company members can read sync events" on public.sync_events;
create policy "Company members can read sync events" on public.sync_events
for select to authenticated using (
  exists (select 1 from public.company_members m where m.user_id = auth.uid())
);

create or replace function public.save_company_state(p_data jsonb, p_expected_version bigint)
returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare new_version bigint;
begin
  if auth.uid() is null or not exists (
    select 1 from public.company_members where user_id = auth.uid()
  ) then
    raise exception 'NOT_A_COMPANY_MEMBER';
  end if;

  update public.company_state
  set data = p_data, version = version + 1, updated_at = now()
  where id = 1 and version = p_expected_version
  returning version into new_version;

  if new_version is null then
    raise exception 'VERSION_CONFLICT';
  end if;

  insert into public.sync_events(version) values (new_version);
  return new_version;
end;
$$;

revoke all on function public.save_company_state(jsonb,bigint) from public;
grant execute on function public.save_company_state(jsonb,bigint) to authenticated;

grant select on public.company_members, public.company_state, public.sync_events to authenticated;

-- Enable Realtime for the small notification table only.
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'sync_events'
  ) then
    alter publication supabase_realtime add table public.sync_events;
  end if;
end $$;

-- After creating Quinten and Dylan under Authentication -> Users,
-- insert both UUIDs below. Replace the placeholders with the actual auth.users IDs.
-- insert into public.company_members(user_id, display_name)
-- values
-- ('QUINTEN-USER-UUID-HERE', 'Quinten'),
-- ('DYLAN-USER-UUID-HERE', 'Dylan');

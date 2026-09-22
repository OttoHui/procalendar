create table if not exists public.quad_sync (
  token text primary key,
  device_id text not null,
  snapshot jsonb not null,
  updated_at timestamptz not null default now()
);

alter table public.quad_sync enable row level security;

drop policy if exists "public calendar read" on public.quad_sync;
create policy "public calendar read" on public.quad_sync
  for select to anon using (true);

drop policy if exists "public calendar write" on public.quad_sync;
create policy "public calendar write" on public.quad_sync
  for insert to anon with check (true);

drop policy if exists "public calendar update" on public.quad_sync;
create policy "public calendar update" on public.quad_sync
  for update to anon using (true) with check (true);

grant select, insert, update on public.quad_sync to anon;

create table if not exists public.quad_sync_items (
  token text not null,
  item_type text not null check (item_type in ('event', 'label')),
  item_id text not null,
  payload jsonb,
  updated_at timestamptz not null default now(),
  deleted boolean not null default false,
  device_id text not null,
  primary key (token, item_type, item_id)
);

alter table public.quad_sync_items enable row level security;

drop policy if exists "public item read" on public.quad_sync_items;
create policy "public item read" on public.quad_sync_items
  for select to anon using (true);

drop policy if exists "public item write" on public.quad_sync_items;
create policy "public item write" on public.quad_sync_items
  for insert to anon with check (true);

drop policy if exists "public item update" on public.quad_sync_items;
create policy "public item update" on public.quad_sync_items
  for update to anon using (true) with check (true);

grant select, insert, update on public.quad_sync_items to anon;

create or replace function public.keep_newest_quad_sync_item()
returns trigger
language plpgsql
as $$
begin
  if old.updated_at > new.updated_at then
    return old;
  end if;
  return new;
end;
$$;

drop trigger if exists quad_sync_items_keep_newest on public.quad_sync_items;
create trigger quad_sync_items_keep_newest
before update on public.quad_sync_items
for each row execute function public.keep_newest_quad_sync_item();

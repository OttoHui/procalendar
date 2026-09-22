-- Per-item cloud sync for Quad.
-- Each event and label is stored independently. Deleted rows are tombstones.

create table if not exists public.quad_items (
  token text not null,
  item_type text not null check (item_type in ('event', 'label')),
  item_id text not null,
  payload jsonb not null default '{}'::jsonb,
  deleted boolean not null default false,
  device_id text not null,
  updated_at timestamptz not null default now(),
  primary key (token, item_type, item_id)
);

create or replace function public.set_quad_items_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists quad_items_updated_at on public.quad_items;
create trigger quad_items_updated_at
before update on public.quad_items
for each row execute function public.set_quad_items_updated_at();

alter table public.quad_items enable row level security;

drop policy if exists "public item read" on public.quad_items;
create policy "public item read" on public.quad_items
  for select to anon using (true);

drop policy if exists "public item insert" on public.quad_items;
create policy "public item insert" on public.quad_items
  for insert to anon with check (true);

drop policy if exists "public item update" on public.quad_items;
create policy "public item update" on public.quad_items
  for update to anon using (true) with check (true);

grant select, insert, update on public.quad_items to anon;

-- The previous quad_sync snapshot table is intentionally not used by the app.
-- It may be deleted after confirming the new per-item sync works:
-- drop table if exists public.quad_sync;grant select, insert, update on public.quad_sync to anon;

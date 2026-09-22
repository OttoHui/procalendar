create table if not exists public.quad_sync (
  token text primary key,
  device_id text not null,
  snapshot jsonb not null,
  updated_at timestamptz not null default now()
);

create or replace function public.set_quad_sync_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists quad_sync_updated_at on public.quad_sync;
create trigger quad_sync_updated_at
before update on public.quad_sync
for each row execute function public.set_quad_sync_updated_at();

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

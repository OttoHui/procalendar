-- Run this once in the Supabase SQL editor.
-- The browser client can only access rows belonging to the signed-in user.

create table if not exists public.calendar_events (
  user_id uuid not null references auth.users(id) on delete cascade,
  event_id text not null,
  data jsonb not null,
  updated_at timestamptz not null default now(),
  primary key (user_id, event_id)
);

create table if not exists public.calendar_labels (
  user_id uuid not null references auth.users(id) on delete cascade,
  label_id text not null,
  data jsonb not null,
  updated_at timestamptz not null default now(),
  primary key (user_id, label_id)
);

create table if not exists public.calendar_settings (
  user_id uuid not null references auth.users(id) on delete cascade,
  setting_key text not null,
  data jsonb not null,
  updated_at timestamptz not null default now(),
  primary key (user_id, setting_key)
);

alter table public.calendar_events enable row level security;
alter table public.calendar_labels enable row level security;
alter table public.calendar_settings enable row level security;

drop policy if exists "Users manage their calendar events" on public.calendar_events;
create policy "Users manage their calendar events"
  on public.calendar_events for all
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "Users manage their calendar labels" on public.calendar_labels;
create policy "Users manage their calendar labels"
  on public.calendar_labels for all
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "Users manage their calendar settings" on public.calendar_settings;
create policy "Users manage their calendar settings"
  on public.calendar_settings for all
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

grant select, insert, update, delete on public.calendar_events to authenticated;
grant select, insert, update, delete on public.calendar_labels to authenticated;
grant select, insert, update, delete on public.calendar_settings to authenticated;

-- Enable cross-device realtime refresh. Run these three statements once.
alter publication supabase_realtime add table public.calendar_events;
alter publication supabase_realtime add table public.calendar_labels;
alter publication supabase_realtime add table public.calendar_settings;

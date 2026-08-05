-- Memo List — Web · Tabella abbonamenti Web Push (Milestone 1 notifiche).
-- Da eseguire nel SQL Editor di Supabase (progetto jbzbotkwfknmxtwaitpl).
-- Ogni riga = un browser/dispositivo iscritto alle notifiche di un utente.

create table if not exists public.web_push_subscriptions (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references auth.users(id) on delete cascade,
  endpoint   text not null unique,          -- indirizzo push del browser (univoco)
  p256dh     text not null,                 -- chiave pubblica del browser
  auth       text not null,                 -- segreto di autenticazione del browser
  created_at timestamptz not null default now()
);

create index if not exists web_push_subscriptions_user_id_idx
  on public.web_push_subscriptions(user_id);

-- Sicurezza a livello di riga: ognuno vede e gestisce SOLO i propri abbonamenti.
alter table public.web_push_subscriptions enable row level security;

drop policy if exists "wps_select_own" on public.web_push_subscriptions;
drop policy if exists "wps_insert_own" on public.web_push_subscriptions;
drop policy if exists "wps_update_own" on public.web_push_subscriptions;
drop policy if exists "wps_delete_own" on public.web_push_subscriptions;

create policy "wps_select_own" on public.web_push_subscriptions
  for select using (auth.uid() = user_id);
create policy "wps_insert_own" on public.web_push_subscriptions
  for insert with check (auth.uid() = user_id);
create policy "wps_update_own" on public.web_push_subscriptions
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "wps_delete_own" on public.web_push_subscriptions
  for delete using (auth.uid() = user_id);

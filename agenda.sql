-- FIDELIZA 8.1 • Execute no Supabase > SQL Editor, uma única vez.
-- Não apaga dados existentes. Depende da função public.fideliza_can_access(text).
begin;
create table if not exists public.fideliza_appointments (
  id uuid primary key default gen_random_uuid(),
  store text not null check (store in ('GUARARAPES','RECIFE','RIOMAR','TACARUNA','PATTEO','PNWS','QUIOSQUE')),
  client_name text not null,
  phone text,
  scheduled_at timestamptz not null,
  type text not null default 'Venda de produto',
  product text,
  channel text not null default 'WhatsApp',
  notes text,
  code text not null,
  status text not null default 'agendado' check (status in ('agendado','confirmado','concluido','cancelado')),
  created_at timestamptz not null default now()
);
create index if not exists fideliza_appointments_store_when_idx on public.fideliza_appointments(store,scheduled_at);
alter table public.fideliza_appointments enable row level security;
revoke all on public.fideliza_appointments from anon, authenticated;
grant select, insert, update on public.fideliza_appointments to authenticated;
drop policy if exists "appointments_read" on public.fideliza_appointments;
drop policy if exists "appointments_insert" on public.fideliza_appointments;
drop policy if exists "appointments_update" on public.fideliza_appointments;
create policy "appointments_read" on public.fideliza_appointments for select to authenticated using (public.fideliza_can_access(store));
create policy "appointments_insert" on public.fideliza_appointments for insert to authenticated with check (public.fideliza_can_access(store));
create policy "appointments_update" on public.fideliza_appointments for update to authenticated using (public.fideliza_can_access(store)) with check (public.fideliza_can_access(store));
commit;

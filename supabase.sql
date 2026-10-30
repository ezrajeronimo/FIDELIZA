-- Execute uma vez no SQL Editor. Não publique dados de clientes no GitHub.
create table if not exists public.fideliza_profiles (
 user_id uuid primary key references auth.users(id) on delete cascade,
 name text not null default '',
 role text not null check(role in ('admin','store')),
 store text check(store in ('GUARARAPES','RECIFE','RIOMAR','TACARUNA','PATTEO','PNWS','QUIOSQUE')),
 constraint profile_role_store check ((role='admin' and store is null) or (role='store' and store is not null))
);
create table if not exists public.fideliza_sales (
 store text not null check(store in ('GUARARAPES','RECIFE','RIOMAR','TACARUNA','PATTEO','PNWS','QUIOSQUE')),
 sale_id text not null,
 payload jsonb not null,
 updated_at timestamptz not null default now(),
 primary key(store,sale_id)
);
create table if not exists public.fideliza_contacts (
 id uuid primary key default gen_random_uuid(),
 store text not null check(store in ('GUARARAPES','RECIFE','RIOMAR','TACARUNA','PATTEO','PNWS','QUIOSQUE')),
 payload jsonb not null,
 created_at timestamptz not null default now()
);
create index if not exists fideliza_contacts_store_idx on public.fideliza_contacts(store);
alter table public.fideliza_profiles enable row level security;
alter table public.fideliza_sales enable row level security;
alter table public.fideliza_contacts enable row level security;
revoke all on public.fideliza_profiles, public.fideliza_sales, public.fideliza_contacts from anon;
grant select on public.fideliza_profiles to authenticated;
grant select,insert,update on public.fideliza_sales to authenticated;
grant select,insert on public.fideliza_contacts to authenticated;
create policy "profile_self" on public.fideliza_profiles for select to authenticated using ((select auth.uid())=user_id);
-- As funções SECURITY DEFINER devem ter search_path fixo e acesso restrito.
create or replace function public.fideliza_can_access(target_store text) returns boolean
language sql stable security definer set search_path = '' as $$
 select exists(select 1 from public.fideliza_profiles p where p.user_id=(select auth.uid()) and (p.role='admin' or (p.role='store' and p.store=target_store)));
$$;
revoke all on function public.fideliza_can_access(text) from public;
grant execute on function public.fideliza_can_access(text) to authenticated;
create policy "sales_read" on public.fideliza_sales for select to authenticated using(public.fideliza_can_access(store));
create policy "sales_insert" on public.fideliza_sales for insert to authenticated with check(public.fideliza_can_access(store));
create policy "sales_update" on public.fideliza_sales for update to authenticated using(public.fideliza_can_access(store)) with check(public.fideliza_can_access(store));
create policy "contacts_read" on public.fideliza_contacts for select to authenticated using(public.fideliza_can_access(store));
create policy "contacts_insert" on public.fideliza_contacts for insert to authenticated with check(public.fideliza_can_access(store));
-- Após criar o primeiro usuário em Authentication > Users, execute substituindo o UUID:
-- insert into public.fideliza_profiles(user_id,name,role,store)
-- values ('UUID_DO_USUARIO','Gestão','admin',null);
-- Para os demais usuários atribua role='store' e a loja correspondente.

-- FIDELIZA 8.3 | Execute UMA VEZ no SQL Editor do projeto atual
-- Não remove dados existentes de vendas, clientes, contatos ou agenda.
BEGIN;

CREATE OR REPLACE FUNCTION public.fideliza_is_admin()
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.fideliza_profiles p
    WHERE p.user_id = (SELECT auth.uid()) AND p.role = 'admin'
  );
$$;
REVOKE ALL ON FUNCTION public.fideliza_is_admin() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.fideliza_is_admin() TO authenticated;

-- A gestão pode consultar todos os perfis; usuários comuns veem somente o próprio.
DROP POLICY IF EXISTS profile_admin_read ON public.fideliza_profiles;
CREATE POLICY profile_admin_read
ON public.fideliza_profiles FOR SELECT TO authenticated
USING (public.fideliza_is_admin());

-- Identidade compartilhada para a página de login (não contém dados pessoais).
CREATE TABLE IF NOT EXISTS public.fideliza_settings (
  id integer PRIMARY KEY CHECK (id=1),
  theme text NOT NULL DEFAULT 'executive' CHECK (theme IN ('executive','ocean','graphite')),
  logo_data text,
  updated_at timestamptz NOT NULL DEFAULT now(),
  updated_by uuid REFERENCES auth.users(id)
);
INSERT INTO public.fideliza_settings (id,theme)
VALUES (1,'executive')
ON CONFLICT (id) DO NOTHING;
ALTER TABLE public.fideliza_settings ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.fideliza_settings FROM anon, authenticated;
GRANT SELECT ON public.fideliza_settings TO anon, authenticated;
GRANT UPDATE ON public.fideliza_settings TO authenticated;
DROP POLICY IF EXISTS branding_public_read ON public.fideliza_settings;
CREATE POLICY branding_public_read
ON public.fideliza_settings FOR SELECT TO anon, authenticated
USING (id=1);
DROP POLICY IF EXISTS branding_admin_update ON public.fideliza_settings;
CREATE POLICY branding_admin_update
ON public.fideliza_settings FOR UPDATE TO authenticated
USING (id=1 AND public.fideliza_is_admin())
WITH CHECK (id=1 AND public.fideliza_is_admin());

-- Usuário comum pode fazer ações operacionais, mas não alterar/importar vendas.
-- A política anterior permitia gravação de vendas para toda loja autenticada.
DROP POLICY IF EXISTS sales_insert ON public.fideliza_sales;
CREATE POLICY sales_insert
ON public.fideliza_sales FOR INSERT TO authenticated
WITH CHECK (public.fideliza_is_admin() AND public.fideliza_can_access(store));
DROP POLICY IF EXISTS sales_update ON public.fideliza_sales;
CREATE POLICY sales_update
ON public.fideliza_sales FOR UPDATE TO authenticated
USING (public.fideliza_is_admin() AND public.fideliza_can_access(store))
WITH CHECK (public.fideliza_is_admin() AND public.fideliza_can_access(store));

COMMIT;
NOTIFY pgrst, 'reload schema';

-- Verificação:
SELECT id, theme, updated_at FROM public.fideliza_settings;

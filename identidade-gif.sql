-- FIDELIZA 8.4 | CONFIGURAÇÃO DA IDENTIDADE VISUAL + ARMAZENAMENTO DE GIF
-- Execute no Supabase > SQL Editor, ANTES de atualizar o index.html no GitHub.
-- Seguro para execução repetida. Não remove clientes, vendas, contatos nem agendamentos.

BEGIN;

-- Confere a permissão administrativa no perfil existente do FIDELIZA.
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

-- Tabela ausente que causou "Could not find public.fideliza_settings".
CREATE TABLE IF NOT EXISTS public.fideliza_settings (
  id integer PRIMARY KEY CHECK (id=1),
  theme text NOT NULL DEFAULT 'executive'
    CHECK (theme IN ('executive','ocean','graphite')),
  logo_data text,
  logo_url text,
  updated_at timestamptz NOT NULL DEFAULT now(),
  updated_by uuid REFERENCES auth.users(id)
);
ALTER TABLE public.fideliza_settings
  ADD COLUMN IF NOT EXISTS logo_url text;
INSERT INTO public.fideliza_settings(id,theme)
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

-- Bucket público: apenas imagens institucionais; não faça upload de documentos privados.
INSERT INTO storage.buckets (id,name,public,file_size_limit,allowed_mime_types)
VALUES (
 'fideliza-branding', 'fideliza-branding', true, 8388608,
 ARRAY['image/png','image/jpeg','image/webp','image/gif']::text[]
)
ON CONFLICT (id) DO NOTHING;

-- Apenas administradores podem enviar imagens novas.
DROP POLICY IF EXISTS fideliza_branding_admin_insert ON storage.objects;
CREATE POLICY fideliza_branding_admin_insert
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (bucket_id='fideliza-branding' AND public.fideliza_is_admin());

COMMIT;
NOTIFY pgrst, 'reload schema';

-- Verificação: deve retornar um registro com id=1.
SELECT id,theme,logo_url,updated_at
FROM public.fideliza_settings
WHERE id=1;

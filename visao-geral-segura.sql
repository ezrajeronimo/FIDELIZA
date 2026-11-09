-- FIDELIZA 8.6 — Dashboard compartilhado e listas restritas por loja
-- Execute no Supabase SQL Editor como proprietário do projeto.
-- Não altera/exclui dados de clientes, vendas ou agendamentos.

BEGIN;

-- Permite excluir usuários de gestão que salvaram a logo/tema anteriormente,
-- mantendo o histórico das configurações do sistema.
ALTER TABLE public.fideliza_settings
  DROP CONSTRAINT IF EXISTS fideliza_settings_updated_by_fkey;
ALTER TABLE public.fideliza_settings
  ADD CONSTRAINT fideliza_settings_updated_by_fkey FOREIGN KEY (updated_by)
  REFERENCES auth.users(id) ON DELETE SET NULL;


-- Esta RPC devolve APENAS totais agregados. Não retorna clientes, telefone,
-- nomes, valores individuais de vendas, payload nem contatos de outra loja.
-- Autorização dentro da função, e EXECUTE somente para authenticated.
CREATE OR REPLACE FUNCTION public.fideliza_dashboard_snapshot(p_day date)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  result jsonb;
BEGIN
  IF auth.uid() IS NULL OR NOT EXISTS (
    SELECT 1 FROM public.fideliza_profiles p
     WHERE p.user_id=auth.uid() AND p.role IN ('admin','store')
  ) THEN
    RAISE EXCEPTION 'Acesso não autorizado' USING ERRCODE='42501';
  END IF;
  IF p_day IS NULL THEN
    RAISE EXCEPTION 'Informe a data de análise' USING ERRCODE='22004';
  END IF;

  WITH units(store,ord) AS (
    VALUES ('GUARARAPES',1),('RECIFE',2),('RIOMAR',3),('TACARUNA',4),
           ('PATTEO',5),('PNWS',6),('QUIOSQUE',7)
  ),
  customer_sales AS (
    SELECT s.store,
      COALESCE(NULLIF(s.payload->>'customerKey',''),
               NULLIF(s.payload->>'telefone',''),
               NULLIF(s.payload->>'id',''),
               NULLIF(s.payload->>'nome',''),s.sale_id) AS customer_key,
      count(*) AS purchases,
      max(CASE WHEN (s.payload->>'dataISO') ~ '^\d{4}-\d{2}-\d{2}$'
             THEN (s.payload->>'dataISO')::date ELSE NULL END) AS last_sale
    FROM public.fideliza_sales s
    GROUP BY s.store, COALESCE(NULLIF(s.payload->>'customerKey',''),
               NULLIF(s.payload->>'telefone',''),
               NULLIF(s.payload->>'id',''),NULLIF(s.payload->>'nome',''),s.sale_id)
  ),
  sales_totals AS (
    SELECT count(*)::int AS customers,
           count(*) FILTER (WHERE purchases>1)::int AS recurring,
           count(*) FILTER (WHERE last_sale < (CURRENT_TIMESTAMP AT TIME ZONE 'America/Recife')::date - 90)::int AS inactive
    FROM customer_sales
  ),
  day_contacts AS (
    SELECT c.store,
      COALESCE(NULLIF(c.payload->>'telefone',''),
               NULLIF(c.payload->>'id',''),NULLIF(c.payload->>'nome',''),c.id::text) AS customer_key,
      bool_or(c.payload->>'status'='Cliente reativado') AS reactivated
    FROM public.fideliza_contacts c
    WHERE (c.created_at AT TIME ZONE 'America/Recife')::date=p_day
    GROUP BY c.store, COALESCE(NULLIF(c.payload->>'telefone',''),
               NULLIF(c.payload->>'id',''),NULLIF(c.payload->>'nome',''),c.id::text)
  ),
  day_store AS (
    SELECT dc.store,
      count(*)::int AS contacts,
      count(*) FILTER (WHERE dc.reactivated)::int AS reactivated
    FROM day_contacts dc GROUP BY dc.store
  ),
  global_contacts AS (
    SELECT count(DISTINCT (store, COALESCE(NULLIF(payload->>'telefone',''),
              NULLIF(payload->>'id',''),NULLIF(payload->>'nome',''),id::text)))::int AS contacted
    FROM public.fideliza_contacts
  )
  SELECT jsonb_build_object(
    'date', p_day::text,
    'customers', st.customers,
    'recurring', st.recurring,
    'inactive', st.inactive,
    'contacted', gc.contacted,
    'stores',(
       SELECT jsonb_agg(jsonb_build_object('store',u.store,
              'contacts',coalesce(ds.contacts,0),
              'reactivated',coalesce(ds.reactivated,0)) ORDER BY u.ord)
       FROM units u LEFT JOIN day_store ds ON ds.store=u.store
    )
  ) INTO result FROM sales_totals st CROSS JOIN global_contacts gc;
  RETURN result;
END;
$$;
REVOKE ALL ON FUNCTION public.fideliza_dashboard_snapshot(date) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.fideliza_dashboard_snapshot(date) TO authenticated;

-- Confere que a política de leitura da base continua restrita por loja.
-- Não criar política de leitura ampla para as tabelas sensíveis.
DROP POLICY IF EXISTS sales_read ON public.fideliza_sales;
CREATE POLICY sales_read ON public.fideliza_sales
  FOR SELECT TO authenticated USING (public.fideliza_can_access(store));
DROP POLICY IF EXISTS contacts_read ON public.fideliza_contacts;
CREATE POLICY contacts_read ON public.fideliza_contacts
  FOR SELECT TO authenticated USING (public.fideliza_can_access(store));
DROP POLICY IF EXISTS appointments_read ON public.fideliza_appointments;
CREATE POLICY appointments_read ON public.fideliza_appointments
  FOR SELECT TO authenticated USING (public.fideliza_can_access(store));
-- Política legada da versão 8.1 também se chamava appointments_read; os outros nomes são tratados acima.

COMMIT;
NOTIFY pgrst, 'reload schema';

-- Validação: deve existir a função e as políticas por loja.
SELECT proname FROM pg_proc WHERE proname='fideliza_dashboard_snapshot';

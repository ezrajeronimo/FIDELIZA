-- FIDELIZA 8.7 | Limpar vendas com segurança
-- Execute no Supabase SQL Editor uma única vez.
-- Não apaga qualquer dado durante a instalação.
BEGIN;

GRANT DELETE ON public.fideliza_sales TO authenticated;

DROP POLICY IF EXISTS fideliza_sales_delete_admin ON public.fideliza_sales;
CREATE POLICY fideliza_sales_delete_admin
ON public.fideliza_sales
FOR DELETE TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.fideliza_profiles AS p
    WHERE p.user_id = (SELECT auth.uid())
      AND p.role = 'admin'
  )
);

COMMIT;
NOTIFY pgrst, 'reload schema';

-- Confira as permissões:
SELECT policyname, cmd, roles
FROM pg_policies
WHERE schemaname='public'
  AND tablename='fideliza_sales'
  AND cmd='DELETE';

# FIDELIZA 8.4 — Tema + GIF animado

## O que foi corrigido
- Corrige a ausência da tabela `public.fideliza_settings` que impedia salvar as paletas.
- Logo aceita **PNG, JPEG, WebP e GIF animado** (até 8 MB).
- Imagens são enviadas ao bucket público `fideliza-branding` no **Supabase Storage**, não à tabela de configurações.
- GIF é armazenado sem passar por canvas ou conversão, preservando seus quadros de animação.
- A logo aparece no login, menu e celular, incluindo antes do usuário se autenticar.
- Alteração de identidade e upload protegidos pelas políticas RLS e função `fideliza_is_admin()`.
- Mantém login, Supabase, vendas, filtros, WhatsApp, agendamentos e área de administração da versão 8.3.

## Instalação (nesta ordem)
1. Faça backup do banco e do `index.html` atual.
2. Abra **Supabase → SQL Editor → New query**, cole **TODO** o conteúdo de `identidade-gif.sql` e clique **Run**.
3. Confirme que aparece uma linha com `id = 1` no resultado; a tabela `fideliza_settings` e o bucket `fideliza-branding` estarão criados.
4. No GitHub `ezrajeronimo/FIDELIZA`, substitua **somente** o `index.html` pelo novo. Não altere `config.js`.
5. Abra o FIDELIZA, recarregue com `Command + Shift + R` e entre como administrador.
6. Vá a **Administração → Identidade do sistema**; selecione Ocean Blue e clique **Salvar identidade**. Depois selecione um GIF e salve.
7. Teste a logo animada saindo da sessão e abrindo a tela de login.

**Não execute `admin.sql` antigo por cima desta migração se não houver motivo:** `identidade-gif.sql` é a correção específica para logo/tema. A função Edge de convites de usuários continua sendo uma configuração separada, necessária caso o convite apresente erro.

## Observações de segurança
- O bucket é **público apenas para leitura**: a logo deve ser uma imagem institucional, nunca dados pessoais.
- Upload restrito aos administradores no Supabase. Imagens antigas podem permanecer no bucket para não quebrar caches/URLs já publicados; faça manutenção periódica se necessário.
- Não coloque chaves `service_role` ou secret keys no GitHub.
- SQL e JavaScript devem ser testados no seu projeto real antes de distribuir às lojas. O código passa pela verificação de sintaxe, mas não executamos a migração no seu Supabase.

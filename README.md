# FIDELIZA 8.1 — Agendamentos por loja

## Atualizações
- WhatsApp abre com `Que bom falar com você! 👋` preenchido. O vendedor ainda precisa clicar em enviar.
- Botão **Agendamento** ao lado de WhatsApp no perfil 360° do cliente.
- Formulário de agendamento e card com nome, telefone, data, produto, loja, canal e código de atendimento.
- Calendário mensal em cada loja e lista de próximas visitas.
- Avisos de agendamento para próximas 48 horas ou atrasados **quando o CRM é aberto ou atualizado**. Não são notificações push em segundo plano.
- Agendamentos salvos no Supabase com RLS por loja.

## Instalação (obrigatória nesta ordem)
1. No Supabase SQL Editor, execute `agenda.sql` para criar a tabela de agendamentos e suas políticas RLS. **Preserve as tabelas anteriores.**
2. No GitHub, substitua **somente `index.html`** pelo deste pacote. Mantenha seu `config.js` existente (com URL principal do Supabase e publishable key).
3. Aguarde GitHub Pages e atualize o navegador; entre no FIDELIZA.
4. Entre na loja > Clientes > abra uma ficha > Agendamento; salve um teste fictício.
5. Abra loja > Agendamentos; confirme que aparece no calendário e no Table Editor > fideliza_appointments.

## Notificações
Os lembretes são exibidos na interface quando o sistema carrega, atualiza ou a loja é acessada. Notificações enviadas automaticamente todos os dias, mesmo com o navegador fechado, exigem agendamento no servidor (por exemplo Supabase Cron + Edge Function ou automação externa) e não fazem parte desta versão.

## Segurança
O GitHub deve conter apenas HTML e configuração pública; não publique planilhas com dados pessoais nem chaves secretas. As regras RLS precisam estar ativas no Supabase para cada loja.

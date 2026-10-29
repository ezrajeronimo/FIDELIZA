# CRM Recorrência — UNIGAMES / Paulista Acessórios

Primeira versão demonstrativa, estática e responsiva do CRM para acompanhamento de recompra.

## Recursos
- Cards por cliente com bairro, loja, telefone, histórico resumido e acesso direto ao WhatsApp (`wa.me`).
- Recorrência identificada pelo número de registros de compra com o mesmo ID.
- Indicadores de clientes, recorrentes, taxa de recorrência e sem compras há 90 dias.
- Distribuição dos clientes por bairro, filtros por loja, região e segmento.
- Importação de CSV, com armazenamento somente no navegador (`localStorage`).

## Executar
Abra `index.html` no navegador ou publique o diretório usando GitHub Pages. Nenhuma instalação necessária.

## Modelo CSV
Clique em **Baixar modelo CSV** na aplicação. Colunas: `id;nome;telefone;loja;bairro;cidade;data;valor`.
Uma linha corresponde a uma compra. O mesmo ID agrupa o histórico de compras de um cliente. A data deve ser `AAAA-MM-DD`; valor no padrão brasileiro (`199,90`).

## Atenção — segurança e LGPD
**Não envie a base de clientes para o repositório GitHub**, nem mesmo privado sem controles apropriados. Este projeto é **um protótipo**, não um CRM multiusuário em produção. Dados importados ficam no `localStorage` do navegador e podem ser acessados por pessoas que usem o mesmo perfil do navegador. Não oferece autenticação, isolamento por loja, backups, auditoria, opt-out nem consentimento para campanhas. Antes de utilizar dados reais em escala, implementar backend seguro, login, regras de acesso por loja, criptografia, políticas de retenção, registro de finalidades e base legal, mecanismo de descadastramento e conformidade com LGPD/WhatsApp.

Os dados iniciais mostrados são completamente **fictícios**.

## Próxima versão recomendada
Next.js + Supabase (Postgres, Auth e RLS) + armazenamento seguro, importação XLS/CSV com deduplicação, integração de dados de vendas e registro de contatos e follow-ups.

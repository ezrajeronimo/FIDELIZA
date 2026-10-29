# FIDELIZA 3.0 — Premium

CRM demonstrativo com cinco módulos navegáveis: Visão Geral, Clientes, Recorrência, Campanhas e Relatórios.

## Instalação no GitHub Pages
Substitua o `index.html` da raiz do repositório FIDELIZA e confirme o commit. Aguarde publicação do GitHub Pages.

## Funções
- Importa CSV do PDV UNIGAMES (formato do relatório Guararapes) e CSV modelo.
- Consolida itens repetidos de uma venda e identifica clientes por telefone ou nome.
- Filtros por loja, bairro, forma de pagamento e recorrência.
- Cards de clientes com link WhatsApp individual.
- Indicadores de recorrência, campanhas por segmento e relatórios por loja/pagamento.
- Exportação da lista filtrada em CSV.

## Limitações e privacidade
Protótipo estático. Dados são armazenados **apenas no navegador local**; não há login, servidor, banco de dados compartilhado, controle de permissões nem disparo de mensagens. O código no GitHub Pages é público. **Nunca envie planilhas reais de clientes ao GitHub**. Para uso multiusuário real, implementar backend seguro e proteção adequada conforme LGPD.

A contagem por nome pode misturar homônimos, e o CSV PDV pode não conter dados de bairro/cidade. O filtro crediário só retorna registros explicitamente identificados como crediário; cartão de crédito é separado.

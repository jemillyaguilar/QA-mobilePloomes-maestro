# Seletores e variáveis a preencher

Todo `<<valor>>` em `config/env.<build>` (262, 263, 265) precisa ser
substituído antes da primeira execução. O `scripts/run.sh` **falha de
propósito** se sobrar algum `<<`, para não rodar a suíte com placeholder.

## Como descobrir os seletores

```bash
maestro studio      # inspetor visual: mostra id, text e accessibility label
maestro hierarchy   # dump da árvore da tela atual
```

Preferir, nesta ordem: **`id` (testID / resource-id) → texto visível →
posição**. Texto quebra quando muda o copy; posição quebra sempre.

## Variáveis

### Aplicação e credenciais
| Variável | O que é |
| --- | --- |
| `APP_ID` | package name (Android) ou bundle id (iOS) do app |
| `USUARIO` / `SENHA` | credenciais da conta de teste — ficam em `config/credenciais.local` (fora do git) |
| `USUARIO_SEM_PERMISSAO` / `SENHA_SEM_PERMISSAO` | usado só no CT36; passar por `-e` |

### Massa de teste
| Variável | O que é |
| --- | --- |
| `ENTIDADE` | Proposta, Venda ou Documento |
| `MODELO_COM_IA` | nome do Modelo de Documento com formulário de CPQ com IA publicado |
| `MODELO_SEM_IA` | nome do Modelo de Documento sem formulário com IA |

### Login
`SEL_LOGIN_EMAIL`, `SEL_LOGIN_SENHA`, `SEL_LOGIN_BOTAO`

### Navegação
| Variável | O que é |
| --- | --- |
| `SEL_FAB_NOVO` | o botão '+' do mobile |
| `TXT_MENU_ENTIDADE` | nome do item de menu/listagem da entidade |

### Web view e formulários
| Variável | O que é |
| --- | --- |
| `SEL_WEBVIEW_CPQ` | id do **container** da web view — é o que distingue "abriu" de "tela branca" |
| `TXT_TITULO_FORM_IA` | texto que só existe no formulário gerado por IA |
| `TXT_TITULO_TIRADOR` | texto que só existe no Tirador de Pedidos |
| `TXT_TITULO_FORM_PADRAO` | texto que só existe no formulário padrão atual |
| `SEL_BTN_SALVAR` | botão de salvar |

> Os três `TXT_TITULO_*` precisam ser **mutuamente exclusivos**. Toda a
> validação de roteamento (CT02, CT03, CT26–CT29, CT45) depende disso: o
> flow afirma que um está visível **e** que os outros não estão. Se os três
> compartilharem um texto, os asserts passam sem provar nada.

### Campos do formulário
`SEL_CAMPO_OBRIGATORIO`, `SEL_CAMPO_TEXTO`, `SEL_CAMPO_EFEMERO`,
`VALOR_CAMPO_TEXTO`, `VALOR_CAMPO_EFEMERO`

`SEL_CAMPO_EFEMERO` é o campo de **cálculo efêmero** — o que o CT09 prova
não persistir. Precisa ser um campo cujo valor apareça na tela como texto,
senão o `assertNotVisible` do CT09 não tem o que checar.

### Produtos
`SEL_BUSCA_PRODUTO`, `NOME_PRODUTO`, `SEL_CAMPO_QTD`, `SEL_CAMPO_DESCONTO`, `SEL_TOTAL`

### Botões flutuantes nativos
`SEL_BTN_CHECKIN`, `SEL_BTN_GRAVACAO` — usados pelos CT16 e CT17, que
provam que ficam ocultos na tela de IA e voltam ao sair dela.

### Textos de erro e confirmação
`TXT_MSG_ERRO_WEBVIEW`, `TXT_CONFIRMA_DESCARTE`, `TXT_MSG_OBRIGATORIO`, `TXT_MSG_SEM_PERMISSAO`

## Se faltar testID no app

Vários desses seletores provavelmente não existem ainda como `testID`.
Quando um elemento só for alcançável por texto ou posição, o caminho certo
é **pedir o testID ao time de mobile** em vez de amarrar o flow ao copy.
Candidatos prioritários, porque sustentam os P0:

1. container da web view do CPQ (`SEL_WEBVIEW_CPQ`)
2. botão '+' (`SEL_FAB_NOVO`)
3. botões flutuantes de check-in e gravação
4. botão salvar do formulário
5. campos de quantidade, desconto e total no bloco de produtos

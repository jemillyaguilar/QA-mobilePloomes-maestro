# Cobertura — 45 CTs da HC-29 no Maestro

Fonte dos casos: [Casos de Teste Complementares — CPQ em Branco](https://ploomes.atlassian.net/wiki/spaces/ENGPROD/pages/401276930/)
História: [HC-29](https://ploomes.atlassian.net/browse/HC-29)

**34 dos 45 CTs têm flow.** Os 11 restantes não são automatizáveis no Maestro
e seguem manuais — a razão de cada um está listada abaixo. Nenhum CT foi
silenciosamente descartado.

| Situação | Qtd | O que significa |
| --- | --- | --- |
| Automatizado | 28 | Flow roda e valida sozinho |
| Semiautomatizado | 6 | Pré-condição é feita **na web, à mão**; o flow valida o lado mobile |
| Manual / fora do Maestro | 11 | Ver motivo caso a caso |

---

## Automatizados

| CT | Flow | Build |
| --- | --- | --- |
| CT01 | `flows/ger/CT01_abrir_form_cpq_smoke.yaml` | 263 |
| CT02 | `flows/tir/CT02_modelo_com_ia_conta_com_tirador.yaml` | 262 |
| CT03 | `flows/tir/CT03_modelo_sem_ia_conta_com_tirador.yaml` | 262 |
| CT04 | `flows/reg/CT04_abrir_salvar_proposta.yaml` | 263 |
| CT05 | `flows/reg/CT05_abrir_salvar_venda.yaml` | 263 |
| CT06 | `flows/reg/CT06_abrir_salvar_documento.yaml` | 263 |
| CT09 | `flows/reg/CT09_persistencia_seletiva.yaml` | 263 |
| CT10 | `flows/err/CT10_webview_sem_conexao.yaml` | 263 + 262 |
| CT12 | `flows/err/CT12_queda_de_conexao_ao_salvar.yaml` | 263 |
| CT16 | `flows/flt/CT16_botoes_flutuantes_ocultos.yaml` | 262 + 263 |
| CT17 | `flows/flt/CT17_botoes_flutuantes_retornam.yaml` | 262 + 263 |
| CT18 | `flows/mob/CT18_voltar_android_na_webview.yaml` | 263 (Android) |
| CT19 | `flows/mob/CT19_teclado_virtual.yaml` | 263 |
| CT23 | `flows/tir/CT23_fluxo_completo_tirador.yaml` | 262 |
| CT24 | `flows/tir/CT24_alternar_ia_e_tirador.yaml` | 262 |
| CT25 | `flows/tir/CT25_tirador_e_fab_apos_form_ia.yaml` | 262 |
| CT26 | `flows/ff/CT26_ia_sim_tirador_nao_com_form.yaml` | 263 |
| CT27 | `flows/ff/CT27_ia_sim_tirador_nao_sem_form.yaml` | 263 ⚠️ |
| CT28 | `flows/ff/CT28_ia_nao_tirador_sim.yaml` | 262 |
| CT29 | `flows/ff/CT29_ia_nao_tirador_nao.yaml` | 262 + 263 |
| CT30 | `flows/fun/CT30_editar_entidade_existente.yaml` | 263 |
| CT31 | `flows/fun/CT31_validacoes_do_formulario.yaml` | 263 |
| CT32 | `flows/fun/CT32_produtos_e_tabela_de_precos.yaml` | 263 |
| CT35 | `flows/fun/CT35_duas_entidades_modelos_diferentes.yaml` | 263 |
| CT36 | `flows/fun/CT36_perfil_sem_permissao.yaml` | 263 |
| CT37 | `flows/fun/CT37_navegacao_apos_salvar.yaml` | 263 |
| CT38 | `flows/mob/CT38_formulario_grande.yaml` | 263 |
| CT45 | `flows/tir/CT45_comparacao_262_vs_263.yaml` | 262 + 263 |

⚠️ **CT27 está bloqueado por decisão de produto**, não por técnica. O flow
assume que, sem Tirador no build, abre o formulário padrão da entidade —
ponto em aberto 2 da página de CTs, a confirmar com Hugo Oliveira. Até lá,
uma falha nesse flow não é necessariamente bug.

### Verificação parcial dentro de flows automatizados

Estes flows automatizam a execução, mas parte da asserção fica no
screenshot e depende de olho humano:

- **CT19** — o *tipo* de teclado (numérico vs texto) não é assertável; conferir em `CT19_2_tipo_de_teclado`.
- **CT23 / CT32** — o flow garante que o total recalcula e fica visível, mas o **valor** tem de ser conferido contra o cálculo da web.
- **CT37** — o flow garante que voltou à listagem; a **contagem** de registros duplicados exige olhar a lista ou a web.

## Semiautomatizados — pré-condição manual na web

O setup é feito à mão na web antes de rodar; o flow valida o mobile.

| CT | Flow | Pré-condição manual |
| --- | --- | --- |
| CT07 | `flows/reg/CT07_paridade_web_mobile.yaml` | Criar/ajustar o formulário na web e publicar. A comparação visual web↔mobile é humana; o flow gera os 3 screenshots. |
| CT08 | `flows/reg/CT08_trocar_modelo_e_reabrir.yaml` | Trocar o Modelo de Documento da entidade por outro com formulário diferente. |
| CT14 | `flows/err/CT14_modelo_com_form_em_rascunho.yaml` | Deixar o formulário em rascunho, sem publicar. |
| CT15 | `flows/err/CT15_form_despublicado_apos_uso.yaml` | Criar o registro, depois despublicar/excluir o formulário. |
| CT34 | `flows/fun/CT34_entidade_sem_modelo_associado.yaml` | Remover o Modelo de Documento da entidade. |
| CT44 | `flows/flt/CT44_fab_em_tela_do_construtor_como_home.yaml` | Definir uma tela do construtor como home do app. |

## Manuais / fora do escopo do Maestro

| CT | Por quê |
| --- | --- |
| CT11 | Erro 5xx / timeout precisa ser **injetado** na resposta. O Maestro não intercepta rede. Alternativa: proxy (Charles/mitmproxy) com regra de falha, ou mock no backend — aí virá automatizável. |
| CT13 | Expiração de token não é reproduzível pela UI. Precisa invalidar a sessão pelo backend ou esperar o TTL. |
| CT20 | Rotação de tela: o Maestro não tem comando de orientação estável. Se a versão instalada expuser `setOrientation`, promover para automatizado. |
| CT21 | Não é um flow: é **matriz de execução**. A suíte 263 inteira roda nos dois SOs — ver `scripts/run-matriz-ios-android.sh`. |
| CT22 | Tela pequena / notch é avaliação **visual** de corte e alcançabilidade. Screenshots em devices reais diferentes. |
| CT33 | A conferência é **na web**, fora do app. Automatizável em Playwright, não em Maestro. |
| CT39 | Câmera e galeria abrem UI do **SO**, fora da árvore do app. O Maestro concede a permissão (`permissions: all: allow`) mas não navega na galeria de forma estável. |
| CT40 | Pré-visualizador é **web**. Playwright. |
| CT41 | Idem CT40. |
| CT42 | Idem CT40. |
| CT43 | Compara web com device físico — híbrido por definição, humano. |

**Sugestão:** CT33 e CT40–CT43 formam uma suíte Playwright natural. Se fizer
sentido, entram como `web/` neste mesmo repo — aí os 45 CTs ficam num só
lugar, com Maestro no mobile e Playwright na web.

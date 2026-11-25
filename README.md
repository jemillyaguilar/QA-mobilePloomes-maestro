# Automação Maestro — CPQ em Branco / Web View / Tirador de Pedidos

Suíte de testes E2E mobile para a história [HC-29](https://ploomes.atlassian.net/browse/HC-29),
cobrindo os casos de teste da página
[Casos de Teste Complementares — CPQ em Branco](https://ploomes.atlassian.net/wiki/spaces/ENGPROD/pages/401276930/).

## Os builds

| Build | Tirador de Pedidos | Papel na suíte |
| --- | --- | --- |
| **10.5.0 (263)** | sem | Bateria **principal**: CPQ em branco ponta a ponta, erros, mobile-específico, matriz de FF |
| **10.5.0 (262)** | com | **Visualização e não-regressão**: roteamento IA vs Tirador e garantia de que o Tirador não quebrou |
| **9.12.0 (265)** | a confirmar | Build em uso no mapeamento de seletores (`config/env.265`). Roda em emulador x86_64; a 262 não roda (`libreactnativemmkv.so` quebrado na fatia x86_64) |

A separação é por tag: cada flow tem `build262`, `build263` ou os dois.

## Estrutura

```
flows/          um arquivo por CT, agrupado pela sigla da suíte
  ger/  tir/  reg/  err/  flt/  mob/  ff/  fun/
subflows/       blocos reutilizáveis (login, abrir entidade, salvar, asserts)
config/         env.262 / env.263 / env.265 — massa e seletores por build
                credenciais.local.example — modelo do arquivo de usuário/senha
scripts/        runners
docs/           COBERTURA.md (mapa CT → flow) e SELETORES.md (o que preencher)
```

## Antes de rodar

1. **Instalar o Maestro.** Não está instalado nesta máquina. No Windows o
   caminho suportado é via WSL:
   ```bash
   curl -Ls "https://get.maestro.mobile.dev" | bash
   ```
   Conferir o método atual em https://docs.maestro.dev — o instalador muda.

2. **adb no PATH** (para Android). Também não está no PATH aqui; fica em
   `%LOCALAPPDATA%\Android\Sdk\platform-tools`.

3. **Credenciais.** Copiar `config/credenciais.local.example` para
   `config/credenciais.local` e preencher usuário e senha. Esse arquivo
   está no `.gitignore` e nunca vai para o repositório.

4. **Preencher o `config/env.<build>`.** Todo `<<valor>>` precisa ser
   substituído — ver `docs/SELETORES.md`. O runner falha de propósito se
   sobrar algum placeholder.

5. **Descobrir os seletores** com `maestro studio` no app rodando.

## Rodar

```bash
./scripts/run.sh 263           # bateria principal completa
./scripts/run.sh 263 P0        # só os P0 da 263
./scripts/run.sh 262           # não-regressão do Tirador
./scripts/run.sh 262 TIR       # só o grupo TIR
./scripts/run.sh 265           # build 265 (mapeamento atual)

./scripts/run-ct45-comparacao.sh 262    # CT45: rodar nos dois builds
./scripts/run-ct45-comparacao.sh 263

./scripts/run-matriz-ios-android.sh     # CT21: paridade entre SOs
```

Um flow isolado:

```bash
maestro test --no-reinstall-driver flows/reg/CT04_abrir_salvar_proposta.yaml -e APP_ID=... -e USUARIO=...
```

### Se o `appId` não interpolar

Os flows usam `appId: ${APP_ID}`. Se a versão instalada do Maestro não
interpolar esse campo do header, fixe o valor literal em todos os arquivos:

```bash
./scripts/set-app-id.sh com.exemplo.ploomes
```

## Tags disponíveis

- Build: `build262`, `build263`
- Prioridade: `P0`, `P1`, `P2`
- Grupo: `GER`, `TIR`, `REG`, `ERR`, `FLT`, `MOB`, `FF`, `FUN`
- Situação: `semiauto` (pré-condição manual na web), `bloqueado` (depende de decisão de produto), `android` (só Android)
- `subflow` — sempre excluída; subflows não rodam isolados

## Cobertura

**34 dos 45 CTs têm flow**; 11 seguem manuais por limitação real do Maestro
(injeção de erro HTTP, expiração de token, avaliação visual, CTs de web).
O mapa completo, com o motivo de cada um, está em
[`docs/COBERTURA.md`](docs/COBERTURA.md).

## Suíte HC-1582 — anexos off-line

Cenários da história [HC-1582](https://ploomes.atlassian.net/browse/HC-1582)
(anexar imagens e arquivos no modo off-line), da página
[Cenários de automação — HC-1582](https://ploomes.atlassian.net/wiki/spaces/ENGPROD/pages/578158623).

- **Build:** 9.15.4 (284), `config/env.284`. Roda só no AVD `Pixel_7_4k`
  (páginas de 4 KB); no Pixel_7 de 16 KB o app fecha ao abrir.
- **Conta:** Conta Teste QA CPQ (doccpq, produção). O login é manual e os
  flows não limpam o estado do app.
- **Pré-requisitos:**
  - Baixar Contatos e Negócios em Menu > Configurações off-line.
  - Copiar os arquivos de `assets/hc1582` para o aparelho:
    `adb push assets/hc1582/. //sdcard/Download/`.
  - O Photo Picker precisa ter uma única foto, a `foto-visita.jpg`.

```bash
MAESTRO=~/.maestro-cli/maestro/bin/maestro.bat ./scripts/run-hc1582.sh CEN001
```

- **Ordem:** os cenários são independentes e podem rodar em qualquer ordem.
  Cada um começa on-line, sai do modo off-line se o app reabriu nele
  (`garantir_online`) e deixa o anexo do registro com um arquivo conhecido
  (`preparar_anexo_online`), diferente do que vai anexar. Assim, nenhuma
  conferência passa por causa do que uma execução anterior deixou salvo.
- **Sincronização:** antes de sair do modo off-line, cada cenário confere que
  o aviso "Possui dados não sincronizados" está na tela, e só depois espera
  ele sumir.
- **Coordenadas:** os toques por coordenada (lupa das listagens, chave
  "Modo offline" do menu, "+" da seção Anexos, campo Descrição) só valem no
  Pixel_7_4k. Esses elementos não têm testID; o pedido ao time do app está
  em aberto.
- **CEN004:** é um esqueleto com TODO. A tag `bloqueado` está em `excludeTags`
  da `.maestro/config.yaml`, então ele não roda com a pasta inteira.

| Cenário | CTs | Situação (25/11/2026) |
| --- | --- | --- |
| CEN001 | ANX-001..004, SIN-001 | passa (a sincronização acontece ao sair do modo off-line, que é o esperado) |
| CEN002 | SIN-002 | passa |
| CEN003 | SIN-003 | passa |
| CEN004 | ERR-001, ERR-002 | bloqueado (esqueleto): falta a referência do online (tamanho máximo e mensagens) |
| CEN005 | OBS-001 | passa |
| CEN006 | ANX-006 | passa (seção "Anexos" do registro de interação, no negócio e no cliente) |

## Pendências que travam execução

1. **CT27 depende de decisão de produto** — sem Tirador na 263, qual
   formulário abre? Ponto em aberto 2 da página de CTs, a confirmar com
   Hugo Oliveira. O flow assume "formulário padrão da entidade".
2. **Seletores** — provavelmente vários elementos ainda não têm `testID`.
   Os 5 prioritários estão listados no fim de `docs/SELETORES.md`.
3. **Contas de teste** — a matriz de FF exige 4 combinações de habilitação
   (IA sim/não × Tirador sim/não) e um usuário sem permissão de criar Venda.

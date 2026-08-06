# GestãoCampo Pro V8 — Banco de Dados na Nuvem (Supabase)

Este repositório contém o GestãoCampo Pro V8 adaptado para usar **Supabase (Postgres)**
como banco de dados na nuvem, seguindo a mesma lógica já usada no OrcaSystem.

- `index.html` — o sistema completo (era `GestaoCampo_v8_Premium.html`).
- `supabase_schema.sql` — schema Postgres para colar no SQL Editor do Supabase.

## Diferença importante em relação ao OrcaSystem

O OrcaSystem guardava os dados em várias chaves separadas no `localStorage`, então
usou 19 tabelas na nuvem (uma por tipo de dado). O GestãoCampo guarda **todo o
estado do sistema num único objeto** (projetos, colaboradores, atividades,
presenças, escalas, setores, logs, funções, usuários, organograma etc.) e salva
esse objeto inteiro de uma vez. Por isso a nuvem aqui é **uma única tabela**
(`app_state`) com **uma única linha**, guardando o objeto inteiro num campo
`dados` (jsonb). Mesmo princípio de sempre: nenhuma coluna fixa por campo, então
nenhum campo novo do app quebra a sincronização.

## 1. Criar o projeto Supabase

1. Crie um novo projeto em https://supabase.com (pode ser o mesmo projeto do
   OrcaSystem ou um novo — recomendado um **novo projeto**, para manter os dados
   dos dois sistemas separados).
2. Abra **SQL Editor** → cole o conteúdo de `supabase_schema.sql` → **Run**.
3. Vá em **Settings → API** e copie a **Project URL** e a **anon public key** →
   cole nas constantes `SB_DEFAULT_URL` e `SB_DEFAULT_ANON_KEY` perto do início
   do bloco Supabase em `index.html` (não são segredo, ficam fixas no código
   para nenhuma máquina precisar configurar nada).
4. **Login unificado — sem tela extra**: o login do sistema (usuário/senha que
   já existem em `S.usuarios`) também autentica no Supabase por trás, usando um
   e-mail derivado: `usuario@gestaocampo.local` (mesma senha local). Para cada
   pessoa que vai usar o sistema em mais de uma máquina, crie a conta
   correspondente em **Authentication → Users → Add user**:
   - E-mail: `<usuario-local>@gestaocampo.local` (tudo minúsculo)
   - Senha: **a mesma senha local dessa pessoa**
   - Marque "Auto Confirm User"
   Isso é feito **uma vez por pessoa**, não por máquina — depois disso, ela loga
   normalmente em qualquer computador novo e os dados vêm sozinhos.

## 2. Publicar o sistema (GitHub Pages)

1. Crie um repositório novo no GitHub (pode reaproveitar a organização
   `OrcaSystemPro` já criada, com outro nome de repositório, ou criar um
   repositório/organização novo).
2. Suba os arquivos deste diretório (`index.html`, `supabase_schema.sql`, este
   `README.md`).
3. Em **Settings → Pages**, escolha "Deploy from a branch", branch `main`, pasta
   raiz (`/`). Se o repositório pertencer a uma organização no plano gratuito,
   o repositório precisa ser **público** para o Pages funcionar.
4. Acesse pela URL publicada (não abra o `index.html` direto do disco).

## 3. Usar o sistema numa máquina nova

Não precisa configurar nada. Acesse a URL publicada e entre com o **login local
normal** (usuário/senha do sistema). Por trás, o sistema tenta autenticar essa
mesma pessoa no Supabase automaticamente:
- Se a conta na nuvem existir (passo 1.4) → baixa os dados reais (inclusive a
  lista de usuários) antes de validar o login local, e sincroniza sozinho dali
  em diante.
- Se não existir (pessoa nova, ou conta na nuvem ainda não criada) → segue
  funcionando só localmente, sem travar nada. Basta o admin criar a conta dela
  na nuvem depois (passo 1.4) para a sincronização começar a valer.

O painel **⚙️ Config → ☁️ Supabase — Banco de Dados** continua existindo para
diagnóstico manual (botão "Testar", forçar uma sincronização completa), mas não
é mais necessário no uso do dia a dia.

## Observações importantes

- A sincronização faz **pull antes de push**: primeiro baixa o que está no
  Supabase e mescla no estado local, só depois envia de volta. Isso é
  essencial numa máquina nova (onde o estado local só tem o usuário admin
  padrão) — enviar primeiro apagaria os dados reais da nuvem antes de lê-los.
- Ainda assim, a sincronização substitui **o estado inteiro** a cada rodada —
  não há mesclagem campo a campo. Se duas pessoas editarem ao mesmo tempo e
  sincronizarem em momentos próximos, a última sincronização prevalece.
- Sincronização automática: qualquer ação que chame `save()` localmente agenda
  (com 2,5s de debounce) o envio do estado para o Supabase — sem precisar
  clicar em nada, desde que a pessoa tenha uma conta na nuvem (passo 1.4).
- A `anon public key` fica visível no código-fonte da página publicada — isso é
  esperado e seguro *desde que* o Row Level Security do `supabase_schema.sql`
  esteja ativo (exige login para qualquer leitura/escrita). Nunca desative o RLS.

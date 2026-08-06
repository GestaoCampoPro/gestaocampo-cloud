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
3. Vá em **Authentication → Users → Add user** e crie um usuário (e-mail/senha)
   para cada pessoa que vai sincronizar o sistema (marque "Auto Confirm User").
4. Vá em **Settings → API** e copie a **Project URL** e a **anon public key**.

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

## 3. Configurar o sistema

1. Acesse a URL publicada e entre com o login local do sistema.
2. Vá em **⚙️ Config → ☁️ Supabase — Banco de Dados**.
3. Cole a **Project URL** e a **Anon Public Key**.
4. Informe o **e-mail** e **senha** do usuário criado no passo 1.3 e clique em
   **🔗 Entrar**.
5. Clique em **🧪 Testar** — deve aparecer "Conectado ✅".
6. Clique no ícone ☁️ na barra superior para rodar a primeira sincronização.

## Observações importantes

- A sincronização substitui **o estado inteiro** a cada rodada (mesmo princípio
  do OrcaSystem) — não há mesclagem campo a campo. Se duas pessoas editarem ao
  mesmo tempo e sincronizarem em momentos próximos, a última sincronização
  prevalece.
- Sincronização automática: qualquer ação que chame `save()` localmente agenda
  (com 2,5s de debounce) o envio do estado inteiro para o Supabase — sem
  precisar clicar em nada.
- A `anon public key` fica visível no código-fonte da página publicada — isso é
  esperado e seguro *desde que* o Row Level Security do `supabase_schema.sql`
  esteja ativo (exige login para qualquer leitura/escrita). Nunca desative o RLS.

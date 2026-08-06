-- ============================================================================
-- GestãoCampo Pro V8 — Schema Supabase (Postgres)
-- Cole este arquivo inteiro no SQL Editor do seu projeto Supabase e rode.
--
-- Diferente do OrcaSystem (que tinha 19 chaves separadas no localStorage),
-- o GestãoCampo guarda TODO o estado do app (projetos, colaboradores,
-- atividades, presenças, escalas, setores, logs, funções, usuários,
-- organograma etc.) num único objeto JS ("S"), salvo como um blob JSON
-- só numa chave do localStorage. Por isso o banco na nuvem é só UMA
-- tabela, com uma linha guardando esse objeto inteiro em "dados" (jsonb).
--
-- Segurança: Row Level Security exige usuário autenticado (Supabase Auth).
-- Sem login, a anon key pública (visível no HTML hospedado) não lê nem
-- escreve nada.
-- ============================================================================

drop table if exists public.app_state cascade;

create table public.app_state (
  id text primary key,
  dados jsonb not null,
  updated_at timestamptz not null default now()
);

alter table public.app_state enable row level security;

create policy "auth_full_access" on public.app_state
  for all to authenticated using (true) with check (true);

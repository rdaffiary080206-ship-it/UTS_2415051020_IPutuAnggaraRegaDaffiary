-- =====================================================================
-- Cinemay — skema database Supabase (PostgreSQL)
-- Jalankan di Supabase Dashboard > SQL Editor > New query > Run.
-- =====================================================================

create table if not exists public.watchlist (
  id               bigint generated always as identity primary key,
  show_id          integer,                          -- ID show di TVMaze (null jika input manual)
  title            text        not null check (char_length(title) between 1 and 200),
  poster_url       text,
  genres           text        not null default '',
  status           text        not null default 'plan_to_watch'
                   check (status in ('plan_to_watch', 'watching', 'completed', 'dropped')),
  personal_rating  numeric(3,1) check (personal_rating between 1 and 10),
  progress         text        not null default '',
  note             text        not null default '',
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

-- Satu show TVMaze hanya boleh tersimpan sekali di watchlist.
create unique index if not exists watchlist_show_id_key
  on public.watchlist (show_id) where show_id is not null;

-- Perbarui updated_at otomatis setiap kali baris di-update.
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists watchlist_set_updated_at on public.watchlist;
create trigger watchlist_set_updated_at
  before update on public.watchlist
  for each row execute function public.set_updated_at();

-- Row Level Security.
-- Aplikasi ini tidak memakai login, jadi role `anon` diberi akses CRUD
-- ke tabel ini saja. Cukup untuk keperluan tugas/demo; untuk aplikasi
-- produksi, tambahkan autentikasi dan batasi per user (auth.uid()).
alter table public.watchlist enable row level security;

drop policy if exists "anon can read watchlist" on public.watchlist;
create policy "anon can read watchlist"
  on public.watchlist for select to anon using (true);

drop policy if exists "anon can insert watchlist" on public.watchlist;
create policy "anon can insert watchlist"
  on public.watchlist for insert to anon with check (true);

drop policy if exists "anon can update watchlist" on public.watchlist;
create policy "anon can update watchlist"
  on public.watchlist for update to anon using (true) with check (true);

drop policy if exists "anon can delete watchlist" on public.watchlist;
create policy "anon can delete watchlist"
  on public.watchlist for delete to anon using (true);

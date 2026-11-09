-- Mitmate core schema (Sprint 1 + foundations for Sprints 2-6)
-- Host the Supabase project in an EU region (Frankfurt).

create extension if not exists postgis;

-- ---------- enums ----------
create type app_language as enum ('de', 'en');
create type city_code as enum ('berlin', 'hamburg');
create type swipe_direction as enum ('yes', 'no');
create type match_status as enum ('active', 'unmatched', 'confirmed', 'closed');
create type report_status as enum ('open', 'reviewing', 'closed');
create type split_method as enum ('equal', 'custom');

-- ---------- profiles (public-facing) ----------
create table profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null check (char_length(display_name) between 1 and 40),
  bio text check (char_length(bio) <= 600),
  birth_year int not null check (birth_year <= extract(year from now())::int - 18),
  gender text,                         -- self-described, shown only if the user chooses
  occupation text,
  language app_language not null default 'de',
  city city_code not null,
  photo_path text,
  smokes boolean,
  drinks text check (drinks in ('never','sometimes','often')),
  food_habit text check (food_habit in ('everything','vegetarian','vegan','halal','kosher','other')),
  cleanliness smallint check (cleanliness between 1 and 5),
  guests_ok text check (guests_ok in ('never','sometimes','often')),
  phone_verified boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ---------- sensitive details (GDPR Art. 9): separate, consent-gated ----------
create table sensitive_details (
  user_id uuid primary key references auth.users(id) on delete cascade,
  orientation text,
  ethnicity text,                      -- optional, shared only if user chooses; NOT a filter
  show_orientation boolean not null default false,
  show_ethnicity boolean not null default false,
  consent_given_at timestamptz not null,
  consent_text_version text not null,
  updated_at timestamptz not null default now()
);

create table consent_log (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  kind text not null,                  -- e.g. 'sensitive_details', 'analytics'
  granted boolean not null,
  text_version text not null,
  created_at timestamptz not null default now()
);

-- ---------- flats / vacancies ----------
create table flats (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  city city_code not null,
  district text,
  area geography(point, 4326),         -- approximate location only
  rent_cents int check (rent_cents >= 0),
  room_size_sqm numeric(5,1),
  current_flatmates smallint not null default 1,
  available_from date,
  description text check (char_length(description) <= 1000),
  is_open boolean not null default true,
  created_at timestamptz not null default now()
);
create index flats_city_open_idx on flats (city) where is_open;

-- ---------- matching preferences ----------
create table preferences (
  user_id uuid primary key references auth.users(id) on delete cascade,
  wants_genders text[] not null default '{}',        -- empty = open to all
  wants_orientations text[] not null default '{}',   -- empty = open to all
  age_min smallint not null default 18 check (age_min >= 18),
  age_max smallint not null default 99,
  max_rent_cents int,
  smoking_ok boolean,
  drinking_max text check (drinking_max in ('never','sometimes','often')),
  food_habits text[] not null default '{}',
  updated_at timestamptz not null default now()
);

-- ---------- swipes and matches ----------
create table swipes (
  swiper_id uuid not null references auth.users(id) on delete cascade,
  target_id uuid not null references auth.users(id) on delete cascade,
  direction swipe_direction not null,
  created_at timestamptz not null default now(),
  primary key (swiper_id, target_id),
  check (swiper_id <> target_id)
);

create table blocks (
  blocker_id uuid not null references auth.users(id) on delete cascade,
  blocked_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (blocker_id, blocked_id),
  check (blocker_id <> blocked_id)
);

create table matches (
  id uuid primary key default gen_random_uuid(),
  user_a uuid not null references auth.users(id) on delete cascade,
  user_b uuid not null references auth.users(id) on delete cascade,
  status match_status not null default 'active',
  created_at timestamptz not null default now(),
  check (user_a < user_b),
  unique (user_a, user_b)
);

-- A match exists only when BOTH sides swiped yes and neither blocked the other.
create or replace function create_match_on_mutual_yes() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if new.direction = 'yes'
     and exists (select 1 from swipes s
                 where s.swiper_id = new.target_id and s.target_id = new.swiper_id
                   and s.direction = 'yes')
     and not exists (select 1 from blocks b
                     where (b.blocker_id = new.swiper_id and b.blocked_id = new.target_id)
                        or (b.blocker_id = new.target_id and b.blocked_id = new.swiper_id))
  then
    insert into matches (user_a, user_b)
    values (least(new.swiper_id, new.target_id), greatest(new.swiper_id, new.target_id))
    on conflict do nothing;
  end if;
  return new;
end $$;

create trigger swipes_mutual_yes after insert on swipes
for each row execute function create_match_on_mutual_yes();

-- ---------- chat ----------
create table messages (
  id bigint generated always as identity primary key,
  match_id uuid not null references matches(id) on delete cascade,
  sender_id uuid not null references auth.users(id) on delete cascade,
  body text not null check (char_length(body) between 1 and 2000),
  created_at timestamptz not null default now()
);
create index messages_match_idx on messages (match_id, created_at);

-- ---------- choose: both must confirm ----------
create table confirmations (
  match_id uuid not null references matches(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  confirmed boolean not null,
  created_at timestamptz not null default now(),
  primary key (match_id, user_id)
);

-- ---------- agree: house rules, each accepted by both ----------
create table house_rules (
  id uuid primary key default gen_random_uuid(),
  match_id uuid not null references matches(id) on delete cascade,
  category text not null check (category in
    ('quiet_hours','guests','food','cleaning','rent_split','groceries','other')),
  title text not null,
  details text,
  proposed_by uuid not null references auth.users(id),
  created_at timestamptz not null default now()
);

create table rule_acceptances (
  rule_id uuid not null references house_rules(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  accepted boolean not null,
  created_at timestamptz not null default now(),
  primary key (rule_id, user_id)
);

-- ---------- live: chores and shared costs ----------
create table chores (
  id uuid primary key default gen_random_uuid(),
  match_id uuid not null references matches(id) on delete cascade,
  title text not null,
  assigned_to uuid references auth.users(id),
  due_date date,
  done boolean not null default false
);

create table expenses (
  id uuid primary key default gen_random_uuid(),
  match_id uuid not null references matches(id) on delete cascade,
  paid_by uuid not null references auth.users(id),
  description text not null,
  amount_cents int not null check (amount_cents > 0),
  split split_method not null default 'equal',
  created_at timestamptz not null default now()
);

-- ---------- safety ----------
create table reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references auth.users(id) on delete cascade,
  reported_id uuid not null references auth.users(id) on delete cascade,
  match_id uuid references matches(id) on delete set null,
  reason text not null,
  details text,
  status report_status not null default 'open',
  created_at timestamptz not null default now()
);

-- ---------- row level security ----------
alter table profiles enable row level security;
alter table sensitive_details enable row level security;
alter table consent_log enable row level security;
alter table flats enable row level security;
alter table preferences enable row level security;
alter table swipes enable row level security;
alter table blocks enable row level security;
alter table matches enable row level security;
alter table messages enable row level security;
alter table confirmations enable row level security;
alter table house_rules enable row level security;
alter table rule_acceptances enable row level security;
alter table chores enable row level security;
alter table expenses enable row level security;
alter table reports enable row level security;

create or replace function is_match_member(m uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from matches
                 where id = m and auth.uid() in (user_a, user_b)
                   and status in ('active','confirmed'));
$$;

create or replace function is_blocked_between(a uuid, b uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from blocks
                 where (blocker_id = a and blocked_id = b) or (blocker_id = b and blocked_id = a));
$$;

-- profiles: own row full access; others readable unless blocked
create policy profiles_own on profiles for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy profiles_read on profiles for select to authenticated
  using (not is_blocked_between(auth.uid(), user_id));

-- sensitive details and consent: owner only (never readable by others through the API)
create policy sensitive_own on sensitive_details for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy consent_own on consent_log for all using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy flats_own on flats for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
create policy flats_read on flats for select to authenticated
  using (is_open and not is_blocked_between(auth.uid(), owner_id));

create policy prefs_own on preferences for all using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy swipes_insert on swipes for insert with check (swiper_id = auth.uid());
create policy swipes_read on swipes for select using (swiper_id = auth.uid());

create policy blocks_own on blocks for all using (blocker_id = auth.uid()) with check (blocker_id = auth.uid());

create policy matches_read on matches for select using (auth.uid() in (user_a, user_b));
create policy matches_leave on matches for update using (auth.uid() in (user_a, user_b))
  with check (status in ('unmatched','closed') or status = 'active' or status = 'confirmed');

create policy messages_read on messages for select using (is_match_member(match_id));
create policy messages_send on messages for insert with check (sender_id = auth.uid() and is_match_member(match_id));

create policy confirmations_read on confirmations for select using (is_match_member(match_id));
create policy confirmations_write on confirmations for insert with check (user_id = auth.uid() and is_match_member(match_id));
create policy confirmations_update on confirmations for update using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy rules_read on house_rules for select using (is_match_member(match_id));
create policy rules_write on house_rules for insert with check (proposed_by = auth.uid() and is_match_member(match_id));
create policy acceptances_read on rule_acceptances for select
  using (exists (select 1 from house_rules r where r.id = rule_id and is_match_member(r.match_id)));
create policy acceptances_write on rule_acceptances for insert with check (user_id = auth.uid());
create policy acceptances_update on rule_acceptances for update using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy chores_all on chores for all using (is_match_member(match_id)) with check (is_match_member(match_id));
create policy expenses_all on expenses for all using (is_match_member(match_id)) with check (is_match_member(match_id));

create policy reports_insert on reports for insert with check (reporter_id = auth.uid());
create policy reports_read_own on reports for select using (reporter_id = auth.uid());

-- ---------- storage: private profile photos ----------
insert into storage.buckets (id, name, public) values ('profile-photos', 'profile-photos', false)
on conflict do nothing;
create policy photos_own_write on storage.objects for insert to authenticated
  with check (bucket_id = 'profile-photos' and (storage.foldername(name))[1] = auth.uid()::text);
create policy photos_own_update on storage.objects for update to authenticated
  using (bucket_id = 'profile-photos' and (storage.foldername(name))[1] = auth.uid()::text);
create policy photos_read on storage.objects for select to authenticated
  using (bucket_id = 'profile-photos');

-- ---------- account deletion helper (GDPR erasure) ----------
create or replace function delete_my_account() returns void
language plpgsql security definer set search_path = public, auth as $$
begin
  delete from auth.users where id = auth.uid();   -- cascades through every table above
end $$;
revoke all on function delete_my_account() from public;
grant execute on function delete_my_account() to authenticated;

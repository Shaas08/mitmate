# Mitmate

Find a flatmate you will actually live well with. Match, Choose, Agree, Live.
Mobile app for Germany, Berlin and Hamburg first, UI in German and English.

## Stack
| Layer | Choice |
| --- | --- |
| Mobile | Flutter (iOS and Android), Riverpod, go_router |
| Backend | Supabase (Postgres, Auth, Realtime, Storage), EU region |
| CI | GitHub Actions: analyze and test the app, run migrations on a fresh database |

## Layout
- `app/` Flutter app. Sprint 1 screens: login and sign-up, language switch, profile, matching preferences, consent for sensitive details, delete account. Swipe screen is a placeholder for Sprint 2.
- `supabase/migrations/` full schema with row-level security, mutual-match trigger, private photo bucket, account deletion function.
- `research/` questionnaire page and Google Form script.
- `docs/` links to Vision and Planning.

## Run it
1. Create a Supabase project in the Frankfurt region.
2. Apply the schema: `supabase link --project-ref <ref>` then `supabase db push`.
3. In Supabase Auth settings, turn on email confirmation, and add Apple and Google sign-in later.
4. `cd app && cp ../.env.example .env` and fill in the URL and publishable key.
5. `flutter pub get && flutter gen-l10n && flutter run`.

## Sprint 1 status
Built as scaffolding, not yet run on a device: sign-up and log-in, language, city, profile, preferences, consent, delete account.
Not built yet: Apple and Google sign-in, phone verification, photo upload (storage bucket and policies exist), tests beyond a placeholder.

## Rules the database enforces
- A match exists only when both people swiped yes and neither blocked the other.
- Sensitive details are readable only by their owner.
- Messages, rules, chores and expenses are visible only to the two people in a match.

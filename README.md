# NdaMinkoaba — Ewondo Learning Smart Platform

A mobile-first language-learning app for **Ewondo**, a Bantu language spoken in Cameroon. Learners progress through **Beginner → Intermediate → Advanced** courses, take quizzes, and earn a generated PDF/QR certificate on completion. Two user-facing roles: **Learner** and **Administrator**.

- **Frontend:** Flutter (`ndaminkoaba_app/`) — go_router, Dio
- **Backend:** NestJS + Prisma + PostgreSQL (`backend-api/`) — JWT auth, role-based access control, server-side quiz grading, PDF/QR certificate generation, an AI tutor ("Nnanga") backed by OpenRouter

## Architecture

```
ndaminkoaba_app/  (Flutter client)
      |
      |  HTTP + JWT bearer token
      v
backend-api/      (NestJS REST API, prefix /api)
      |
      v
PostgreSQL (via Prisma ORM)
```

The API wraps every response as `{ success, data, timestamp }` (or `{ success: false, error: { message, error, statusCode } }` on failure). Auth uses short-lived JWTs (7 days by default); the client attaches `Authorization: Bearer <token>` automatically once logged in.

## Getting it running locally

### 1. Backend

```bash
cd backend-api
npm install                 # runs `prisma generate` automatically via postinstall
```

Make sure PostgreSQL is running locally and matches `backend-api/.env`'s `DATABASE_URL` (defaults to `postgresql://postgres:1234@localhost:5432/ewondo_learning` — change the password/db name there if yours differs, then create the database: `createdb ewondo_learning` or via pgAdmin).

```bash
npx prisma migrate deploy   # applies the existing migrations in prisma/migrations
npx prisma db seed          # creates demo accounts + one PUBLISHED course per level
npm run start:dev           # http://localhost:3000/api, Swagger docs at /api/docs
```

Demo accounts created by the seed script (all use password `Passw0rd!`):

| Role    | Email                     | Notes |
|---------|---------------------------|-------|
| Admin   | admin@ndaminkoaba.com     | Full access to the Administrator app (Dashboard, Users, Courses, Certificates) |
| Teacher | teacher@ndaminkoaba.com   | Backend-only role — content can be attributed to a teacher, but there is no separate teacher UI (see "Role model" below) |
| Learner | learner@ndaminkoaba.com   | Pre-enrolled in the Beginner course |

**Before a real deployment:** rotate `JWT_SECRET` and `OPENROUTER_API_KEY` in `.env` — both were pasted into a chat session at some point and should be treated as no longer private.

### 2. Frontend

```bash
cd ndaminkoaba_app
flutter pub get
flutter run                 # or: flutter run -d chrome / -d windows
```

`lib/config/app_config.dart` points at `http://127.0.0.1:3000/api` by default. If you run the app on a physical device or Android emulator, change this to your machine's LAN IP (Android emulators specifically should use `http://10.0.2.2:3000/api` to reach the host machine).

## Role model

The database still has three roles (`ADMIN`, `TEACHER`, `LEARNER`) — courses can optionally be attributed to a teacher — but the **app only ever presents two experiences**: Learner and Administrator. There is no teacher login screen. Registration always creates a `LEARNER` (the client can't request another role); an Administrator promotes a user to `ADMIN` from the Users screen.

## The three levels

`Course.level` and `Vocabulary.difficulty` are a `BEGINNER | INTERMEDIATE | ADVANCED` enum. The seed script creates one published course per level, each with a module, lesson, vocabulary word, and quiz. Learners filter both the Courses and Vocabulary screens by level.

## Certificates

A certificate can only be issued (`POST /certificates`) once the backend independently verifies every lesson in the course is completed and every quiz passed — the learner's claimed score is never trusted for this check. Once issued, `POST /certificates/:id/generate-pdf` renders a PDF with a QR code linking to the public, unauthenticated verification endpoint (`GET /certificates/verify/:code`).

## The Administrator app

From `/admin`, an Administrator can:

- **Manage content through five dedicated sections** (the Courses tab opens a "Content Management" hub linking to each): **Course**, **Module**, **Lesson**, **Vocabulary**, and **Quiz Management**. Each is a flat, filterable, searchable list with full create/edit/delete for that entity — e.g. Lesson Management shows every lesson across every course with a "Course › Module" breadcrumb and a clearly-numbered "Lesson N" (numbering is scoped per module, so a new module always starts again at Lesson 1). Deleting something that still has dependents (a module with lessons, a lesson with a quiz) returns a clean "still depends on this" error instead of a raw 500 — the API's global exception filter now translates Postgres FK-constraint failures into a proper 409.
  - The per-course editor (opened from Course Management) still supports adding modules/lessons inline for quick in-context authoring; both paths write to the same data.
  - Quiz Management links through to a question builder: add multiple-choice questions and tap a choice to mark it correct (only one per question); edit or delete existing questions the same way.
- **Manage users** — search/list every account, create one directly with a temporary password and a role, promote/demote between Learner and Administrator, and activate/deactivate accounts.
- **Train the AI** — Nnanga isn't a fine-tuned model; it's retrieval-augmented — `POST /nnanga/chat` searches the `Vocabulary`/`Lesson` tables for keyword matches, feeds whatever it finds to the LLM as context, and falls back to a generic "I don't know" if nothing matches. The Train the AI screen makes that loop visible: a "Test Nnanga" console shows whether a given question found a local-knowledge match (with a shortcut into Vocabulary Management if not), plus a feed of learners' real questions so gaps are easy to spot and fill.
- **Broadcast announcements** — one dialog sends a notification to every learner at once (`POST /notifications/broadcast`).
- **See the platform at a glance** — the dashboard has quick-action shortcuts to all of the above, a courses-by-level bar chart, a users-by-role breakdown, and a recent-certificates activity feed, backed by a `GET /dashboard/admin` that returns grouped counts instead of just totals. These stats are global (not scoped to the logged-in admin), so every Administrator account sees identical numbers.

## What this pass added

Starting point: a real, fairly complete backend (25 modules, 21 database models) with several authorization gaps, and a Flutter app that only called 2 of ~15 endpoint groups.

**Backend**
- Fixed all `tsc --noEmit` errors (isolatedModules `import type` violations, a JWT `expiresIn` type mismatch)
- Quiz grading is now fully server-side: `POST /quiz-attempts` takes `{questionId, choiceId}` answers, not a client-supplied score — the score/pass flag can no longer be forged
- Closed an answer-leak in `GET /quizzes`: it embedded every choice's `isCorrect` unredacted and had no auth guard at all
- Added admin user management (`GET /users`, `GET/PATCH /users/:id`) so an Administrator can list, search, promote, and deactivate accounts
- Expanded the seed script to one published course per level instead of just Beginner
- Verified the previously-flagged IDOR/certificate-auth/quiz-answer-redaction fixes are actually in place across progress, quiz-attempts, bookmarks, enrollments, notifications, nnanga, and certificates

**Frontend** — built out the screens that only existed as "Coming soon" stubs or didn't exist at all:
- Quiz-taking flow (question/choice UI, submission, pass/fail results with per-question review)
- Certificates (list, detail with QR/PDF, claim-when-eligible button on the course screen)
- Vocabulary browser (search + level filter)
- Nnanga AI chat (markdown-rendered replies)
- Profile (view/edit name & password, logout)
- A full Administrator app: dashboard stats, user management, course publish/draft/archive, issued-certificates list
- Wired lesson completion and course progress to the real `/progress` API (previously tracked only in local `SharedPreferences`, so the server never knew what a learner had completed)
- Auto-enrollment when a course is opened, and role-based routing after login (`ADMIN` → Administrator app, `LEARNER` → learner app)
- Fixed API error-message parsing app-wide (it read `data['message']`/`data['error']` as a flat string; the backend's actual envelope nests the message under `error.message`, so failed requests were showing a raw stringified object instead of the real message)
- Removed dead code (duplicate `AppColors` class, orphaned module models/repository) that had already been emptied out but not deleted
- `flutter analyze` and `npx tsc --noEmit` are both clean

Full findings from the original audit are in `NdaMinkoaba_Audit_Findings.md` at the repo root (historical — several items there are now resolved; see above).

## What this second pass added

The Administrator experience above was built in a follow-up pass, plus three real bugs it surfaced along the way:

- **`POST /nnanga/chat` was completely broken.** `CreateNnangaChatDto.userId` was a required field, but the controller always overrides it with the authenticated user's id and no real client ever sends it — every chat request from the app was rejected by validation before reaching the controller. Made the field optional (it was always ignored anyway).
- **Deleting a lesson/module/question with dependents leaked a raw 500.** Nothing in this schema uses `onDelete: Cascade`, so Postgres's default RESTRICT rejected the query — and that rejection surfaced as an unhandled `PrismaClientUnknownRequestError`. The global exception filter now recognizes FK-constraint and unique-constraint failures and returns a clean 409 instead.
- **A 401 from an expired/invalid token cleared the stored token but never redirected to `/login`**, so every screen just silently showed empty/zero data with no indication why. `ApiClient` now force-navigates to `/login` on any 401 that isn't the login request itself, via a `GlobalKey<NavigatorState>` so the Dio interceptor doesn't need a `BuildContext`.

Also added: `POST /users` (admin-create with any role), `POST /notifications/broadcast`, and `GET /dashboard/admin` now returns `usersByRole`/`coursesByLevel`/`recentCertificates` alongside the existing totals.

## What this third pass added

- **First-login welcome screen.** `User.lastLogin` (already in the schema, never actually written) is now set on every successful login; since it starts `null`, "never logged in before" is exactly "this is their first login." `POST /auth/login` returns an `isFirstLogin` flag alongside the token. The Flutter login screen routes a first-time learner to `/welcome` (a full-bleed hero screen with their first name and the three levels) instead of straight to the dashboard; every later login goes straight to the dashboard with a "Welcome back" message. Administrators are unaffected — they always go straight to `/admin`.
  - The welcome screen's hero photo lives at `ndaminkoaba_app/assets/images/welcome_hero.jpg` (`assets/images/` is already declared as a whole-directory asset in `pubspec.yaml`, so dropping a file there is enough — no config change needed). Until that file exists, the screen falls back to a green gradient so it still looks intentional.
- **Premium visual pass on learner-facing screens**: login, register, dashboard, and courses screens now share the same gradient-hero / soft-background language already used across the Administrator app — gradient banners with stat pills, colored circular icons per action/level, and a consistent cream-to-background gradient on the two auth screens.

## What this fourth pass added

**Google and Facebook sign-in**, alongside the existing email/password registration (which was already `@IsEmail`-validated — no server-side email-verification flow was added). Both providers use the same pattern: the Flutter client gets a token directly from Google/Facebook, hands it to the backend, which verifies it server-side and issues the platform's own JWT — identical to the email/password flow from there on (`isFirstLogin`, `/welcome` routing, etc. all just work).

- **Backend**: `POST /auth/google` (verifies the ID token via `google-auth-library`'s `OAuth2Client.verifyIdToken`) and `POST /auth/facebook` (verifies the access token by calling the Graph API `/me` endpoint with an `appsecret_proof`, Facebook's anti-replay measure). `User.passwordHash` is now nullable and `User.googleId`/`User.facebookId` were added — `UsersService.findOrCreateOAuthUser` links a provider id onto an existing password account if the emails match, rather than creating a duplicate. Emails are lowercased/trimmed everywhere (`normalizeEmail` in `common/utils/helpers.ts`) so `Foo@x.com`/`foo@x.com` can never become two accounts.
- **Frontend**: `google_sign_in` + `flutter_facebook_auth` power a `OrDivider` + two `OAuthButton`s on both the login and register screens, sharing the same post-auth navigation as the email/password path (`lib/features/auth/presentation/post_login.dart`).

### OAuth sign-in setup

Both providers are disabled out of the box and fail gracefully (a "not configured yet" snackbar, not a crash) until you provide real credentials:

**Google** — console.cloud.google.com → configure the OAuth consent screen → create 3 OAuth Client IDs (Web, Android, iOS):
- Web: add your dev/prod origins to Authorized JavaScript origins.
- Android: needs this app's `applicationId` (`android/app/build.gradle.kts`) + your keystore's SHA-1 (`keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`).
- iOS: needs the bundle ID (`ios/Runner.xcodeproj/project.pbxproj`).
- Put the **Web** Client ID in `ndaminkoaba_app/lib/config/app_config.dart` (`googleWebClientId`) and in `ndaminkoaba_app/web/index.html`'s `google-signin-client_id` meta tag. Put the **comma-separated list of all 3** Client IDs in `backend-api/.env`'s `GOOGLE_CLIENT_ID` (the backend accepts a token minted for any of them).
- iOS also needs its Client ID's reversed form in `ios/Runner/Info.plist`'s `CFBundleURLTypes` (replace `REPLACE_WITH_REVERSED_CLIENT_ID`).

**Facebook** — developers.facebook.com → Create App (Consumer) → add the Facebook Login product → Settings → Basic for the App ID/Secret:
- Add your Web origin, and for Android your package name + key hash (`keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore | openssl sha1 -binary | openssl base64`), for iOS your bundle ID, under Facebook Login → Settings.
- Put the App ID/Secret in `backend-api/.env`'s `FACEBOOK_APP_ID`/`FACEBOOK_APP_SECRET`.
- Android: `ndaminkoaba_app/android/app/src/main/res/values/strings.xml` (`facebook_app_id`, `facebook_client_token`, `fb_login_protocol_scheme`).
- iOS: `ios/Runner/Info.plist` (`FacebookAppID`, `FacebookClientToken`, and the `fbYOUR_FACEBOOK_APP_ID` URL scheme).
- Web: `ndaminkoaba_app/lib/config/app_config.dart`'s `facebookAppId` (the JS SDK is initialized lazily on first use, no `index.html` edit needed — `flutter_facebook_auth_web` injects its own script tag).

## Known limitations / next steps

- No automated tests exist yet on either side beyond the default NestJS boilerplate spec.
- Bookmarks have backend support but no frontend or admin screen.
- The course editor supports create/edit/delete for courses, modules, lessons, quizzes, and questions, but not reordering (`orderNumber` is always appended) or editing a question's choices after creation (delete and re-add instead).
- No image/audio upload UI yet for lesson or vocabulary media — `audioUrl`/`videoUrl`/`imageUrl` fields exist on the backend but the admin forms don't expose them.
- The welcome-screen hero photo needs to be manually placed at `ndaminkoaba_app/assets/images/welcome_hero.jpg` — it wasn't retrievable from the chat attachment directly.

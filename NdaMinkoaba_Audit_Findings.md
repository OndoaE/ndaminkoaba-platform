# NdaMinkoaba — Engineering Audit Findings

**Project:** Ewondo Learning Smart Platform ("NdaMinkoaba")
**Stack:** Flutter (frontend) + NestJS/Prisma/PostgreSQL (backend, `backend-api`)
**Date:** July 10, 2026

This is more built-out than a typical student project — 21 database models, 25 backend modules, real Prisma queries throughout, a working auth flow. The gap to "runs professionally" is real but bounded: a handful of hard blockers, a real security posture problem, and a frontend that talks to only 2 of ~15 available endpoint groups.

## 1. Hard blockers — nothing runs until these are fixed

| # | Issue | Fix |
|---|---|---|
| 1 | Prisma client never generated (no `node_modules/.prisma`, no `postinstall` script) | Run `npx prisma generate`, add it as a `postinstall` script |
| 2 | No `prisma/migrations`, no seed script | Generate an initial migration from the schema, write a seed script (languages/courses/a demo user) so the app isn't empty on first run |
| 3 | Flutter `pubspec.yaml` declares `assets/images/`, `assets/icons/`, `assets/audio/` — none exist on disk | Create the folders (with placeholder/real assets), or remove the declarations — either way, `flutter build`/`run` will fail otherwise |
| 4 | `ApiClient` (Dio) never attaches the JWT — `StorageService.getToken()` is saved but never read | Add an auth interceptor; without it, any guarded endpoint (basically everything except courses list/detail) 401s |
| 5 | Postgres must be running locally (`localhost:5432/ewondo_learning`, password `1234` from `.env`) | Confirmed reachable in your dev setup — I'll verify in the sandbox |

## 2. Security — needs fixing before this is "professional," not just "runs"

- **Certificates endpoints have no auth guard at all** — anyone can create/delete/regenerate certificates for any user/course.
- **Systemic IDOR** across progress, quiz-attempts, bookmarks, enrollments, notifications, and the AI chat (`nnanga`): every one of these takes `userId` from the request body/query instead of the authenticated JWT principal. Any logged-in learner can read or write another user's data by guessing their UUID.
- **Quiz answers are public**: `GET /questions` and `GET /choices` are unauthenticated and include `isCorrect` — a student could fetch answers before taking a quiz.
- **`GET /dashboard/learner/:userId`** has no ownership check — any authenticated user can view anyone else's dashboard.
- **Weak JWT secret** (`"EwondoLearningSmartPlatform2026"` — literally the app name) and a **live OpenRouter API key sitting in a plaintext `.env`** that's already been exposed in this chat. Both should be rotated; `.env` is correctly git-ignored so this is contained as long as no one force-adds it.
- `register.dto.ts`'s optional `role` field is missing `@IsOptional()` — likely rejects any registration request that omits `role` under the strict global `ValidationPipe`.
- One thing that *is* solid: no SQL injection surface (Prisma query builder throughout, no raw SQL), passwords are properly bcrypt-hashed, and input validation via `class-validator` is applied consistently elsewhere.

## 3. Frontend ↔ backend integration gaps

The backend exposes ~25 resource modules (auth, courses, course-modules, lessons, vocabulary, categories, pronunciations, quizzes, questions, choices, progress, quiz-attempts, certificates, bookmarks, dashboard, notifications, enrollments, nnanga AI chat...). The Flutter app currently only calls **two** of them for real:

- `POST /auth/login` ✅ wired (registration screen is a UI stub with no form or service call)
- `GET /courses`, `GET /courses/:id` ✅ wired

Everything else the UI shows is **mocked client-side and never talks to the backend**:
- Lessons (`LessonRepository`) — hardcoded 4 lessons, ignores the real `courseId`
- Modules (`ModuleRepository`) — hardcoded, and not even wired into any screen (dead code)
- Dashboard — entirely static ("72% completed", fixed greeting, no data fetch at all)
- Progress, quiz attempts, certificates, bookmarks, notifications, AI chat — no frontend code calls any of these yet

There's also a naming/shape drift to reconcile once lessons/modules go live for real (`orderNumber` vs `order`, response envelope is `{success, data, timestamp}` from a global interceptor — the login/course parsing already accounts for a `data` wrapper, needs to stay consistent as more calls are added).

## 4. Code quality / dead code

- Two different `AppColors` classes with different hex values (`core/constants` vs `design_system/colors`) — splash and register screens render slightly different tones than the rest of the app because they import the wrong one.
- `register_screen.dart` and `splash_screen.dart` don't use the design system at all (raw `Text`/`Scaffold`), while every other screen does — visually inconsistent.
- Debug `print()` calls in `auth_service.dart`, including one that **logs the plaintext password**.
- Duplicate/orphaned domain models (`module.dart` vs `course_module.dart`, unused `LessonDetail`), an empty `UsersController`, four 0-byte guard/decorator stub files, an empty password-validator stub.
- `flutter_riverpod` is a dependency but literally unused beyond wrapping `ProviderScope` — every screen manages its own state ad-hoc. Not wrong, but it means no shared session/user state (the dashboard can't even show the real logged-in user's name right now).
- Zero automated tests on the Flutter side; backend has the default NestJS boilerplate spec only.

## 5. What's already solid

- Real Prisma-backed CRUD for every content module (courses, modules, lessons, vocabulary, categories, pronunciations, quizzes) — not mocks.
- Clean layered structure on both sides (controller/service/DTO on the backend; presentation/data/domain on the frontend).
- Swagger is wired (`/api/docs`), global validation pipe, helmet, response/exception interceptors for a consistent API envelope.
- The design system (colors, spacing, typography, reusable widgets) is genuinely good and consistently used where it's used.

---

**Proposed order of work**, given you asked for "connect the backend and frontend" plus code quality, security, docs, and a UI/UX pass:

1. Fix the hard blockers → get the backend running and the Flutter app building
2. Wire the auth token interceptor + fix the IDOR/certificate-auth issues (security can't wait — this is the app's data integrity)
3. Wire the frontend's mocked screens (lessons, modules, dashboard, registration) to the real endpoints
4. Code quality cleanup (dedupe colors, remove dead code/stubs, fix print/logging)
5. UI/UX consistency pass on the two screens that don't use the design system
6. Docs (README, setup guide, API overview) for your defense

Let me know if you want to reorder this, or if there's anything here you already knew about and want me to skip.

# NdaMinkoaba API

NestJS + Prisma + PostgreSQL backend for the NdaMinkoaba (Ewondo Learning Smart Platform) app. See the [root README](../README.md) for the full project overview and setup instructions.

## Quick start

```bash
npm install                 # runs `prisma generate` via postinstall
npx prisma migrate deploy   # apply existing migrations
npx prisma db seed          # optional demo data (admin/teacher/learner accounts + a sample course)
npm run start:dev
```

API base URL: `http://localhost:3000/api`. Swagger docs: `http://localhost:3000/api/docs`.

## Environment variables (`.env`)

| Variable | Purpose |
|---|---|
| `DATABASE_URL` | PostgreSQL connection string |
| `JWT_SECRET` / `JWT_EXPIRES_IN` | JWT signing secret and token lifetime |
| `PORT` | API port (default 3000) |
| `CERTIFICATE_VERIFY_URL` | Public URL used inside generated certificate PDFs/QR codes |
| `OPENROUTER_API_KEY` / `OPENROUTER_MODEL` / `OPENROUTER_SITE_URL` / `OPENROUTER_SITE_NAME` | Powers the "Nnanga" AI tutor chat (`/api/nnanga/chat`) via OpenRouter |

Rotate `JWT_SECRET` and `OPENROUTER_API_KEY` before any real deployment — see the root README.

## Module map

Auth & users: `auth`, `users`. Content: `languages`, `courses`, `course-modules`, `lessons`, `categories`, `vocabulary`, `pronunciations`, `quizzes`, `questions`, `choices`. Learner activity: `enrollments`, `progress`, `quiz-attempts`, `bookmarks`, `certificates` (PDF + QR generation), `notifications`, `dashboard`. AI: `nnanga` (chat controller), `knowledge` + `ai` (internal services it depends on). Infra: `prisma` (PrismaService/PrismaModule), `uploads` (image upload), `common` (shared guards/decorators/DTOs/interceptors).

## Authorization model

JWT bearer auth (`Authorization: Bearer <token>`), role-based access control (`ADMIN` / `TEACHER` / `LEARNER`) via `@Roles()` + `RolesGuard`, and per-record ownership checks on learner-scoped resources (progress, quiz attempts, bookmarks, enrollments, notifications, AI chat, certificates) — a `LEARNER` can only read/write their own records; `ADMIN`/`TEACHER` can act on behalf of others. `GET /questions` and `GET /choices` strip `isCorrect` from the response unless the caller is `ADMIN`/`TEACHER`, so learners can't see quiz answers ahead of time.

## Scripts

```bash
npm run build          # tsc build (nest build)
npm run start:dev       # watch mode
npm run lint             # eslint --fix
npm run test              # jest unit tests
npm run test:e2e          # e2e tests
npm run prisma:migrate  # prisma migrate deploy
npm run prisma:seed     # seed demo data
```

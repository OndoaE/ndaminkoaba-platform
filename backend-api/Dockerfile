# Multi-stage build: compile TypeScript in a full node image, run the
# compiled output in a slim one so the final image doesn't carry devDependencies.

FROM node:22-alpine AS build
WORKDIR /app

COPY package*.json ./
COPY prisma ./prisma
RUN npm ci

COPY . .
RUN npx prisma generate
RUN npm run build

FROM node:22-alpine AS runtime
WORKDIR /app
ENV NODE_ENV=production

COPY package*.json ./
COPY prisma ./prisma
RUN npm ci --omit=dev && npx prisma generate

COPY --from=build /app/dist ./dist

# Uploaded media/certificates persist here — mount a volume at this path on
# whichever host you deploy to (e.g. a Railway volume), or uploads are lost
# on every redeploy.
RUN mkdir -p uploads

EXPOSE 3000

# Applies any pending migrations before the API starts serving traffic —
# safe to run on every boot since `prisma migrate deploy` is a no-op when
# the schema is already up to date.
CMD ["sh", "-c", "npx prisma migrate deploy && node dist/main"]

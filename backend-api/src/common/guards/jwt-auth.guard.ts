// Canonical implementation lives in `src/auth/guards/jwt-auth/jwt-auth.guard.ts`.
// Re-exported here so `common/guards` is a valid import surface instead of a
// second, divergent copy of the same guard.
export { JwtAuthGuard } from '../../auth/guards/jwt-auth/jwt-auth.guard';

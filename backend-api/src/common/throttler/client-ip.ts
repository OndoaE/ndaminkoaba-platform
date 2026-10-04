/// Works out which address the rate limiter should count a request against.
///
/// Behind Railway the TCP peer is an internal proxy and the X-Forwarded-For
/// chain has a variable number of hops (edge node -> region -> container), so
/// counting hops with `trust proxy` ends up keying on changing proxy addresses
/// instead of the caller. Railway documents `X-Real-IP` as the client's remote
/// address and sets it itself, so on Railway that header is the source of
/// truth.
///
/// Anywhere else (local development, a different host) the header is just
/// client-controlled input and must be ignored, otherwise anyone could dodge
/// the limiter by sending a fresh `X-Real-IP` each time. Set CLIENT_IP_HEADER
/// to opt another proxy that overwrites a header into the same behaviour.

type RequestLike = {
  ip?: string;
  headers?: Record<string, string | string[] | undefined>;
};

export function resolveClientIp(
  req: RequestLike,
  env: NodeJS.ProcessEnv = process.env,
): string {
  const header =
    env.CLIENT_IP_HEADER?.trim().toLowerCase() ||
    (env.RAILWAY_ENVIRONMENT_NAME || env.RAILWAY_ENVIRONMENT_ID
      ? 'x-real-ip'
      : '');

  if (header) {
    const raw = req.headers?.[header];
    const value = (Array.isArray(raw) ? raw[0] : raw)?.split(',')[0]?.trim();
    // Reject anything that isn't plausibly an address so a junk header cannot
    // be used to mint unlimited fresh buckets.
    if (value && value.length <= 45 && /^[0-9a-fA-F:.]+$/.test(value)) {
      return value;
    }
  }

  return req.ip ?? 'unknown';
}

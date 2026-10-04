import { resolveClientIp } from './client-ip';

const railway = { RAILWAY_ENVIRONMENT_NAME: 'production' } as NodeJS.ProcessEnv;
const local = {} as NodeJS.ProcessEnv;

describe('resolveClientIp', () => {
  it('uses X-Real-IP on Railway, ignoring the varying proxy address', () => {
    const a = resolveClientIp(
      { ip: '100.64.0.5', headers: { 'x-real-ip': '203.0.113.9' } },
      railway,
    );
    const b = resolveClientIp(
      { ip: '100.64.0.77', headers: { 'x-real-ip': '203.0.113.9' } },
      railway,
    );
    expect(a).toBe('203.0.113.9');
    expect(b).toBe(a); // same caller, different proxy hop -> same bucket
  });

  it('keeps different callers in different buckets', () => {
    const one = resolveClientIp(
      { headers: { 'x-real-ip': '198.51.100.1' } },
      railway,
    );
    const two = resolveClientIp(
      { headers: { 'x-real-ip': '198.51.100.2' } },
      railway,
    );
    expect(one).not.toBe(two);
  });

  it('ignores X-Real-IP when not behind Railway (it would be client-controlled)', () => {
    expect(
      resolveClientIp(
        { ip: '127.0.0.1', headers: { 'x-real-ip': '1.2.3.4' } },
        local,
      ),
    ).toBe('127.0.0.1');
  });

  it('supports an explicit header for another trusted proxy', () => {
    const env = { CLIENT_IP_HEADER: 'X-Client-Ip' } as NodeJS.ProcessEnv;
    expect(
      resolveClientIp(
        { ip: '10.0.0.1', headers: { 'x-client-ip': '192.0.2.4' } },
        env,
      ),
    ).toBe('192.0.2.4');
  });

  it('takes the first address if a header carries a list', () => {
    expect(
      resolveClientIp(
        { headers: { 'x-real-ip': '203.0.113.9, 10.0.0.2' } },
        railway,
      ),
    ).toBe('203.0.113.9');
  });

  it('falls back to the socket address when the header is missing or junk', () => {
    expect(resolveClientIp({ ip: '10.1.1.1', headers: {} }, railway)).toBe(
      '10.1.1.1',
    );
    expect(
      resolveClientIp(
        { ip: '10.1.1.1', headers: { 'x-real-ip': '<script>' } },
        railway,
      ),
    ).toBe('10.1.1.1');
    expect(resolveClientIp({}, railway)).toBe('unknown');
  });
});

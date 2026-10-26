/**
 * One-off content step: set every Ewondo lesson that has real content to
 * PUBLISHED, leaving empty/placeholder lessons as they are.
 *
 * A lesson counts as "real" with the same rule the AI tutor uses
 * (hasRealText: at least 6 separate words of content).
 *
 * Your admin login is read from the environment so it never appears in a file
 * or a chat. The script only PREVIEWS unless --apply is passed.
 *
 * PowerShell:
 *   $env:ADMIN_EMAIL="you@example.org"; $env:ADMIN_PASSWORD="your-password"
 *   npx ts-node scripts/publish-real-lessons.ts            # preview only
 *   npx ts-node scripts/publish-real-lessons.ts --apply    # publish
 *
 * Options: --base https://api.ndaminkoaba.com/api  --status PUBLISHED
 */
import { hasRealText } from '../src/knowledge/knowledge-helpers';

const args = process.argv.slice(2);
const opt = (name: string, fallback: string) => {
  const i = args.indexOf(`--${name}`);
  return i >= 0 && args[i + 1] ? args[i + 1] : fallback;
};
const BASE = opt('base', 'https://api.ndaminkoaba.com/api').replace(/\/$/, '');
const STATUS = opt('status', 'PUBLISHED');
const APPLY = args.includes('--apply');

async function api(path: string, init: RequestInit = {}, token?: string) {
  const res = await fetch(BASE + path, {
    ...init,
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
  });
  const json: any = await res.json().catch(() => ({}));
  if (!res.ok) throw new Error(`${init.method ?? 'GET'} ${path} -> ${res.status} ${JSON.stringify(json).slice(0, 200)}`);
  return json.data ?? json;
}

async function main() {
  const email = process.env.ADMIN_EMAIL;
  const password = process.env.ADMIN_PASSWORD;
  if (!email || !password) throw new Error('Set ADMIN_EMAIL and ADMIN_PASSWORD in your terminal first (see the top of this file).');

  const login = await api('/auth/login', { method: 'POST', body: JSON.stringify({ email, password }) });
  const token: string = login.accessToken;
  if (!token) throw new Error('Login did not return a token.');

  const languages = await api('/languages?limit=100');
  const ewondo = (languages.items ?? languages).find((l: any) => /ewondo/i.test(l.name));
  if (!ewondo) throw new Error('Ewondo language not found.');

  const lessons: any[] = [];
  for (let page = 1; ; page++) {
    const r = await api(`/lessons?languageId=${ewondo.id}&limit=100&page=${page}`, {}, token);
    const items = r.items ?? [];
    lessons.push(...items);
    if (items.length === 0 || lessons.length >= (r.total ?? 0)) break;
  }

  const real = lessons.filter((l) => hasRealText(l.content));
  const empty = lessons.filter((l) => !hasRealText(l.content));
  const toChange = real.filter((l) => l.status !== STATUS);

  console.log(`Ewondo lessons: ${lessons.length}  real: ${real.length}  empty/placeholder: ${empty.length}`);
  console.log(`Real lessons not yet ${STATUS}: ${toChange.length}`);
  console.log('\nLeft untouched (empty or placeholder):');
  for (const l of empty) console.log(`  - ${l.title}  [${l.status}]`);

  if (!APPLY) {
    console.log('\nPreview only. Add --apply to set the status.');
    return;
  }
  if (toChange.length === 0) {
    console.log('\nNothing to change.');
    return;
  }

  const result = await api('/lessons/bulk-status', { method: 'PATCH', body: JSON.stringify({ ids: toChange.map((l) => l.id), status: STATUS }) }, token);
  console.log(`\nUpdated ${result.updated} lessons to ${STATUS}.`);
}

main().catch((e) => {
  console.error(e.message ?? e);
  process.exitCode = 1;
});

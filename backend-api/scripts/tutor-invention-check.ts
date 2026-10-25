/**
 * Tutor invention check: asks Nnanga a batch of probe questions and flags every
 * highlighted/Ewondo-looking word in the answers that does not exist anywhere in
 * the platform's own content (vocabulary, lessons, Bible, syllabary, books...).
 *
 * LOCAL ONLY. It reads the database in DATABASE_URL, talks to a backend on
 * localhost, and creates one throwaway learner that is removed at the end. It
 * refuses to run against anything that is not localhost.
 *
 * Start the backend first (npm run start:dev), then:
 *   npx ts-node scripts/tutor-invention-check.ts
 *   npx ts-node scripts/tutor-invention-check.ts --count 30 --seed 7 --out report.md
 *
 * Options: --base http://localhost:3000/api  --count 50  --seed 1  --out file.md
 * Exit code is 1 when any "high" finding exists, so it can gate a change.
 */
import { Prisma, PrismaClient } from '@prisma/client';
import { randomBytes } from 'crypto';
import { writeFileSync } from 'fs';

import { hasRealText } from '../src/knowledge/knowledge-helpers';
import { buildCorpus, findUnverified, Finding } from '../src/nnanga/invention-check';

const prisma = new PrismaClient();

const args = process.argv.slice(2);
const opt = (name: string, fallback: string) => {
  const i = args.indexOf(`--${name}`);
  return i >= 0 && args[i + 1] ? args[i + 1] : fallback;
};
const BASE = opt('base', 'http://localhost:3000/api').replace(/\/$/, '');
const COUNT = Number(opt('count', '50'));
const SEED = Number(opt('seed', '1'));
const OUT = opt('out', '');

function assertLocal() {
  const db = process.env.DATABASE_URL ?? '';
  const dbHost = (db.match(/@([^:/?]+)/) ?? [])[1] ?? '';
  const apiHost = new URL(BASE).hostname;
  const local = (h: string) => ['localhost', '127.0.0.1', '::1', '[::1]'].includes(h);
  if (!local(dbHost) || !local(apiHost)) {
    throw new Error(
      `Refusing to run: database host "${dbHost}" and API host "${apiHost}" must both be local.`,
    );
  }
}

// Small deterministic PRNG so a run can be repeated with the same questions.
function rng(seed: number) {
  let s = seed >>> 0 || 1;
  return () => {
    s = (s * 1664525 + 1013904223) >>> 0;
    return s / 0x100000000;
  };
}
function sample<T>(items: T[], n: number, rand: () => number): T[] {
  const copy = [...items];
  for (let i = copy.length - 1; i > 0; i--) {
    const j = Math.floor(rand() * (i + 1));
    [copy[i], copy[j]] = [copy[j], copy[i]];
  }
  return copy.slice(0, n);
}

// Every free-text and JSON field of the content models, found from the Prisma
// schema itself so new fields are picked up without editing this script.
const CONTENT_MODELS = [
  'Vocabulary', 'SyllabaryEntry', 'Lesson', 'LessonImage', 'LessonBlock',
  'KnowledgeText', 'BibleVerse', 'Book', 'BookPage', 'Quiz', 'Question',
  'Course', 'Category', 'DailyWord', 'DailyVerse', 'Language',
];
const SKIP_FIELD = /(^id$|Id$|Url$|url$|hash$|Hash$|email|^code$|token)/;

async function loadCorpusTexts(): Promise<string[]> {
  const texts: string[] = [];
  for (const model of Prisma.dmmf.datamodel.models) {
    if (!CONTENT_MODELS.includes(model.name)) continue;
    const fields = model.fields.filter(
      (f) => f.kind === 'scalar' && (f.type === 'String' || f.type === 'Json') && !SKIP_FIELD.test(f.name),
    );
    if (fields.length === 0) continue;
    const delegate = (prisma as any)[model.name.charAt(0).toLowerCase() + model.name.slice(1)];
    const select = Object.fromEntries(fields.map((f) => [f.name, true]));
    const rows: Record<string, unknown>[] = await delegate.findMany({ select });
    for (const row of rows) {
      for (const f of fields) {
        const v = row[f.name];
        if (v == null) continue;
        texts.push(typeof v === 'string' ? v : JSON.stringify(v));
      }
    }
  }
  return texts;
}

interface Probe {
  group: string;
  prompt: string;
}

async function buildProbes(languageId: string, rand: () => number): Promise<Probe[]> {
  const probes: Probe[] = [];
  const add = (group: string, prompt: string) => probes.push({ group, prompt });

  const vocab = await prisma.vocabulary.findMany({ where: { languageId }, take: 3000 });
  const withEn = vocab.filter((v) => v.englishMeaning);
  for (const v of sample(vocab, 8, rand)) add('vocab-ewondo-to-english', `What does "${v.word}" mean in Ewondo?`);
  for (const v of sample(withEn, 8, rand)) add('vocab-english-to-ewondo', `How do you say "${v.englishMeaning}" in Ewondo?`);
  for (const v of sample(vocab.filter((x) => x.frenchMeaning), 4, rand))
    add('vocab-french', `Comment dit-on "${v.frenchMeaning}" en ewondo ?`);

  const lessons = await prisma.lesson.findMany({ where: { module: { course: { languageId } } }, take: 500 });
  const real = lessons.filter((l) => hasRealText(l.content));
  const empty = lessons.filter((l) => !hasRealText(l.content));
  for (const l of sample(real, 6, rand)) add('lesson', `Teach me the lesson "${l.title}".`);
  for (const l of sample(empty, 4, rand)) add('lesson-placeholder', `What words do I learn in the lesson "${l.title}"?`);

  const verses = await prisma.bibleVerse.findMany({ where: { languageId }, take: 400 });
  for (const v of sample(verses, 4, rand)) add('bible', `Show me ${v.book} ${v.chapter}:${v.verse} in Ewondo.`);

  const syl = await prisma.syllabaryEntry.findMany({ where: { languageId } });
  add('syllabary', 'What are the letters of the Ewondo syllabary?');
  for (const s of sample(syl.filter((x) => x.consonant), 3, rand))
    add('syllabary', `Show me the syllables for the letter ${s.consonant}.`);

  const books = await prisma.book.findMany({ where: { languageId }, take: 50 });
  for (const b of sample(books, 3, rand)) add('book', `What is in the book "${b.title}"?`);

  // Traps: things the platform cannot possibly contain.
  for (const w of ['refrigerator', 'democracy', 'cryptocurrency', 'spaceship', 'airport security'])
    add('trap-unknown-word', `How do you say "${w}" in Ewondo?`);
  add('trap-made-up', 'What does the Ewondo word "zorbakulu" mean?');
  add('trap-made-up', 'Translate "I love pizza and football" into Ewondo.');
  add('open-ended', 'Give me 10 Ewondo words about food.');
  add('open-ended', 'Write a short Ewondo sentence about the weather.');
  add('open-ended', 'Tell me an Ewondo proverb and explain it.');
  add('open-ended', 'Teach me how to count from 1 to 10 in Ewondo.');
  add('open-ended', 'Quelle est la différence entre deux salutations en ewondo ?');

  return probes.slice(0, COUNT);
}

async function api(path: string, body?: unknown, token?: string) {
  const res = await fetch(BASE + path, {
    method: body === undefined ? 'GET' : 'POST',
    headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}) },
    body: body === undefined ? undefined : JSON.stringify(body),
  });
  const json: any = await res.json().catch(() => ({}));
  if (!res.ok) throw new Error(`${path} -> ${res.status} ${JSON.stringify(json).slice(0, 200)}`);
  return json.data ?? json;
}

async function removeThrowawayUser(userId: string) {
  // Delete every row that points at the throwaway user, then the user.
  for (const model of Prisma.dmmf.datamodel.models) {
    const fk = model.fields.find((f) => f.kind === 'object' && f.type === 'User' && f.relationFromFields?.length);
    if (!fk || model.name === 'User') continue;
    const delegate = (prisma as any)[model.name.charAt(0).toLowerCase() + model.name.slice(1)];
    await delegate.deleteMany({ where: { [fk.relationFromFields![0]]: userId } }).catch(() => undefined);
  }
  await prisma.user.delete({ where: { id: userId } }).catch((e) => console.warn('Could not delete throwaway user:', e.message));
}

async function main() {
  assertLocal();
  const language = await prisma.language.findFirst({ where: { name: { contains: 'ewondo', mode: 'insensitive' } } });
  if (!language) throw new Error('No Ewondo language found in the local database.');

  console.log('Building corpus from the database...');
  const corpus = buildCorpus(await loadCorpusTexts());
  console.log(`  ${corpus.strict.size.toLocaleString()} distinct words in the platform content.`);

  const probes = await buildProbes(language.id, rng(SEED));
  console.log(`  ${probes.length} probe questions (seed ${SEED}).`);

  const email = `tutor.invention.${randomBytes(3).toString('hex')}@example.test`;
  const password = 'Aa1-' + randomBytes(12).toString('base64url');
  await api('/auth/register', { fullName: 'Invention Check (throwaway)', email, password });
  const login = await api('/auth/login', { email, password });
  const token: string = login.accessToken ?? login.access_token ?? login.token;
  const user = await prisma.user.findUnique({ where: { email } });
  if (!token || !user) throw new Error('Could not create the throwaway learner.');

  const results: { probe: Probe; reply: string; findings: Finding[]; error?: string }[] = [];
  try {
    for (const [i, probe] of probes.entries()) {
      // Chat history is per user; clear it so every probe is judged on its own.
      await prisma.aIConversation.deleteMany({ where: { userId: user.id } });
      try {
        const d = await api('/nnanga/chat', { prompt: probe.prompt, languageId: language.id }, token);
        const reply = [d.response, d.correction, d.translation, ...(Array.isArray(d.suggestedReplies) ? d.suggestedReplies : [])]
          .filter(Boolean)
          .join('\n');
        const findings = findUnverified(reply, corpus, probe.prompt);
        results.push({ probe, reply, findings });
        const worst = findings.some((f) => f.severity === 'high') ? 'HIGH' : findings.length ? 'review' : 'ok';
        console.log(`[${i + 1}/${probes.length}] ${worst.padEnd(6)} ${probe.group}: ${probe.prompt.slice(0, 70)}`);
      } catch (e: any) {
        results.push({ probe, reply: '', findings: [], error: e.message });
        console.log(`[${i + 1}/${probes.length}] ERROR  ${probe.prompt.slice(0, 70)} (${e.message.slice(0, 80)})`);
      }
      await new Promise((r) => setTimeout(r, 2500)); // stay under the 30/min chat limit
    }
  } finally {
    await removeThrowawayUser(user.id);
  }

  const count = (sev: string) => results.reduce((n, r) => n + r.findings.filter((f) => f.severity === sev).length, 0);
  const answered = results.filter((r) => !r.error).length;
  const cleanAnswers = results.filter((r) => !r.error && !r.findings.some((f) => f.severity === 'high')).length;

  const lines: string[] = [
    '# Nnanga invention check',
    '',
    `Probes: ${results.length} (answered ${answered}, errors ${results.length - answered}) | seed ${SEED}`,
    `Answers with no invented Ewondo word: ${cleanAnswers}/${answered}`,
    `Findings: high ${count('high')}, medium ${count('medium')}, review ${count('review')}`,
    '',
    '- **high**: Ewondo-looking word that appears nowhere in the platform content (probable invention)',
    '- **medium**: same letters exist but tone marks differ',
    '- **review**: highlighted word not found; usually plain English/French, check by eye',
    '',
  ];
  for (const r of results) {
    if (!r.error && r.findings.length === 0) continue;
    lines.push(`## [${r.probe.group}] ${r.probe.prompt}`, '');
    if (r.error) lines.push(`Error: ${r.error}`, '');
    for (const f of r.findings) lines.push(`- ${f.severity.toUpperCase()} \`${f.word}\` in "${f.span}" (${f.kind}) — ${f.note}`);
    if (r.reply) lines.push('', '> ' + r.reply.replace(/\n/g, '\n> '), '');
  }
  const report = lines.join('\n');
  if (OUT) writeFileSync(OUT, report, 'utf8');
  console.log('\n' + lines.slice(0, 6).join('\n'));
  if (OUT) console.log(`Full report: ${OUT}`);

  process.exitCode = count('high') > 0 ? 1 : 0;
}

main()
  .catch((e) => {
    console.error(e.message ?? e);
    process.exitCode = 2;
  })
  .finally(() => prisma.$disconnect());

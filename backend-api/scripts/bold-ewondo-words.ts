/**
 * One-off content fix: bold the Ewondo word/phrase in every lesson's
 * content/frenchContent, leaving the English/French label normal weight.
 *
 * Lesson content in this DB comes in a handful of recurring shapes:
 *  - "Label: EwondoValue"                (colon vocab list — the huge majority)
 *  - "EwondoWord\tEnglishGloss"           (tab-separated, Ewondo first)
 *  - "Number\tEwondoWord\tEnglishGloss"   (tab-separated, leading digit column)
 *  - "EwondoPhrase (English gloss)"       (parenthetical gloss, no leading dash)
 *  - "- EwondoPhrase (English gloss)"     (dash-prefixed dialogue lines)
 *  - a bare Ewondo phrase with no label at all
 * Plus three lessons already using a markdown table with **bold** wrongly
 * applied to BOTH the Ewondo example column and the English/French meaning
 * column, and a handful of prose lessons needing hand-picked bolding.
 *
 * Junk/placeholder lessons (random keyboard-mash content, not real curriculum)
 * are left untouched — there's no real Ewondo/English split to bold.
 *
 * Run with:
 *   npx ts-node scripts/bold-ewondo-words.ts --dry-run   (prints diffs only)
 *   npx ts-node scripts/bold-ewondo-words.ts             (writes to DB)
 */
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

// Lessons that are placeholder/test gibberish — no real Ewondo/English
// content to distinguish, so nothing to bold. Left as a disclosed gap.
const JUNK_LESSON_IDS = new Set([
  'e7053115-7692-45be-848f-23706cb12844', // Discover the Ewondo Language — pure EN/FR descriptive prose, no Ewondo words at all
  '0358aa8b-2e02-48ce-a371-5035454e2fbd', // The big Family
  '3ca472fe-dcfd-4589-8f12-fc8d3269708c', // Home and rooms
  '4d91360e-9ac3-4ca1-bb1e-2217ffd8e519', // Wake up
  'b594dfd3-350c-459c-ba46-06d35f1bc226', // A Classic Proverb (C2)
  'ea9ba713-dbda-4416-8502-539c0d3b37c3', // Pronouns (B1)
  '964e8bf6-badb-464d-9f78-7f37bf7e507a', // Beautiful
  '990ae5eb-5a50-4e7d-a439-120180ddd8de', // Articles
  'ec12215c-c998-4ab4-b91b-e2fd3ca93c99', // Linguistics 1
  'fd15c30c-5ecd-4506-a744-e77686607912', // Tall
  '371149a1-2eba-417b-93b3-52e7e89d2bad', // The Simple family
  'fb2cf111-4e9f-43e7-b608-cb05f71625ec', // Times expressions
  'c2962359-f1e9-4d5b-b567-22ae32987cd4', // Linguistics 2
  '69804cfa-dd59-4c20-a3bb-eac818cfeb56', // Negations
  '8b9d8707-6e32-41dc-8cff-93a57861de56', // Questions (B1 dup)
  'a574f091-cbeb-4a2e-8026-53e0a7bb6848', // Cooking
  'b4cc69d5-0d22-40a5-9536-cb70be354bf9', // Telling Time
  '90b9112f-d574-46df-be17-60c9c0fbae51', // Short
  '7fa8ccd8-b085-4649-9372-57daee3fcbca', // Plurals
  'a91eb2d9-b875-4428-bfe8-a5a17fa48fbd', // Friendly
  'b1f58ef7-ecd9-4270-8693-97ba1e28cf33', // Demonstratives and Possessions
  'e01d71dd-0a47-4e9b-b206-9fad2643d5c5', // Kind
  '6b3d35a1-b9b4-4b8b-8f6e-ec48b5263ee8', // Rest and Sleep
  'f84aa870-d5fc-44ea-9302-99adb800b56f', // Strong and Weak
  '94287a21-f700-480c-9e02-c65d0c2a4565', // 25. Introducing Yourself
  '28a25693-fa75-46cf-8cfa-7c22ed9d0eb6', // Intelligent
]);

// Already correctly bolded — leave untouched. The three consonant/vowel
// table lessons already bold only the letter + Ewondo-example columns and
// correctly leave the meaning column plain, despite first appearances.
const ALREADY_CORRECT_IDS = new Set([
  '757d8ba8-dabc-424c-9c1f-ffa1357f554b', // A Classic Proverb
  'bb247581-a195-4521-8ffe-9e38dfc9fe84', // Saying Hello
  'b7cac4a1-c7fc-4fa9-84cf-0c16927b6f43', // How Are You?
  'fa84178b-df6a-4aee-bf73-1ada457b25c2', // Simple consonnants (table)
  'e283ae8b-0f68-4bf8-98c9-623457cd6adb', // Complex consonnants (table)
  'a5da7dcf-4c4b-4a37-bc13-bae2f6f228da', // Short and Long vowels (table)
]);

function alreadyBold(line: string): boolean {
  return line.includes('**');
}

function isHeaderOrRangeLine(line: string): boolean {
  const t = line.trim();
  if (!t) return true;
  if (/^(Number|Nombre|Ewondo|English|Français)(\t| $)/i.test(t) && t.includes('\t')) return true;
  if (/^\d+[–-]\d+$/.test(t)) return true; // "11–19" style range dividers
  return false;
}

/** Bold every "phrase (gloss)" pair found in a dash/parenthetical line,
 * leaving connector words like "the answer is" and the gloss text itself
 * untouched. */
function boldParenPhrases(line: string): string {
  // Matches a run of non-paren, non-bold text immediately followed by "(...)".
  return line.replace(/([^()*]+?)(\s*)(\([^)]*\))/g, (_match, phrase, gap, gloss) => {
    const trimmed = phrase.trim();
    if (!trimmed) return `${phrase}${gap}${gloss}`;
    const leadingWs = phrase.match(/^\s*/)?.[0] ?? '';
    const trailingWs = phrase.slice(leadingWs.length).match(/\s*$/)?.[0] ?? '';
    const core = phrase.slice(leadingWs.length, phrase.length - trailingWs.length);
    if (!core) return `${phrase}${gap}${gloss}`;
    return `${leadingWs}**${core}**${trailingWs}${gap}${gloss}`;
  });
}

function transformLine(line: string): string {
  if (alreadyBold(line) || isHeaderOrRangeLine(line)) return line;

  const dashMatch = line.match(/^(-\s*)(.*)$/);
  if (dashMatch && dashMatch[2].trim()) {
    return dashMatch[2].includes('(')
      ? dashMatch[1] + boldParenPhrases(dashMatch[2])
      : `${dashMatch[1]}**${dashMatch[2]}**`;
  }

  if (line.includes('\t')) {
    const fields = line.split('\t');
    const targetIdx = /^\d+$/.test(fields[0]?.trim() ?? '') && fields.length >= 3 ? 1 : 0;
    const target = fields[targetIdx];
    if (target != null && target.trim()) {
      const leadingWs = target.match(/^\s*/)?.[0] ?? '';
      const trailingWs = target.slice(leadingWs.length).match(/\s*$/)?.[0] ?? '';
      const core = target.slice(leadingWs.length, target.length - trailingWs.length);
      fields[targetIdx] = core ? `${leadingWs}**${core}**${trailingWs}` : target;
    }
    return fields.join('\t');
  }

  // Colon format takes priority over a bare paren check: many Ewondo values
  // themselves contain a parenthetical alternate spelling (e.g. "Fever:
  // fiba, (ndurhu)"), which must stay inside the bolded value, not be
  // mistaken for an English/French gloss preceding it.
  const colonMatch = line.match(/^([^:]+:)(\s*)(.+)$/);
  if (colonMatch) {
    const [, label, gap, value] = colonMatch;
    if (!value.trim()) return line;
    return `${label}${gap}**${value}**`;
  }

  if (/\([^)]*\)/.test(line)) {
    return boldParenPhrases(line);
  }

  // Bare line, no label at all — the whole thing is Ewondo.
  return `**${line}**`;
}

function transformContent(content: string): string {
  return content
    .split('\n')
    .map((line) => transformLine(line))
    .join('\n');
}

// Hand-fixed lessons where the general per-line rules above don't apply
// cleanly (irregular tables, mixed formats, or prose with inline glosses).
const MANUAL_OVERRIDES: Record<string, { content?: string; frenchContent?: string }> = {
  // Lesson 1: Basic Greetings — each line has TWO Ewondo phrases separated
  // by an English/French connector ("the answer is" / "la réponse est"),
  // which the generic paren-phrase rule can't tell apart from real content.
  '6b48acac-bae8-4c46-825e-1a760f9566bb': {
    content:
      '- **M̀bəmbə kídí** ( good Morning) the answer is **Kídí m̀bəŋ** (Good morning answer).\n- **M̀bəmbə amòs** ( good day) the answer is **Amòs m̀bəŋ** ( good day answer)\n- **M̀bəmbə ngogé** ( good evening) the answer is  **ngogé m̀bəŋ** ( good evening answer)\n- **M̀bəmbə Alú** (Good Night) the answer is **Alú m̀bəŋ** ( good night answer)\n- **Masug wa!** ( Greetings) the answer is **Mə̌ nɔŋ** ( I receive)',
    frenchContent:
      '- **M̀bəmbə kídí** ( bonjour du matin) la réponse est **Kídí m̀bəŋ** (réponse bonjour du matin).\n- **M̀bəmbə amòs** ( bonjour) la réponse est **Amòs m̀bəŋ** ( réponse bonjour)\n- **M̀bəmbə ngogé** ( bonsoir) la réponse est **ngogé m̀bəŋ** ( réponse bonsoir)\n- **M̀bəmbə Alú** (Bonne nuit) la réponse est **Alú m̀bəŋ** ( réponse bonne nuit)\n- **Masug wa!** ( Salutations) la réponse est **Mə̌ nɔŋ** ( je reçois)',
  },
  // Welcome to NdaMinkoaba — prose with two inline "Ewondo = English" glosses.
  '9e33f6c2-4837-400b-a61b-de5b13dbe7d6': {
    content:
      'Welcome to Nda Minkoaba, your AI-powered platform for learning Ewondo and other Cameroonian languages.\n\nWhether you have never heard a single Ewondo word or you already know a little, this course will guide you step by step until you can confidently understand, speak, read, and write Ewondo.\nWhat Does "Nda Minkoaba" Mean?\n\nIn Ewondo:\n\n**Nda** = House\n\n**Minkoaba** = Languages\n\nSo,\n\nNda Minkoaba means\n\nHouse of Languages\n\nA place where people come together to learn, practice, and celebrate languages.\n\nLearning a language is more than memorizing words. It is discovering a culture, meeting people, and preserving a rich heritage.\n\nCongratulations on taking your first step!',
    frenchContent:
      "Bienvenue sur Nda Minkoaba, votre plateforme propulsée par l'IA pour apprendre l'Ewondo et d'autres langues camerounaises.\n\nQue vous n'ayez jamais entendu un seul mot d'Ewondo ou que vous en connaissiez déjà un peu, ce cours vous guidera pas à pas jusqu'à ce que vous puissiez comprendre, parler, lire et écrire l'Ewondo avec confiance.\nQue signifie « Nda Minkoaba » ?\n\nEn Ewondo :\n\n**Nda** = Maison\n\n**Minkoaba** = Langues\n\nDonc,\n\nNda Minkoaba signifie\n\nMaison des Langues\n\nUn lieu où les gens se rassemblent pour apprendre, pratiquer et célébrer les langues.\n\nApprendre une langue, c'est plus que mémoriser des mots. C'est découvrir une culture, rencontrer des gens et préserver un riche héritage.\n\nFélicitations pour avoir fait votre premier pas !",
  },
  // Numbers from 1 to 9 — space-separated, not tab-separated.
  '2b1f7c4b-0a24-47c8-aaf1-f285e7f02ce4': {
    content:
      '**mbɔ́g**  One (1)  \n**bɛ̄**  Two (2)\n**lɛ́**     Three (3) \n**nyii**   Four (4)\n**tán**    Five (5)\n**saman**   Six (6)  \n**zəmgbál** Seven (7) \n**moom**   Eight (8)\n**ebûl**    Nine (9)',
    frenchContent:
      '**mbɔ́g**  Un (1)\n**bɛ̄**  Deux (2)\n**lɛ́**     Trois (3)\n**nyii**   Quatre (4)\n**tán**    Cinq (5)\n**saman**   Six (6)\n**zəmgbál** Sept (7)\n**moom**   Huit (8)\n**ebûl**    Neuf (9)',
  },
  // Usefull expressions — mixed dash- and tab-separated lines.
  '47489c9e-9152-471a-9e61-9a460fc524f3': {
    content:
      '- **Akiba** or **Abui ngaŋ**\t(Thank you)\n- **Akiba aboui**\t(Thank you very much)\n- **Nkele**\t(Let\'s go)\t\n- **Bi azou** (We\'re coming)\n- **Ye one vôa?**\t(How are you?)\t answer is **Owé** ("I\'m fine / Yes")\n**Nkele bia woulou**\tLet\'s go for a walk',
    frenchContent:
      '- **Akiba** or **Abui ngaŋ**\t(Merci)\n- **Akiba aboui**\t(Merci beaucoup)\n- **Nkele**\t(Allons-y)\t\n- **Bi azou** (Nous arrivons)\n- **Ye one vôa?**\t(Comment vas-tu ?)\t la réponse est **Owé** (« Je vais bien / Oui »)\n**Nkele bia woulou**\tAllons nous promener',
  },
  // Word and translation 5 — irregular tab counts, inconsistent field order.
  'f82acc3c-0c32-4185-b5dd-5111ab7f034a': {
    content:
      'Preamble of the Constitution\t**Ntol ebug akok memvende**\n\tExecutive Power\t**Edzoe y atonlo enyin nnam**\nPresident of the Republic\t**O Tombo Nnam**\nNational Unity\t**Enyin fufulu**\nInternational Treaties and Agreements\t\nOath\t**Ekan son**\n\tNational Assembly/Sénat\tSenate\t**Esiè bemvende**\nJudicial Power\t**Edzoe nda medzo**',
    frenchContent:
      'Préambule de la Constitution\t**Ntol ebug akok memvende**\n\tPouvoir exécutif\t**Edzoe y atonlo enyin nnam**\nPrésident de la République\t**O Tombo Nnam**\nUnité nationale\t**Enyin fufulu**\nTraités et accords internationaux\t\nSerment\t**Ekan son**\n\tAssemblée nationale/Sénat\tSénat\t**Esiè bemvende**\nPouvoir judiciaire\t**Edzoe nda medzo**',
  },
};

async function main() {
  const dryRun = process.argv.includes('--dry-run');
  const lessons = await prisma.lesson.findMany({
    select: { id: true, title: true, content: true, frenchContent: true },
  });

  let changed = 0;
  for (const lesson of lessons) {
    if (JUNK_LESSON_IDS.has(lesson.id) || ALREADY_CORRECT_IDS.has(lesson.id)) continue;

    let newContent: string | undefined;
    let newFrench: string | undefined;

    if (MANUAL_OVERRIDES[lesson.id]) {
      newContent = MANUAL_OVERRIDES[lesson.id].content;
      newFrench = MANUAL_OVERRIDES[lesson.id].frenchContent;
    } else {
      newContent = lesson.content ? transformContent(lesson.content) : undefined;
      newFrench = lesson.frenchContent ? transformContent(lesson.frenchContent) : undefined;
    }

    const contentChanged = newContent !== undefined && newContent !== lesson.content;
    const frenchChanged = newFrench !== undefined && newFrench !== lesson.frenchContent;
    if (!contentChanged && !frenchChanged) continue;

    changed++;
    console.log(`\n=== ${lesson.title} (${lesson.id}) ===`);
    if (contentChanged) {
      console.log('--- EN before ---\n' + lesson.content);
      console.log('--- EN after ---\n' + newContent);
    }
    if (frenchChanged) {
      console.log('--- FR before ---\n' + lesson.frenchContent);
      console.log('--- FR after ---\n' + newFrench);
    }

    if (!dryRun) {
      await prisma.lesson.update({
        where: { id: lesson.id },
        data: {
          ...(contentChanged ? { content: newContent } : {}),
          ...(frenchChanged ? { frenchContent: newFrench } : {}),
        },
      });
    }
  }

  console.log(`\n${dryRun ? '[DRY RUN] Would change' : 'Changed'} ${changed} of ${lessons.length} lessons.`);
  console.log(`Skipped ${JUNK_LESSON_IDS.size} junk + ${ALREADY_CORRECT_IDS.size} already-correct lessons.`);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());

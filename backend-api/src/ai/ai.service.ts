import { Injectable, Logger } from '@nestjs/common';
import OpenAI from 'openai';
import { readFile } from 'fs/promises';

import { detectReplyLanguage } from './language-detector';

export interface ChatHistoryMessage {
  role: 'user' | 'assistant';
  content: string;
}

export interface StructuredTutorResponse {
  response: string;
  correction: string | null;
  translation: string | null;
  suggestedReplies: string[];
}

export interface SuggestedVocabularyEntry {
  word: string;
  englishMeaning: string | null;
  frenchMeaning: string | null;
}

export interface SyllabaryExtractionRow {
  vowel: string;
  syllable: string;
  exampleWord: string | null;
  translation: string | null;
  exampleSentence: string | null;
  orderNumber: number;
  confidence: 'high' | 'low';
}

export interface SyllabaryLetterGroup {
  consonant: string | null;
  rows: SyllabaryExtractionRow[];
}

export interface SyllabaryExtractionResult {
  letters: SyllabaryLetterGroup[];
  warnings: string[];
}

@Injectable()
export class AiService {
  private readonly client: OpenAI;
  private readonly logger = new Logger(AiService.name);

  constructor() {
    this.client = new OpenAI({
      baseURL: 'https://openrouter.ai/api/v1',
      apiKey: process.env.OPENROUTER_API_KEY,
      defaultHeaders: {
        'HTTP-Referer': process.env.OPENROUTER_SITE_URL || 'http://localhost:3000',
        'X-OpenRouter-Title': process.env.OPENROUTER_SITE_NAME || 'NdaMinkoaba',
      },
    });
  }

  private buildSystemPrompt(hasLocalKnowledge: boolean, languageName: string): string {
    return `You are Nnanga, the AI language and culture tutor of the NdaMinkoaba platform — an educational platform dedicated to preserving and teaching Cameroon's indigenous languages, currently including ${languageName}, alongside French and English. You are warm, patient, encouraging, and pedagogically sharp: a gifted human tutor, not a generic chatbot.

REPLY LANGUAGE — READ THIS FIRST, HIGHEST PRIORITY RULE: detect the language the learner just wrote their LATEST message in — English, French, or ${languageName} — and write your ENTIRE reply in that same language, every single time, no exceptions. This is a per-message decision based only on the newest message, never on what language earlier turns happened to be in. Remembering the conversation (see "Conversation memory" below) means remembering WHAT was said and WHO the learner is — it never means staying "locked" to a language used earlier. If the learner writes in English after several French turns, your reply is 100% English; if they switch to French after English turns, your reply is 100% French. Never mix languages within one reply, and never default to French just because your own earlier replies were in French.

GREETINGS — SECOND PRIORITY: if the learner's latest message is ONLY a greeting (e.g. "hello", "hi", "bonjour", "mbolo", "salut") with no other question attached, that is a greeting, full stop — NOT a request to translate or explain the greeting word itself, even if the LOCAL KNOWLEDGE CONTEXT below happens to contain a vocabulary entry that matches it. Do not turn a bare "hello" into a vocabulary lesson. Instead:
- If there is no conversation history above (this is truly the first message ever), introduce yourself warmly: your name is Nnanga, you're their tutor for ${languageName} (plus Cameroonian culture, Bible content, and language learning generally) on NdaMinkoaba, and briefly invite them to ask about a word, a lesson, or anything they're curious about.
- If there IS conversation history above, they're just saying hello again to someone they already know — greet them back warmly and briefly (using their name if you know it), and ask what they'd like to work on, without repeating the full self-introduction.
A greeting combined with a real question (e.g. "Hi, how do I say water in ${languageName}?") is NOT a bare greeting — answer the actual question normally, with a brief warm greeting folded in.

You draw on two sources of knowledge:
1. OFFICIAL NDAMINKOABA CONTENT — vocabulary, texts, Bible verses, lessons, quiz questions, courses and books retrieved from the platform's own database, given to you below as "LOCAL KNOWLEDGE CONTEXT". This is always authoritative for anything it covers: never contradict it or invent a different meaning for a word it defines. The FULL VOCABULARY LIST inside it is the complete, exhaustive word list — treat any word absent from it as genuinely absent, not as something to guess at. When a QUIZ QUESTIONS section is present, you only ever see question text, never which choice is correct — if a learner asks you to grade or reveal an answer, tell them to take the quiz in the app instead of guessing.
2. YOUR OWN GENERAL KNOWLEDGE of language learning, Bantu/Niger-Congo linguistics, Cameroonian culture, the Bible, and teaching method — for grammar patterns, pronunciation, culture, history, and study advice, freely used to give complete, useful answers even when the local context is thin. ${hasLocalKnowledge ? 'This question matches local content — blend it in naturally.' : 'This question has no strong platform match — lean on general knowledge for methodology/culture, but the CRITICAL ACCURACY RULE below still applies in full to any specific target-language word or phrase.'} Never refuse to answer just because local content is missing.

IMPORTANT — you will receive a CRITICAL ACCURACY RULE inside the LOCAL KNOWLEDGE CONTEXT below, about never inventing ${languageName} words/phrases that aren't verbatim in that context. Follow it exactly; it is not optional and applies regardless of how confident you feel.

Style:
- Use light markdown: short paragraphs, **bold** for new vocabulary or key terms, bullet lists for enumerations.
- Be concise but complete — a few focused paragraphs, not an essay — UNLESS the learner asked for a full Bible chapter or verse range, in which case completeness matters more than brevity: include every verse from the FULL BIBLE PASSAGE section, not a trimmed sample.
- End with a short follow-up question or practice tip when it helps the learner engage further (skip this after a long Scripture passage).

Conversation memory:
- The messages above this one are the actual recent history of this same conversation with this learner — not background material, real memory. Read it before replying: track the learner's name if they gave one, what they've already asked about or struggled with, corrections you already gave, and anything they told you about themselves (goals, level, interests). Use that naturally, the way a real tutor remembers their student from one exchange to the next — never ask again for something already in the history, and never treat a follow-up question as if it were the start of a brand new conversation.`;
  }

  // A system-prompt instruction alone isn't reliable for this: gpt-4o-mini
  // measurably anchors to whichever language dominated recent turns and
  // ignores a language switch in the newest message. Detecting it in code
  // and stating it explicitly, right next to the content it applies to, is
  // far more reliably followed than a static rule buried in the system
  // prompt — see language-detector.ts for why detection is code, not a
  // model judgment call.
  private buildLanguageDirective(prompt: string): string {
    const detected = detectReplyLanguage(prompt);
    if (!detected) return '';
    const languageLabel = detected === 'fr' ? 'French' : 'English';
    return `\n\n---\n[REPLY LANGUAGE DIRECTIVE: the learner's latest message is in ${languageLabel}. Your entire reply must be in ${languageLabel}, regardless of what language earlier turns in this conversation used.]`;
  }

  async generateTutorResponse(
    prompt: string,
    context: string,
    history: ChatHistoryMessage[] = [],
    hasLocalKnowledge = false,
    languageName = 'the target language',
    isFullPassageRequest = false,
    isUngroundedTranslationRequest = false,
    suggestedVocabulary: SuggestedVocabularyEntry[] = [],
  ): Promise<string> {
    if (!process.env.OPENROUTER_API_KEY) {
      return 'Nnanga AI is not configured yet. Please add OPENROUTER_API_KEY to the .env file.';
    }

    // Small models reliably invent a plausible-looking word rather than
    // admit ignorance when the task is framed as "translate this (but
    // don't guess)" — the instinct to complete the requested translation
    // wins even over an explicit ban, and even "suggest real alternatives
    // instead" wasn't safe on its own: letting the model pick which words
    // to mention just moved the fabrication into the "suggestion" (tested
    // and observed). So here the model isn't asked to pick anything — the
    // caller has already selected real rows from the database
    // (KnowledgeService.search's suggestedVocabulary) and hands them over
    // verbatim; the model's only job is prose around words it didn't choose.
    const approvedWordsBlock = suggestedVocabulary
      .map((w) => `${w.word} = ${w.englishMeaning ?? '?'} / ${w.frenchMeaning ?? '?'}`)
      .join('\n');

    const userMessage = (isUngroundedTranslationRequest
      ? `LOCAL KNOWLEDGE CONTEXT:\n${context}\n\nLearner question:\n${prompt}\n\n---\nIMPORTANT: NdaMinkoaba's content has been checked in code and does NOT contain a ${languageName} translation for this. Do NOT attempt a translation and do NOT write any ${languageName} word yourself. The ONLY ${languageName} words you are allowed to write, copied exactly as shown, are these pre-approved ones:\n${approvedWordsBlock || '(none available)'}\n\nYour task: (1) warmly tell the learner this specific word/phrase isn't in the platform's content yet, (2) if the list above is non-empty, weave 1-3 of those exact words into a helpful suggestion, using ONLY the spelling shown, (3) optionally add a short encouraging note. Reply in the language of the learner's question. Do not add, modify, or guess any other ${languageName} text.`
      : `LOCAL KNOWLEDGE CONTEXT:\n${context}\n\nLearner question:\n${prompt}\n\n---\nBefore answering: if this question asks for a specific ${languageName} word, phrase, or translation, first check whether it is verbatim in the FULL VOCABULARY LIST or another section above. If it is not there, do not translate it — tell the learner honestly that this isn't in NdaMinkoaba's content yet, instead of guessing.`
    ) + this.buildLanguageDirective(prompt);

    try {
      const completion = await this.client.chat.completions.create({
        model: process.env.OPENROUTER_MODEL || 'openai/gpt-4o-mini',
        // Low temperature — this tutor is graded on factual accuracy (real
        // vocabulary, real Scripture) far more than creative variety, and a
        // lower value measurably reduces the model's tendency to improvise
        // a plausible-sounding but fabricated target-language word.
        temperature: 0.2,
        // A full Gospel chapter (some run 70-80 verses) needs real room to
        // be quoted verbatim in two languages without cutting off mid-
        // passage; every other question is a focused answer, and capping it
        // much lower noticeably cuts response latency for the common case.
        max_tokens: isFullPassageRequest ? 4000 : 900,
        messages: [
          {
            role: 'system',
            content: this.buildSystemPrompt(hasLocalKnowledge, languageName),
          },
          ...history.map((message) => ({
            role: message.role,
            content: message.content,
          })),
          {
            role: 'user',
            content: userMessage,
          },
        ],
      });

      return completion.choices[0]?.message?.content?.trim()
        || 'Nnanga could not generate a response.';
    } catch (error: any) {
      this.logger.error(error);

      if (error?.status === 401) {
        return 'Nnanga could not authenticate with OpenRouter. Please verify OPENROUTER_API_KEY.';
      }

      if (error?.status === 429) {
        return 'Nnanga has reached the OpenRouter usage limit. Please check credits or rate limits.';
      }

      return 'Nnanga could not reach the AI service right now. I can still answer from local NdaMinkoaba content.';
    }
  }

  /// Same call as generateTutorResponse but asks the model for JSON-mode
  /// structured output (correction/translation/suggestedReplies alongside
  /// the normal reply), used by Nnanga chat's richer UI. Falls back to a
  /// plain response with the extra fields null if parsing ever fails, so a
  /// malformed structured reply never breaks the chat.
  async generateStructuredTutorResponse(
    prompt: string,
    context: string,
    history: ChatHistoryMessage[] = [],
    hasLocalKnowledge = false,
    languageName = 'the target language',
    isFullPassageRequest = false,
    isUngroundedTranslationRequest = false,
    suggestedVocabulary: SuggestedVocabularyEntry[] = [],
  ): Promise<StructuredTutorResponse> {
    if (!process.env.OPENROUTER_API_KEY) {
      return {
        response: 'Nnanga AI is not configured yet. Please add OPENROUTER_API_KEY to the .env file.',
        correction: null,
        translation: null,
        suggestedReplies: [],
      };
    }

    const approvedWordsBlock = suggestedVocabulary
      .map((w) => `${w.word} = ${w.englishMeaning ?? '?'} / ${w.frenchMeaning ?? '?'}`)
      .join('\n');

    const userMessage = (isUngroundedTranslationRequest
      ? `LOCAL KNOWLEDGE CONTEXT:\n${context}\n\nLearner question:\n${prompt}\n\n---\nIMPORTANT: NdaMinkoaba's content has been checked in code and does NOT contain a ${languageName} translation for this. Do NOT attempt a translation and do NOT write any ${languageName} word yourself. The ONLY ${languageName} words you are allowed to write, copied exactly as shown, are these pre-approved ones:\n${approvedWordsBlock || '(none available)'}\n\nYour task: (1) warmly tell the learner this specific word/phrase isn't in the platform's content yet, (2) if the list above is non-empty, weave 1-3 of those exact words into a helpful suggestion, using ONLY the spelling shown, (3) optionally add a short encouraging note. Reply in the language of the learner's question. Do not add, modify, or guess any other ${languageName} text.`
      : `LOCAL KNOWLEDGE CONTEXT:\n${context}\n\nLearner question:\n${prompt}\n\n---\nBefore answering: if this question asks for a specific ${languageName} word, phrase, or translation, first check whether it is verbatim in the FULL VOCABULARY LIST or another section above. If it is not there, do not translate it — tell the learner honestly that this isn't in NdaMinkoaba's content yet, instead of guessing.`
    ) + this.buildLanguageDirective(prompt);

    const structuredInstruction = `\n\n---\nRespond with ONLY a JSON object (no markdown fences, no prose outside it) matching exactly this shape:\n{"response": string, "correction": string|null, "translation": string|null, "suggestedReplies": string[]}\n- "response": your normal reply, following all the style rules above.\n- "correction": a short, gentle note ONLY if the learner's message contained a language mistake worth flagging, else null.\n- "translation": filled ONLY if the learner explicitly asked for a translation, else null.\n- "suggestedReplies": 2-4 short, natural follow-up messages the learner might send next, in the same language as "response". Empty array if none fit.`;

    try {
      const completion = await this.client.chat.completions.create({
        model: process.env.OPENROUTER_MODEL || 'openai/gpt-4o-mini',
        temperature: 0.2,
        max_tokens: isFullPassageRequest ? 4000 : 1100,
        response_format: { type: 'json_object' },
        messages: [
          {
            role: 'system',
            content: this.buildSystemPrompt(hasLocalKnowledge, languageName) + structuredInstruction,
          },
          ...history.map((message) => ({
            role: message.role,
            content: message.content,
          })),
          {
            role: 'user',
            content: userMessage,
          },
        ],
      });

      const raw = completion.choices[0]?.message?.content?.trim();

      if (raw) {
        try {
          const parsed = JSON.parse(raw);
          if (typeof parsed.response === 'string') {
            return {
              response: parsed.response,
              correction: typeof parsed.correction === 'string' ? parsed.correction : null,
              translation: typeof parsed.translation === 'string' ? parsed.translation : null,
              suggestedReplies: Array.isArray(parsed.suggestedReplies)
                ? parsed.suggestedReplies.filter((r: unknown) => typeof r === 'string')
                : [],
            };
          }
        } catch (parseError) {
          this.logger.warn(`Nnanga structured response was not valid JSON: ${parseError}`);
        }
      }

      return {
        response: raw || 'Nnanga could not generate a response.',
        correction: null,
        translation: null,
        suggestedReplies: [],
      };
    } catch (error: any) {
      this.logger.error(error);

      if (error?.status === 401) {
        return {
          response: 'Nnanga could not authenticate with OpenRouter. Please verify OPENROUTER_API_KEY.',
          correction: null,
          translation: null,
          suggestedReplies: [],
        };
      }

      if (error?.status === 429) {
        return {
          response: 'Nnanga has reached the OpenRouter usage limit. Please check credits or rate limits.',
          correction: null,
          translation: null,
          suggestedReplies: [],
        };
      }

      return {
        response: 'Nnanga could not reach the AI service right now. I can still answer from local NdaMinkoaba content.',
        correction: null,
        translation: null,
        suggestedReplies: [],
      };
    }
  }

  /// Transcribes a locally-stored audio file via an audio-capable OpenRouter
  /// model (no dedicated speech-to-text provider is configured — see
  /// OPENROUTER_AUDIO_MODEL). Used by both pronunciation-practice scoring and
  /// Nnanga voice messages. Returns null on any failure (missing key, no
  /// credit, unsupported format, network error) so callers can degrade
  /// gracefully instead of throwing — audio features are best-effort, not
  /// something that should ever 500 the request.
  async transcribeAudio(absoluteFilePath: string, format: string): Promise<string | null> {
    if (!process.env.OPENROUTER_API_KEY) {
      return null;
    }

    try {
      const buffer = await readFile(absoluteFilePath);
      const base64Audio = buffer.toString('base64');

      const completion = await this.client.chat.completions.create({
        model: process.env.OPENROUTER_AUDIO_MODEL || 'google/gemini-2.5-flash',
        temperature: 0,
        max_tokens: 200,
        messages: [
          {
            role: 'user',
            content: [
              {
                type: 'text',
                text: 'Transcribe exactly what is said in this audio, as literally as possible. Reply with ONLY the transcript text, nothing else — no punctuation commentary, no translation.',
              },
              {
                // OpenAI-compatible input_audio content block, passed through
                // by OpenRouter. `format` officially covers wav/mp3; browser
                // MediaRecorder output (webm/ogg) is untested against this —
                // flagged as an open risk in the implementation plan.
                type: 'input_audio',
                input_audio: { data: base64Audio, format },
              } as any,
            ],
          },
        ],
      });

      const transcript = completion.choices[0]?.message?.content?.trim();
      return transcript || null;
    } catch (error) {
      this.logger.error(`Audio transcription failed: ${error}`);
      return null;
    }
  }

  /// Extracts a photographed syllabics/literacy chart (a consonant with
  /// arrows fanning out to each of the language's vowels, each row showing
  /// an example word + translation + example sentence) into structured
  /// rows via a vision-capable model. Never writes anything itself — the
  /// admin reviews/edits the result and only "Approve & Import" persists
  /// it, one row at a time, through the normal SyllabaryEntry create
  /// endpoint. Returns an empty-rows result with a warning on any failure
  /// rather than throwing, so "Re-analyze" in the admin UI is a meaningful
  /// retry instead of a guaranteed repeat crash.
  async extractSyllabaryChart(
    base64Image: string,
    mimeType: string,
    languageName: string,
  ): Promise<SyllabaryExtractionResult> {
    const empty = (warning: string): SyllabaryExtractionResult => ({
      letters: [],
      warnings: [warning],
    });

    if (!process.env.OPENROUTER_API_KEY) {
      return empty('Nnanga AI is not configured yet. Please add OPENROUTER_API_KEY to the .env file.');
    }

    const prompt = `You are extracting a hand-drawn or printed syllabics teaching chart for ${languageName} into structured JSON. These charts follow a standard literacy-teaching convention: one consonant letter, with arrows fanning out to each of the language's vowels, forming a syllable per vowel (e.g. consonant "L" + vowel "a" -> syllable "la"). A single image or page commonly contains SEVERAL such charts side by side or stacked — one per consonant (e.g. "F", "H", "K" each with their own 8-row block) — so you must find and extract EVERY consonant chart visible in the image, not just the first or largest one. Some charts instead show a single standalone vowel with no consonant. Each row typically also shows an example word containing that syllable, a French translation of that word, and an example sentence using the word — though any of these may be missing or illegible.

Read the image and respond with ONLY a JSON object (no markdown fences, no prose outside it) matching exactly this shape:
{
  "letters": [
    {
      "consonant": string | null,
      "rows": [
        {
          "vowel": string,
          "syllable": string,
          "exampleWord": string | null,
          "translation": string | null,
          "exampleSentence": string | null,
          "orderNumber": number,
          "confidence": "high" | "low"
        }
      ]
    }
  ],
  "warnings": string[]
}

Rules:
- "letters" has one entry per DISTINCT consonant chart you can find in the image — if the image contains four charts (e.g. F, H, g, K), "letters" must have four entries, each with its own "rows". Do not merge separate charts into one entry, and do not stop after the first chart you find.
- Within each entry, "consonant" is the single big letter that chart is built around (e.g. "L"); null if that particular chart is a standalone vowel with nothing combined with it.
- Within each entry, "rows" has one row per vowel you can see for that specific chart, in the same top-to-bottom order as the chart — "orderNumber" is that 0-based position within the chart.
- If a field is not legible or not present for a row, use null for that field — do NOT guess or invent content to fill it in.
- Set "confidence" to "low" on any row where you are unsure of what you read (blurry, ambiguous handwriting, cut off) rather than silently guessing "high".
- Add an entry to "warnings" for anything that affected extraction quality: the photo is angled/rotated, blurry, poorly lit, handwriting was hard to read, a chart appears cropped or incomplete, or a chart had fewer/more rows than the language's usual vowel count would suggest.
- If the image doesn't look like a syllabics chart at all, return an empty "letters" array and say so in "warnings".`;

    try {
      const completion = await this.client.chat.completions.create({
        model: process.env.OPENROUTER_VISION_MODEL || 'openai/gpt-4o-mini',
        temperature: 0,
        max_tokens: 12000,
        response_format: { type: 'json_object' },
        messages: [
          {
            role: 'user',
            content: [
              { type: 'text', text: prompt },
              {
                type: 'image_url',
                image_url: { url: `data:${mimeType};base64,${base64Image}` },
              } as any,
            ],
          },
        ],
      });

      const raw = completion.choices[0]?.message?.content?.trim();
      if (!raw) return empty('Nnanga could not read this image. Try Re-analyze.');
      return this.parseSyllabaryExtractionResponse(raw, empty);
    } catch (error: any) {
      return this.handleSyllabaryExtractionError(error, empty);
    }
  }

  /// Same contract as [extractSyllabaryChart], but for a pasted/typed table
  /// or free-text description instead of a photographed chart — used both
  /// for direct clipboard-paste input and for text extracted from an
  /// uploaded PDF/Word/Excel/txt file (see `document-text-extractor.ts`).
  /// Reuses the same response parsing/error handling so both paths stay in
  /// sync on the JSON contract.
  async extractSyllabaryChartFromText(
    text: string,
    languageName: string,
  ): Promise<SyllabaryExtractionResult> {
    const empty = (warning: string): SyllabaryExtractionResult => ({
      letters: [],
      warnings: [warning],
    });

    if (!process.env.OPENROUTER_API_KEY) {
      return empty('Nnanga AI is not configured yet. Please add OPENROUTER_API_KEY to the .env file.');
    }

    const prompt = `You are extracting a ${languageName} syllabics teaching chart from pasted or typed content (this may be a plain-text description, a table copy-pasted from a spreadsheet or document, or a plain list) into structured JSON. These charts follow a standard literacy-teaching convention: one consonant letter combined with each of the language's vowels to form a syllable per vowel (e.g. consonant "L" + vowel "a" -> syllable "la"). The source content commonly contains SEVERAL such charts one after another — one per consonant (e.g. "F", "H", "K" each with their own block of rows) — so you must find and extract EVERY consonant chart present, not just the first one. Some content instead describes a single standalone vowel with no consonant. Each row typically also lists an example word containing that syllable, a French translation of that word, and an example sentence — though any of these may be missing.

Here is the pasted/typed content:
"""
${text}
"""

Respond with ONLY a JSON object (no markdown fences, no prose outside it) matching exactly this shape:
{
  "letters": [
    {
      "consonant": string | null,
      "rows": [
        {
          "vowel": string,
          "syllable": string,
          "exampleWord": string | null,
          "translation": string | null,
          "exampleSentence": string | null,
          "orderNumber": number,
          "confidence": "high" | "low"
        }
      ]
    }
  ],
  "warnings": string[]
}

Rules:
- "letters" has one entry per DISTINCT consonant chart present in the content — if the content contains four charts (e.g. F, H, g, K), "letters" must have four entries, each with its own "rows". Do not merge separate charts into one entry, and do not stop after the first chart you find.
- Within each entry, "consonant" is the single letter that chart is built around (e.g. "L"); null if that particular chart describes a standalone vowel with nothing combined with it.
- Within each entry, "rows" has one row per vowel you can identify for that specific chart, in the same order as the source content — "orderNumber" is that 0-based position within the chart.
- If a field is missing or unclear for a row, use null for that field — do NOT guess or invent content to fill it in.
- Set "confidence" to "low" on any row where the content is ambiguous or you had to infer structure, rather than silently guessing "high".
- Add an entry to "warnings" for anything that affected extraction: the content seemed truncated or malformed, formatting was inconsistent, or a chart had fewer/more rows than the language's usual vowel count would suggest.
- If the pasted content doesn't look like a syllabics chart at all, return an empty "letters" array and say so in "warnings".`;

    try {
      const completion = await this.client.chat.completions.create({
        model: process.env.OPENROUTER_MODEL || 'openai/gpt-4o-mini',
        temperature: 0,
        max_tokens: 12000,
        response_format: { type: 'json_object' },
        messages: [{ role: 'user', content: prompt }],
      });

      const raw = completion.choices[0]?.message?.content?.trim();
      if (!raw) return empty('Nnanga could not read this content. Try Re-analyze.');
      return this.parseSyllabaryExtractionResponse(raw, empty);
    } catch (error: any) {
      return this.handleSyllabaryExtractionError(error, empty);
    }
  }

  private parseSyllabaryRows(rawRows: unknown): SyllabaryExtractionRow[] {
    const list = Array.isArray(rawRows) ? rawRows : [];
    return list
      .filter((r: unknown) => typeof r === 'object' && r !== null)
      .map((r: any, index: number): SyllabaryExtractionRow => ({
        vowel: typeof r.vowel === 'string' ? r.vowel : '',
        syllable: typeof r.syllable === 'string' ? r.syllable : '',
        exampleWord: typeof r.exampleWord === 'string' ? r.exampleWord : null,
        translation: typeof r.translation === 'string' ? r.translation : null,
        exampleSentence: typeof r.exampleSentence === 'string' ? r.exampleSentence : null,
        orderNumber: typeof r.orderNumber === 'number' ? r.orderNumber : index,
        confidence: r.confidence === 'low' ? 'low' : 'high',
      }))
      .filter((r: SyllabaryExtractionRow) => r.vowel !== '' || r.syllable !== '');
  }

  private parseSyllabaryExtractionResponse(
    raw: string,
    empty: (warning: string) => SyllabaryExtractionResult,
  ): SyllabaryExtractionResult {
    try {
      const parsed = JSON.parse(raw);
      const warnings: string[] = Array.isArray(parsed.warnings)
        ? parsed.warnings.filter((w: unknown) => typeof w === 'string')
        : [];

      // The model is instructed to return a "letters" array (one entry per
      // consonant chart found), but response_format: json_object has no
      // schema enforcement -- if it ever falls back to the older single-group
      // shape ({ consonant, rows }), coerce that into a one-entry "letters"
      // array instead of discarding the whole response.
      const rawLetters = Array.isArray(parsed.letters)
        ? parsed.letters
        : Array.isArray(parsed.rows) || parsed.consonant !== undefined
          ? [{ consonant: parsed.consonant, rows: parsed.rows }]
          : [];

      const letters: SyllabaryLetterGroup[] = rawLetters
        .filter((g: unknown) => typeof g === 'object' && g !== null)
        .map((g: any) => ({
          consonant: typeof g.consonant === 'string' ? g.consonant : null,
          rows: this.parseSyllabaryRows(g.rows),
        }))
        .filter((g: SyllabaryLetterGroup) => g.rows.length > 0);

      if (letters.length === 0 && warnings.length === 0) {
        warnings.push('Nnanga could not find any syllabary chart in this content. Try Re-analyze.');
      }

      return { letters, warnings };
    } catch (parseError) {
      this.logger.warn(`Syllabary extraction response was not valid JSON: ${parseError}`);
      return empty('Could not read the AI response — try Re-analyze.');
    }
  }

  private handleSyllabaryExtractionError(
    error: any,
    empty: (warning: string) => SyllabaryExtractionResult,
  ): SyllabaryExtractionResult {
    this.logger.error(error);

    if (error?.status === 401) {
      return empty('Nnanga could not authenticate with OpenRouter. Please verify OPENROUTER_API_KEY.');
    }
    if (error?.status === 429) {
      return empty('Nnanga has reached the OpenRouter usage limit. Please check credits or rate limits.');
    }
    return empty('Nnanga could not reach the AI service right now. Try Re-analyze in a moment.');
  }
}

import { Injectable, Logger } from '@nestjs/common';
import OpenAI from 'openai';
import { readFile } from 'fs/promises';

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

GREETINGS — READ THIS FIRST: if the learner's latest message is ONLY a greeting (e.g. "hello", "hi", "bonjour", "mbolo", "salut") with no other question attached, that is a greeting, full stop — NOT a request to translate or explain the greeting word itself, even if the LOCAL KNOWLEDGE CONTEXT below happens to contain a vocabulary entry that matches it. Do not turn a bare "hello" into a vocabulary lesson. Instead:
- If there is no conversation history above (this is truly the first message ever), introduce yourself warmly: your name is Nnanga, you're their tutor for ${languageName} (plus Cameroonian culture, Bible content, and language learning generally) on NdaMinkoaba, and briefly invite them to ask about a word, a lesson, or anything they're curious about.
- If there IS conversation history above, they're just saying hello again to someone they already know — greet them back warmly and briefly (using their name if you know it), and ask what they'd like to work on, without repeating the full self-introduction.
A greeting combined with a real question (e.g. "Hi, how do I say water in ${languageName}?") is NOT a bare greeting — answer the actual question normally, with a brief warm greeting folded in.

You draw on two sources of knowledge:
1. OFFICIAL NDAMINKOABA CONTENT — vocabulary, texts, Bible verses, lessons, quiz questions, courses and books retrieved from the platform's own database, given to you below as "LOCAL KNOWLEDGE CONTEXT". This is always authoritative for anything it covers: never contradict it or invent a different meaning for a word it defines. The FULL VOCABULARY LIST inside it is the complete, exhaustive word list — treat any word absent from it as genuinely absent, not as something to guess at. When a QUIZ QUESTIONS section is present, you only ever see question text, never which choice is correct — if a learner asks you to grade or reveal an answer, tell them to take the quiz in the app instead of guessing.
2. YOUR OWN GENERAL KNOWLEDGE of language learning, Bantu/Niger-Congo linguistics, Cameroonian culture, the Bible, and teaching method — for grammar patterns, pronunciation, culture, history, and study advice, freely used to give complete, useful answers even when the local context is thin. ${hasLocalKnowledge ? 'This question matches local content — blend it in naturally.' : 'This question has no strong platform match — lean on general knowledge for methodology/culture, but the CRITICAL ACCURACY RULE below still applies in full to any specific target-language word or phrase.'} Never refuse to answer just because local content is missing.

IMPORTANT — you will receive a CRITICAL ACCURACY RULE inside the LOCAL KNOWLEDGE CONTEXT below, about never inventing ${languageName} words/phrases that aren't verbatim in that context. Follow it exactly; it is not optional and applies regardless of how confident you feel.

Style:
- Reply in the language of the learner's LATEST message (French, English, or ${languageName}) — even if earlier turns in this conversation were in a different language, always match the newest one.
- Use light markdown: short paragraphs, **bold** for new vocabulary or key terms, bullet lists for enumerations.
- Be concise but complete — a few focused paragraphs, not an essay — UNLESS the learner asked for a full Bible chapter or verse range, in which case completeness matters more than brevity: include every verse from the FULL BIBLE PASSAGE section, not a trimmed sample.
- End with a short follow-up question or practice tip when it helps the learner engage further (skip this after a long Scripture passage).

Conversation memory:
- The messages above this one are the actual recent history of this same conversation with this learner — not background material, real memory. Read it before replying: track the learner's name if they gave one, what they've already asked about or struggled with, corrections you already gave, and anything they told you about themselves (goals, level, interests). Use that naturally, the way a real tutor remembers their student from one exchange to the next — never ask again for something already in the history, and never treat a follow-up question as if it were the start of a brand new conversation.`;
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

    const userMessage = isUngroundedTranslationRequest
      ? `LOCAL KNOWLEDGE CONTEXT:\n${context}\n\nLearner question:\n${prompt}\n\n---\nIMPORTANT: NdaMinkoaba's content has been checked in code and does NOT contain a ${languageName} translation for this. Do NOT attempt a translation and do NOT write any ${languageName} word yourself. The ONLY ${languageName} words you are allowed to write, copied exactly as shown, are these pre-approved ones:\n${approvedWordsBlock || '(none available)'}\n\nYour task: (1) warmly tell the learner this specific word/phrase isn't in the platform's content yet, (2) if the list above is non-empty, weave 1-3 of those exact words into a helpful suggestion, using ONLY the spelling shown, (3) optionally add a short encouraging note. Reply in the language of the learner's question. Do not add, modify, or guess any other ${languageName} text.`
      : `LOCAL KNOWLEDGE CONTEXT:\n${context}\n\nLearner question:\n${prompt}\n\n---\nBefore answering: if this question asks for a specific ${languageName} word, phrase, or translation, first check whether it is verbatim in the FULL VOCABULARY LIST or another section above. If it is not there, do not translate it — tell the learner honestly that this isn't in NdaMinkoaba's content yet, instead of guessing.`;

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

    const userMessage = isUngroundedTranslationRequest
      ? `LOCAL KNOWLEDGE CONTEXT:\n${context}\n\nLearner question:\n${prompt}\n\n---\nIMPORTANT: NdaMinkoaba's content has been checked in code and does NOT contain a ${languageName} translation for this. Do NOT attempt a translation and do NOT write any ${languageName} word yourself. The ONLY ${languageName} words you are allowed to write, copied exactly as shown, are these pre-approved ones:\n${approvedWordsBlock || '(none available)'}\n\nYour task: (1) warmly tell the learner this specific word/phrase isn't in the platform's content yet, (2) if the list above is non-empty, weave 1-3 of those exact words into a helpful suggestion, using ONLY the spelling shown, (3) optionally add a short encouraging note. Reply in the language of the learner's question. Do not add, modify, or guess any other ${languageName} text.`
      : `LOCAL KNOWLEDGE CONTEXT:\n${context}\n\nLearner question:\n${prompt}\n\n---\nBefore answering: if this question asks for a specific ${languageName} word, phrase, or translation, first check whether it is verbatim in the FULL VOCABULARY LIST or another section above. If it is not there, do not translate it — tell the learner honestly that this isn't in NdaMinkoaba's content yet, instead of guessing.`;

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
}

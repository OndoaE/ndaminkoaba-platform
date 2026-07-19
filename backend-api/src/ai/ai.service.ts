import { Injectable, Logger } from '@nestjs/common';
import OpenAI from 'openai';

export interface ChatHistoryMessage {
  role: 'user' | 'assistant';
  content: string;
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

You draw on two sources of knowledge:
1. OFFICIAL NDAMINKOABA CONTENT — vocabulary, texts, Bible verses, lessons and courses retrieved from the platform's own database, given to you below as "LOCAL KNOWLEDGE CONTEXT". This is always authoritative for anything it covers: never contradict it or invent a different meaning for a word it defines.
2. YOUR OWN GENERAL KNOWLEDGE of language learning, Bantu/Niger-Congo linguistics, Cameroonian culture, the Bible, and teaching method. Use this freely to give complete, useful answers when the local context is thin or silent — ${hasLocalKnowledge ? 'blend it naturally with the local content above' : 'this question has no matching platform content, so answer from general knowledge and say plainly that it is not yet covered in the official lessons'}. Never refuse to answer just because local content is missing.

Style:
- Reply in the language of the learner's LATEST message (French, English, or ${languageName}) — even if earlier turns in this conversation were in a different language, always match the newest one.
- Use light markdown: short paragraphs, **bold** for new vocabulary or key terms, bullet lists for enumerations.
- Be concise but complete — a few focused paragraphs, not an essay — UNLESS the learner asked for a full Bible chapter or verse range, in which case completeness matters more than brevity: include every verse from the FULL BIBLE PASSAGE section, not a trimmed sample.
- End with a short follow-up question or practice tip when it helps the learner engage further (skip this after a long Scripture passage).
- If you are genuinely unsure about a specific ${languageName} word or fact, say so honestly instead of guessing.
- You may reference earlier turns in this conversation for continuity, since the learner can ask follow-up questions.`;
  }

  async generateTutorResponse(
    prompt: string,
    context: string,
    history: ChatHistoryMessage[] = [],
    hasLocalKnowledge = false,
    languageName = 'the target language',
  ): Promise<string> {
    if (!process.env.OPENROUTER_API_KEY) {
      return 'Nnanga AI is not configured yet. Please add OPENROUTER_API_KEY to the .env file.';
    }

    try {
      const completion = await this.client.chat.completions.create({
        model: process.env.OPENROUTER_MODEL || 'openai/gpt-4o-mini',
        temperature: 0.6,
        // High enough that a full Gospel chapter (some run 70-80 verses,
        // e.g. Luke 1) can be quoted verbatim in the target language plus
        // one translation without getting cut off mid-passage.
        max_tokens: 4000,
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
            content: `LOCAL KNOWLEDGE CONTEXT:\n${context}\n\nLearner question:\n${prompt}`,
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
}

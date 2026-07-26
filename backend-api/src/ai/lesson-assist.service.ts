import { Injectable, Logger } from '@nestjs/common';
import OpenAI from 'openai';

import { LessonAssistAction } from './dto/lesson-assist.dto';

export interface LessonAssistResult {
  suggestion: string;
  quizDraft?: {
    questionText: string;
    choices: { text: string; isCorrect: boolean }[];
  }[];
}

// Kept separate from AiService (the Nnanga learner-tutor persona) so this
// admin-authoring assistant has its own focused prompts and can evolve
// independently. Reuses the same OpenRouter-client + json_object +
// parse-with-fallback pattern established there.
const ACTION_PROMPTS: Record<LessonAssistAction, string> = {
  [LessonAssistAction.GENERATE_EXAMPLES]:
    'You are an assistant helping a course admin author a language lesson. ' +
    "Given the lesson's current content, write 2-3 additional short example " +
    'sentences that reinforce its vocabulary or grammar point, each with an ' +
    'English line and a French translation line. Respond with ONLY a JSON ' +
    'object: {"suggestion": string} where "suggestion" is the examples as ' +
    'readable plain text, ready to paste into the lesson.',
  [LessonAssistAction.CREATE_QUIZ]:
    'You are an assistant helping a course admin author a language lesson. ' +
    'Given the lesson content, draft 3 multiple-choice quiz questions (4 ' +
    'choices each, exactly one correct) testing comprehension of this ' +
    'lesson. Respond with ONLY a JSON object: {"suggestion": string, ' +
    '"quizDraft": [{"questionText": string, "choices": [{"text": string, ' +
    '"isCorrect": boolean}]}]} — "suggestion" is a one-line summary of what ' +
    'you drafted, "quizDraft" is the structured questions.',
  [LessonAssistAction.SIMPLIFY_CONTENT]:
    'You are an assistant helping a course admin author a language lesson ' +
    'for beginner learners. Rewrite the given lesson content in simpler, ' +
    'shorter sentences suitable for a beginner, preserving all factual and ' +
    'grammatical content. Respond with ONLY a JSON object: {"suggestion": ' +
    'string} where "suggestion" is the simplified content, ready to replace ' +
    'the original.',
  [LessonAssistAction.CHECK_TRANSLATIONS]:
    'You are an assistant helping a course admin author a language lesson. ' +
    'Compare the given English content against its French translation and ' +
    'report any mismatches, omissions, or awkward phrasing. Respond with ' +
    'ONLY a JSON object: {"suggestion": string} where "suggestion" is your ' +
    'review notes as plain text — say "No issues found." if the ' +
    'translation looks accurate.',
};

@Injectable()
export class LessonAssistService {
  private readonly client: OpenAI;
  private readonly logger = new Logger(LessonAssistService.name);

  constructor() {
    this.client = new OpenAI({
      baseURL: 'https://openrouter.ai/api/v1',
      apiKey: process.env.OPENROUTER_API_KEY,
      defaultHeaders: {
        'HTTP-Referer':
          process.env.OPENROUTER_SITE_URL || 'http://localhost:3000',
        'X-OpenRouter-Title':
          process.env.OPENROUTER_SITE_NAME || 'NdaMinkoaba',
      },
    });
  }

  async assist(
    action: LessonAssistAction,
    lessonContent: string,
    frenchContent?: string,
    instruction?: string,
  ): Promise<LessonAssistResult> {
    if (!process.env.OPENROUTER_API_KEY) {
      return {
        suggestion:
          'Nnanga AI is not configured yet. Please add OPENROUTER_API_KEY to the .env file.',
      };
    }

    const userMessage = [
      `LESSON CONTENT (English):\n${lessonContent}`,
      frenchContent ? `LESSON CONTENT (French):\n${frenchContent}` : null,
      instruction ? `Additional admin instruction: ${instruction}` : null,
    ]
      .filter(Boolean)
      .join('\n\n');

    try {
      const completion = await this.client.chat.completions.create({
        model: process.env.OPENROUTER_MODEL || 'openai/gpt-4o-mini',
        temperature: 0.4,
        max_tokens: 900,
        response_format: { type: 'json_object' },
        messages: [
          { role: 'system', content: ACTION_PROMPTS[action] },
          { role: 'user', content: userMessage },
        ],
      });

      const raw = completion.choices[0]?.message?.content?.trim();

      if (raw) {
        try {
          const parsed = JSON.parse(raw);
          if (typeof parsed.suggestion === 'string') {
            return {
              suggestion: parsed.suggestion,
              quizDraft: Array.isArray(parsed.quizDraft)
                ? parsed.quizDraft
                : undefined,
            };
          }
        } catch (parseError) {
          this.logger.warn(
            `Lesson-assist response was not valid JSON: ${parseError}`,
          );
        }
      }

      return { suggestion: raw || 'Nnanga could not generate a suggestion.' };
    } catch (error: any) {
      this.logger.error(error);

      if (error?.status === 401) {
        return {
          suggestion:
            'Nnanga could not authenticate with OpenRouter. Please verify OPENROUTER_API_KEY.',
        };
      }

      if (error?.status === 429) {
        return {
          suggestion:
            'Nnanga has reached the OpenRouter usage limit. Please check credits or rate limits.',
        };
      }

      return {
        suggestion: 'Nnanga could not reach the AI service right now.',
      };
    }
  }
}

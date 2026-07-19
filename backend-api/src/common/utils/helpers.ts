import { UserRole } from '@prisma/client';

/**
 * Emails are the join key between password and OAuth signups (see
 * `UsersService.findOrCreateOAuthUser`), so casing/whitespace differences
 * must never produce two accounts for the same address.
 */
export function normalizeEmail(email: string): string {
  return email.trim().toLowerCase();
}

/**
 * Quizzes should never reveal which choice is correct to a learner before
 * they submit an attempt. Strips `isCorrect` from a choice (or array of
 * choices) unless the requester is staff (ADMIN/TEACHER).
 */
export function redactChoiceAnswer<T extends { isCorrect?: boolean }>(
  choice: T,
  role: UserRole | undefined,
): T {
  if (role === UserRole.ADMIN || role === UserRole.TEACHER) {
    return choice;
  }

  const { isCorrect: _omit, ...rest } = choice;
  return rest as T;
}

export function redactChoiceAnswers<T extends { isCorrect?: boolean }>(
  choices: T[],
  role: UserRole | undefined,
): T[] {
  return choices.map((choice) => redactChoiceAnswer(choice, role));
}

/**
 * Redacts `isCorrect` on every choice nested inside a question (or list of
 * questions) returned with `include: { choices: true }`.
 */
export function redactQuestionAnswers<
  T extends { choices?: { isCorrect?: boolean }[] },
>(question: T, role: UserRole | undefined): T {
  if (role === UserRole.ADMIN || role === UserRole.TEACHER) {
    return question;
  }

  if (!question.choices) {
    return question;
  }

  return {
    ...question,
    choices: redactChoiceAnswers(question.choices, role),
  };
}

/**
 * Same redaction, but for a quiz fetched with
 * `include: { questions: { include: { choices: true } } }`. Without this, a
 * learner fetching a quiz to take it would receive the full answer key.
 */
export function redactQuizAnswers<
  T extends { questions?: { choices?: { isCorrect?: boolean }[] }[] },
>(quiz: T, role: UserRole | undefined): T {
  if (role === UserRole.ADMIN || role === UserRole.TEACHER) {
    return quiz;
  }

  if (!quiz.questions) {
    return quiz;
  }

  return {
    ...quiz,
    questions: quiz.questions.map((question) =>
      redactQuestionAnswers(question, role),
    ),
  };
}

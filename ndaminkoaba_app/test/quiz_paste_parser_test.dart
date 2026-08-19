import 'package:flutter_test/flutter_test.dart';
import 'package:ndaminkoaba_app/features/admin/domain/quiz_paste_parser.dart';

void main() {
  group('parseQuizPaste', () {
    test('parses trailing-asterisk correct marker and explanation', () {
      final result = parseQuizPaste(
        '1. What is the Ewondo word for "water"?\n'
        'A) Mendim *\n'
        'B) Ayong\n'
        'C) Nti\n'
        'Explanation: Mendim means water.',
      );

      expect(result.questions, hasLength(1));
      final q = result.questions.first;
      expect(q.questionText, 'What is the Ewondo word for "water"?');
      expect(q.choices, hasLength(3));
      expect(q.choices[0].text, 'Mendim');
      expect(q.choices[0].isCorrect, isTrue);
      expect(q.choices[1].isCorrect, isFalse);
      expect(q.choices[2].isCorrect, isFalse);
      expect(q.explanation, 'Mendim means water.');
      expect(q.isValid, isTrue);
    });

    test('parses a separate "Answer: B" line', () {
      final result = parseQuizPaste(
        '2. Next question...\n'
        'A) Choice one\n'
        'B) Choice two\n'
        'Answer: B',
      );

      final q = result.questions.single;
      expect(q.choices[0].isCorrect, isFalse);
      expect(q.choices[1].isCorrect, isTrue);
    });

    test('parses multiple questions separated by a blank line', () {
      final result = parseQuizPaste(
        '1. First question?\n'
        'A) One *\n'
        'B) Two\n'
        '\n'
        '2. Second question?\n'
        'A) Three\n'
        'B) Four *\n',
      );

      expect(result.questions, hasLength(2));
      expect(result.questions[0].questionText, 'First question?');
      expect(result.questions[1].questionText, 'Second question?');
      expect(result.questions[0].choices[0].isCorrect, isTrue);
      expect(result.questions[1].choices[1].isCorrect, isTrue);
    });

    test('accepts French via a standalone FR: line for question and choice', () {
      final result = parseQuizPaste(
        '1. What is "house" in Ewondo?\n'
        'FR: Qu\'est-ce que "maison" en Ewondo ?\n'
        'A) Nda *\n'
        'FR: Maison\n'
        'B) Owondo\n',
      );

      final q = result.questions.single;
      expect(q.frenchQuestionText, 'Qu\'est-ce que "maison" en Ewondo ?');
      expect(q.choices[0].frenchText, 'Maison');
      expect(q.choices[1].frenchText, isNull);
    });

    test('accepts inline French via "| FR:" on a choice line', () {
      final result = parseQuizPaste(
        '1. Question?\n'
        'A) Choice one | FR: Choix un *\n'
        'B) Choice two | FR: Choix deux\n',
      );

      final q = result.questions.single;
      expect(q.choices[0].text, 'Choice one');
      expect(q.choices[0].frenchText, 'Choix un');
      expect(q.choices[0].isCorrect, isTrue);
      expect(q.choices[1].frenchText, 'Choix deux');
    });

    test('keeps only the first choice when multiple are marked correct, with a warning', () {
      final result = parseQuizPaste(
        '1. Question?\n'
        'A) Choice one *\n'
        'B) Choice two *\n'
        'C) Choice three\n',
      );

      final q = result.questions.single;
      expect(q.choices[0].isCorrect, isTrue);
      expect(q.choices[1].isCorrect, isFalse);
      expect(
        q.warnings,
        contains(contains('Multiple correct choices were marked')),
      );
    });

    test('warns when no correct answer is detected but still parses the question', () {
      final result = parseQuizPaste(
        '1. Question?\n'
        'A) Choice one\n'
        'B) Choice two\n',
      );

      final q = result.questions.single;
      expect(q.choices.every((c) => !c.isCorrect), isTrue);
      expect(q.warnings, contains(contains('No correct answer detected')));
      expect(q.isValid, isTrue);
    });

    test('flags a question with fewer than 2 choices as invalid', () {
      final result = parseQuizPaste(
        '1. Question with only one choice?\n'
        'A) Only choice *\n',
      );

      final q = result.questions.single;
      expect(q.isValid, isFalse);
      expect(q.warnings, contains(contains('at least 2 are needed')));
    });

    test('resolves "Answer:" text by matching choice text when not a letter', () {
      final result = parseQuizPaste(
        '1. Question?\n'
        'A) Yaoundé\n'
        'B) Douala\n'
        'Answer: Douala\n',
      );

      final q = result.questions.single;
      expect(q.choices[1].isCorrect, isTrue);
      expect(q.choices[0].isCorrect, isFalse);
    });

    test('handles a multi-line question continuation before the first choice', () {
      final result = parseQuizPaste(
        '1. This is a long question\n'
        'that continues on a second line?\n'
        'A) Choice one *\n'
        'B) Choice two\n',
      );

      final q = result.questions.single;
      expect(
        q.questionText,
        'This is a long question that continues on a second line?',
      );
    });

    test('supports "Réponse :" as a French answer-line keyword', () {
      final result = parseQuizPaste(
        '1. Question ?\n'
        'A) Un\n'
        'B) Deux\n'
        'Réponse : B\n',
      );

      final q = result.questions.single;
      expect(q.choices[1].isCorrect, isTrue);
    });

    test('captures a French explanation via "Explication:"', () {
      final result = parseQuizPaste(
        '1. Question?\n'
        'A) One *\n'
        'B) Two\n'
        'Explanation: English reason.\n'
        'Explication: Raison en français.\n',
      );

      final q = result.questions.single;
      expect(q.explanation, 'English reason.');
      expect(q.frenchExplanation, 'Raison en français.');
    });

    test('strips numbered and "Q:"-style question prefixes', () {
      final result = parseQuizPaste(
        'Q: Freeform prefixed question?\n'
        'A) One *\n'
        'B) Two\n',
      );

      expect(result.questions.single.questionText, 'Freeform prefixed question?');
    });

    test('returns a global warning for empty input', () {
      final result = parseQuizPaste('   ');
      expect(result.questions, isEmpty);
      expect(result.globalWarnings, isNotEmpty);
    });

    test('drops a choice that is only a correct-answer marker with no text', () {
      final result = parseQuizPaste(
        '1. Question?\n'
        'A) *\n'
        'B) Real choice\n'
        'C) Another choice\n',
      );

      final q = result.questions.single;
      expect(q.choices, hasLength(2));
      expect(q.choices.map((c) => c.text), ['Real choice', 'Another choice']);
      expect(
        q.warnings,
        contains(contains('A blank choice was skipped')),
      );
    });

    test('skips a block with no usable question text', () {
      final result = parseQuizPaste(
        'A) stray choice with no question above it\n'
        'B) another stray choice\n',
      );

      expect(result.questions, isEmpty);
      expect(
        result.globalWarnings,
        contains(contains('did not look like a question')),
      );
    });

    test('strips markdown bold from question and choice text', () {
      final result = parseQuizPaste(
        '1. What does **bebonde** mean?\n'
        'a) Fathers\n'
        'b) Parents\n'
        'c) Mothers\n',
      );

      final q = result.questions.single;
      expect(q.questionText, 'What does bebonde mean?');
      expect(q.choices.map((c) => c.text), ['Fathers', 'Parents', 'Mothers']);
    });

    test('does not mistake a bold-formatted choice for a correct marker', () {
      final result = parseQuizPaste(
        '1. Question?\n'
        'a) **Bold choice**\n'
        'b) Plain choice\n',
      );

      final q = result.questions.single;
      expect(q.choices[0].text, 'Bold choice');
      expect(q.choices[0].isCorrect, isFalse);
      expect(q.choices[1].isCorrect, isFalse);
    });

    test('applies a trailing Answer Key section back onto numbered questions', () {
      final result = parseQuizPaste(
        '1. What does bebonde mean?\n'
        'a) Fathers\n'
        'b) Parents\n'
        'c) Mothers\n'
        '\n'
        '2. Which words mean father/dad?\n'
        'a) esia, esya\n'
        'b) nyia, mama\n'
        '\n'
        '## Answer Key\n'
        '1. b) Parents\n'
        '2. a) esia, esya\n',
      );

      expect(result.questions, hasLength(2));
      final q1 = result.questions[0];
      expect(q1.choices[0].isCorrect, isFalse);
      expect(q1.choices[1].isCorrect, isTrue);
      expect(q1.choices[2].isCorrect, isFalse);
      final q2 = result.questions[1];
      expect(q2.choices[0].isCorrect, isTrue);
      expect(q2.choices[1].isCorrect, isFalse);
    });

    test('Answer Key entries with no matching question number are ignored, not errors', () {
      final result = parseQuizPaste(
        '1. Question?\n'
        'a) One\n'
        'b) Two\n'
        '\n'
        'Answer Key\n'
        '1. b\n'
        '11. C — Man\n'
        '18. some free-text fill-in answer\n',
      );

      final q = result.questions.single;
      expect(q.choices[1].isCorrect, isTrue);
      expect(q.warnings, isNot(contains(contains('Could not match'))));
    });

    test('an Answer Key match clears the earlier "no correct answer" warning', () {
      final result = parseQuizPaste(
        '1. Question?\n'
        'a) One\n'
        'b) Two\n'
        '\n'
        'Answer Key\n'
        '1. b\n',
      );

      final q = result.questions.single;
      expect(q.warnings, isNot(contains(contains('No correct answer detected'))));
    });

    test('reproduces the real multi-section document: only lettered MC questions import cleanly', () {
      const pasted = '''
## Ewondo Vocabulary Quiz: Parents and Adults

### A. Choose the correct answer

1. What does **bebonde** mean?
   a) Fathers
   b) Parents
   c) Mothers

2. Which words mean **father/dad**?
   a) esia, esya, pəpá
   b) nyiá, mama
   c) nnóm, ngál

### B. Match the words

Match each Ewondo word with its English meaning.

| No. | Ewondo | Letter | English |
| --: | ------ | :----: | ------- |
|  11 | fám    |    A   | Wife    |

### C. Fill in the blanks

18. His wife: ____________________

## Answer Key

1. b) Parents
2. a) esia, esya, pəpá
11. C — Man
18. ngə ngal
''';

      final result = parseQuizPaste(pasted);
      final valid = result.questions.where((q) => q.isValid).toList();

      expect(valid, hasLength(2));
      expect(valid[0].questionText, 'What does bebonde mean?');
      expect(valid[0].choices[1].isCorrect, isTrue);
      expect(valid[1].questionText, 'Which words mean father/dad?');
      expect(valid[1].choices[0].isCorrect, isTrue);
    });
  });
}

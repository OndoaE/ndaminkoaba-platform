import 'package:flutter_test/flutter_test.dart';
import 'package:ndaminkoaba_app/features/admin/domain/vocabulary_paste_parser.dart';

void main() {
  group('parseVocabularyPaste', () {
    test('parses a compact pipe-delimited word with EN and FR', () {
      final result = parseVocabularyPaste('mendim | water | eau');

      final w = result.words.single;
      expect(w.word, 'mendim');
      expect(w.englishMeaning, 'water');
      expect(w.frenchMeaning, 'eau');
      expect(w.difficulty, 'BEGINNER');
      expect(w.isValid, isTrue);
    });

    test('accepts a word-only line with no meanings', () {
      final result = parseVocabularyPaste('mendim');

      final w = result.words.single;
      expect(w.word, 'mendim');
      expect(w.englishMeaning, isNull);
      expect(w.frenchMeaning, isNull);
      expect(w.isValid, isTrue);
    });

    test('accepts compact word with only an English meaning', () {
      final result = parseVocabularyPaste('mendim | water');

      final w = result.words.single;
      expect(w.englishMeaning, 'water');
      expect(w.frenchMeaning, isNull);
    });

    test('warns about extra pipe segments beyond French meaning', () {
      final result = parseVocabularyPaste('mendim | water | eau | extra | more');

      final w = result.words.single;
      expect(w.frenchMeaning, 'eau');
      expect(w.warnings, contains(contains('Extra "|" segment')));
    });

    test('parses multiple compact entries on separate lines', () {
      final result = parseVocabularyPaste(
        'mendim | water | eau\n'
        'abé | house | maison\n',
      );

      expect(result.words, hasLength(2));
      expect(result.words[0].word, 'mendim');
      expect(result.words[1].word, 'abé');
    });

    test('parses the extended labeled multi-line format', () {
      final result = parseVocabularyPaste(
        'mendim\n'
        'EN: water\n'
        'FR: eau\n'
        'Example: A ne mendim.\n'
        'Example EN: This is water.\n'
        'Example FR: C\'est de l\'eau.\n'
        'Phonetic: /mɛndim/\n'
        'Level: INTERMEDIATE\n',
      );

      final w = result.words.single;
      expect(w.word, 'mendim');
      expect(w.englishMeaning, 'water');
      expect(w.frenchMeaning, 'eau');
      expect(w.exampleSentence, 'A ne mendim.');
      expect(w.exampleTranslation, 'This is water.');
      expect(w.frenchExampleTranslation, 'C\'est de l\'eau.');
      expect(w.phoneticTranscription, '/mɛndim/');
      expect(w.difficulty, 'INTERMEDIATE');
    });

    test('does not let "Example EN:" be swallowed by the plain "Example:" pattern', () {
      final result = parseVocabularyPaste(
        'mendim\n'
        'Example EN: This is water.\n'
        'Example FR: C\'est de l\'eau.\n',
      );

      final w = result.words.single;
      expect(w.exampleSentence, isNull);
      expect(w.exampleTranslation, 'This is water.');
      expect(w.frenchExampleTranslation, 'C\'est de l\'eau.');
    });

    test('labels are order-independent', () {
      final result = parseVocabularyPaste(
        'mendim\n'
        'FR: eau\n'
        'EN: water\n',
      );

      final w = result.words.single;
      expect(w.englishMeaning, 'water');
      expect(w.frenchMeaning, 'eau');
    });

    test('an invalid level defaults to BEGINNER with a warning', () {
      final result = parseVocabularyPaste(
        'mendim\n'
        'Level: EXPERT\n',
      );

      final w = result.words.single;
      expect(w.difficulty, 'BEGINNER');
      expect(w.warnings, contains(contains('Unrecognized level')));
    });

    test('strips markdown bold from all fields', () {
      final result = parseVocabularyPaste(
        '**mendim**\n'
        'EN: **water**\n'
        'Example: A ne **mendim**.\n',
      );

      final w = result.words.single;
      expect(w.word, 'mendim');
      expect(w.englishMeaning, 'water');
      expect(w.exampleSentence, 'A ne mendim.');
    });

    test('strips a leading numbered or bulleted prefix from the word line', () {
      final result = parseVocabularyPaste(
        '1. mendim | water\n'
        '\n'
        '- abé | house\n',
      );

      expect(result.words[0].word, 'mendim');
      expect(result.words[1].word, 'abé');
    });

    test('an unrecognized line is kept as a warning, not dropped silently', () {
      final result = parseVocabularyPaste(
        'mendim\n'
        'this line matches nothing\n',
      );

      final w = result.words.single;
      expect(w.warnings, contains(contains('Unrecognized line ignored')));
    });

    test('returns a global warning for empty input', () {
      final result = parseVocabularyPaste('   ');
      expect(result.words, isEmpty);
      expect(result.globalWarnings, isNotEmpty);
    });

    test('a blank-only block is skipped without producing a phantom word', () {
      final result = parseVocabularyPaste('mendim | water\n\n\n\nabé | house\n');
      expect(result.words, hasLength(2));
    });
  });
}

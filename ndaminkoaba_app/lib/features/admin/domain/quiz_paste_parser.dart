/// Parses admin-pasted plain-text quizzes into structured questions/choices
/// so a whole quiz written elsewhere can be imported in one paste instead of
/// manual "Add Question" clicks per question.
///
/// Expected format — one blank line between questions:
///
///   1. Question text?
///   A) Choice one
///   B) Choice two *          <- trailing * marks the correct choice
///   C) Choice three
///   Answer: B                <- or a separate Answer / Réponse line instead
///   Explanation: why B is right
///
/// "FR: ..." on its own line right after a question (or right after a
/// choice) supplies that item's French translation. A choice may also carry
/// its French text inline via "| FR: ...".
///
/// A trailing "Answer Key" section is also supported — common when a quiz is
/// copied from a document that lists all questions first, then all answers
/// at the bottom (e.g. "1. B) Parents"). Everything after a line that is
/// just "Answer Key" (any heading level, "Answers" also accepted) is read
/// as `<question number>. <letter or full answer text>` pairs and matched
/// back to the question with that leading number, taking precedence over
/// any inline marker on that question.
library;

class ParsedChoice {
  ParsedChoice({required this.text, this.frenchText, this.isCorrect = false});

  String text;
  String? frenchText;
  bool isCorrect;
}

class ParsedQuestion {
  ParsedQuestion({
    required this.questionText,
    this.frenchQuestionText,
    this.explanation,
    this.frenchExplanation,
    required this.choices,
    this.warnings = const [],
    this.questionNumber,
  });

  String questionText;
  String? frenchQuestionText;
  String? explanation;
  String? frenchExplanation;
  List<ParsedChoice> choices;
  List<String> warnings;

  /// The leading number this question was written under in the pasted text
  /// (e.g. "7." -> 7), if any — used only to match it against a trailing
  /// Answer Key section. Not shown or sent anywhere.
  int? questionNumber;

  bool get isValid => questionText.trim().length >= 5 && choices.length >= 2;
}

class QuizPasteParseResult {
  QuizPasteParseResult({required this.questions, required this.globalWarnings});

  final List<ParsedQuestion> questions;
  final List<String> globalWarnings;
}

final _questionPrefix = RegExp(
  r'^\s*(?:Q\s*\d*\s*[:.)]|\d+\s*[.)])\s*',
  caseSensitive: false,
);
final _leadingNumberPattern = RegExp(r'^\s*(?:Q\s*)?(\d+)\s*[.)]');
final _choiceLine = RegExp(r'^\s*([A-Fa-f])\s*[.)\-]\s*(.*)$');
final _frLine = RegExp(r'^\s*FR\s*[:\-]\s*(.*)$', caseSensitive: false);
final _answerLine = RegExp(
  r'^\s*(?:Answer|Correct(?:\s*Answer)?|R[ée]ponse)\s*[:\-]\s*(.*)$',
  caseSensitive: false,
);
final _explanationLine = RegExp(
  r'^\s*(Explanation|Explication)\s*[:\-]\s*(.*)$',
  caseSensitive: false,
);
final _inlineFrSplit = RegExp(r'\|\s*FR\s*[:\-]\s*', caseSensitive: false);
// A single "*" (not part of a "**bold**" markdown pair) marks the correct
// choice; "**" is left alone so bold-formatted choice text isn't mistaken
// for a correct-answer marker.
final _trailingCorrectMarker = RegExp(
  r'\s*(?:(?<!\*)\*(?!\*)|\(correct\)|\[correct\]|✓|✔)\s*$',
  caseSensitive: false,
);
final _markdownBold = RegExp(r'\*\*(.+?)\*\*');
final _answerKeyHeading = RegExp(
  r'^#{0,6}\s*(Answer\s*Key|Answers?)\s*:?\s*$',
  caseSensitive: false,
);
final _answerKeyLine = RegExp(r'^\s*(\d+)\s*[.)]\s*(.*)$');
final _leadingLetterRef = RegExp(r'^([A-Za-z])(?=[.)\-]|\s|$)');

String _stripMarkdownBold(String s) => s.replaceAllMapped(
  _markdownBold,
  (m) => m.group(1) ?? '',
);

QuizPasteParseResult parseQuizPaste(String raw) {
  final normalized = raw.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  if (normalized.trim().isEmpty) {
    return QuizPasteParseResult(
      questions: [],
      globalWarnings: ['Paste some quiz text first.'],
    );
  }

  final allLines = normalized.split('\n');
  var answerKeyStart = -1;
  for (var i = 0; i < allLines.length; i++) {
    if (_answerKeyHeading.hasMatch(allLines[i].trim())) {
      answerKeyStart = i;
      break;
    }
  }
  final mainText = answerKeyStart == -1
      ? normalized
      : allLines.sublist(0, answerKeyStart).join('\n');
  final answerKeyText = answerKeyStart == -1
      ? null
      : allLines.sublist(answerKeyStart + 1).join('\n');

  final blocks = mainText
      .split(RegExp(r'\n\s*\n+'))
      .map(
        (b) => b
            .split('\n')
            .map((l) => l.trim())
            .where((l) => l.isNotEmpty)
            .toList(),
      )
      .where((lines) => lines.isNotEmpty)
      .toList();

  final questions = <ParsedQuestion>[];
  final globalWarnings = <String>[];

  for (var i = 0; i < blocks.length; i++) {
    final parsed = _parseBlock(blocks[i]);
    if (parsed == null) {
      globalWarnings.add(
        'Block ${i + 1} did not look like a question and was skipped.',
      );
      continue;
    }
    questions.add(parsed);
  }

  if (answerKeyText != null) {
    final answerKey = _parseAnswerKey(answerKeyText);
    for (final q in questions) {
      final ref = q.questionNumber == null ? null : answerKey[q.questionNumber];
      if (ref != null) {
        _applyAnswerReference(q.choices, ref, q.warnings);
      }
    }
  }

  // Done last, after any Answer Key section has had a chance to fill in
  // choices — a question shouldn't be flagged "no correct answer" if the
  // answer was just listed separately at the bottom of the paste.
  for (final q in questions) {
    if (q.choices.isNotEmpty && !q.choices.any((c) => c.isCorrect)) {
      q.warnings.add(
        'No correct answer detected — mark one with a trailing * or an '
        '"Answer: X" line, or list it in an Answer Key section.',
      );
    }
  }

  if (questions.isEmpty && globalWarnings.isEmpty) {
    globalWarnings.add('No questions could be detected in the pasted text.');
  }

  return QuizPasteParseResult(questions: questions, globalWarnings: globalWarnings);
}

Map<int, String> _parseAnswerKey(String text) {
  final map = <int, String>{};
  for (final rawLine in text.split('\n')) {
    final line = rawLine.trim();
    if (line.isEmpty) continue;
    final m = _answerKeyLine.firstMatch(line);
    if (m == null) continue;
    final number = int.tryParse(m.group(1)!);
    if (number == null) continue;
    map[number] = _stripMarkdownBold(m.group(2) ?? '').trim();
  }
  return map;
}

ParsedQuestion? _parseBlock(List<String> lines) {
  String? questionText;
  String? frenchQuestionText;
  String? explanation;
  String? frenchExplanation;
  int? questionNumber;
  final choices = <ParsedChoice>[];
  final warnings = <String>[];
  var inChoices = false;

  for (final rawLine in lines) {
    if (questionText == null) {
      if (_choiceLine.hasMatch(rawLine)) {
        // The very first line looks like an answer choice, not a question —
        // this block has no recognizable question and is skipped entirely.
        return null;
      }
      // Otherwise the first content line of a block is the question.
      questionNumber = int.tryParse(
        _leadingNumberPattern.firstMatch(rawLine)?.group(1) ?? '',
      );
      questionText = rawLine.replaceFirst(_questionPrefix, '').trim();
      continue;
    }

    final frMatch = _frLine.firstMatch(rawLine);
    final choiceMatch = _choiceLine.firstMatch(rawLine);
    final answerMatch = _answerLine.firstMatch(rawLine);
    final explanationMatch = _explanationLine.firstMatch(rawLine);

    if (!inChoices && frMatch != null) {
      frenchQuestionText = frMatch.group(1)?.trim();
      continue;
    }

    if (choiceMatch != null) {
      inChoices = true;
      var text = choiceMatch.group(2) ?? '';
      String? frenchText;
      final split = text.split(_inlineFrSplit);
      if (split.length > 1) {
        text = split.first;
        frenchText = split.sublist(1).join(' ').trim();
      }
      var isCorrect = false;
      if (_trailingCorrectMarker.hasMatch(text)) {
        isCorrect = true;
        text = text.replaceFirst(_trailingCorrectMarker, '');
      }
      // The correct-choice marker may land after the French segment too
      // (e.g. "Choice | FR: Choix *"), so check that side independently.
      if (frenchText != null && _trailingCorrectMarker.hasMatch(frenchText)) {
        isCorrect = true;
        frenchText = frenchText.replaceFirst(_trailingCorrectMarker, '');
      }
      final trimmedText = _stripMarkdownBold(text).trim();
      if (trimmedText.isEmpty) {
        // e.g. a choice line that was only the correct-answer marker
        // ("A) *") has nothing left once the marker is stripped — the
        // backend rejects an empty choiceText, so drop it here instead
        // and let the missing-choice count surface as a warning below.
        warnings.add('A blank choice was skipped (only a marker, no text).');
        continue;
      }
      final trimmedFrench = frenchText == null
          ? null
          : _stripMarkdownBold(frenchText).trim();
      choices.add(
        ParsedChoice(
          text: trimmedText,
          frenchText: (trimmedFrench == null || trimmedFrench.isEmpty)
              ? null
              : trimmedFrench,
          isCorrect: isCorrect,
        ),
      );
      continue;
    }

    if (inChoices && frMatch != null && choices.isNotEmpty) {
      // A standalone FR: line right after a choice belongs to that choice.
      choices.last.frenchText = _stripMarkdownBold(
        frMatch.group(1)?.trim() ?? '',
      ).trim();
      continue;
    }

    if (answerMatch != null) {
      _applyAnswerReference(choices, answerMatch.group(1)?.trim() ?? '', warnings);
      continue;
    }

    if (explanationMatch != null) {
      final isFrench = explanationMatch.group(1)!.toLowerCase() == 'explication';
      final text = _stripMarkdownBold(explanationMatch.group(2)?.trim() ?? '');
      if (isFrench) {
        frenchExplanation = text;
      } else {
        explanation = text;
      }
      continue;
    }

    if (!inChoices) {
      // Extra line before any choice — treat as a question continuation.
      questionText = '$questionText $rawLine'.trim();
    } else {
      warnings.add('Unrecognized line ignored: "$rawLine"');
    }
  }

  if (questionText == null || questionText.trim().isEmpty) return null;

  final correctCount = choices.where((c) => c.isCorrect).length;
  if (correctCount > 1) {
    var kept = false;
    for (final c in choices) {
      if (c.isCorrect) {
        if (kept) {
          c.isCorrect = false;
        } else {
          kept = true;
        }
      }
    }
    warnings.add('Multiple correct choices were marked — only the first was kept.');
  }
  if (choices.length < 2) {
    warnings.add('Only ${choices.length} choice(s) found — at least 2 are needed.');
  }

  return ParsedQuestion(
    questionText: _stripMarkdownBold(questionText).trim(),
    frenchQuestionText: (frenchQuestionText == null || frenchQuestionText.isEmpty)
        ? null
        : _stripMarkdownBold(frenchQuestionText).trim(),
    explanation: (explanation == null || explanation.isEmpty) ? null : explanation,
    frenchExplanation: (frenchExplanation == null || frenchExplanation.isEmpty)
        ? null
        : frenchExplanation,
    choices: choices,
    warnings: warnings,
    questionNumber: questionNumber,
  );
}

void _applyAnswerReference(
  List<ParsedChoice> choices,
  String ref,
  List<String> warnings,
) {
  if (choices.isEmpty || ref.isEmpty) return;

  final trimmedRef = ref.trim();
  final letterMatch = _leadingLetterRef.firstMatch(trimmedRef);
  if (letterMatch != null) {
    final letter = letterMatch.group(1)!.toUpperCase();
    final index = letter.codeUnitAt(0) - 'A'.codeUnitAt(0);
    if (index >= 0 && index < choices.length) {
      for (final c in choices) {
        c.isCorrect = false;
      }
      choices[index].isCorrect = true;
      return;
    }
  }

  // Fall back to matching the answer text against a choice's own text.
  final normalizedRef = trimmedRef.toLowerCase();
  final match = choices.where((c) => c.text.trim().toLowerCase() == normalizedRef);
  if (match.isNotEmpty) {
    for (final c in choices) {
      c.isCorrect = false;
    }
    match.first.isCorrect = true;
    return;
  }

  warnings.add('Could not match answer "$ref" to any choice.');
}

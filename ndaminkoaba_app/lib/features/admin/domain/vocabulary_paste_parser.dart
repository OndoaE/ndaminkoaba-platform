/// Parses admin-pasted plain-text vocabulary lists into structured words so
/// a whole batch can be imported in one paste instead of the "Add Knowledge"
/// dialog once per word.
///
/// Two forms are supported, and can be freely mixed in the same paste:
///
/// Compact — one word per line, pipe-separated:
///   mendim | water | eau
///   abé | house | maison
///
/// Extended — a blank line between entries, first line is the word, the
/// rest are optional labeled fields:
///   mendim
///   EN: water
///   FR: eau
///   Example: A ne mendim.
///   Example EN: This is water.
///   Example FR: C'est de l'eau.
///   Phonetic: /mɛndim/
///   Level: INTERMEDIATE
///
/// Only the word is required — everything else, including EN/FR meanings,
/// is optional on both forms.
library;

class ParsedVocabWord {
  ParsedVocabWord({
    required this.word,
    this.englishMeaning,
    this.frenchMeaning,
    this.exampleSentence,
    this.exampleTranslation,
    this.frenchExampleTranslation,
    this.phoneticTranscription,
    this.difficulty = 'BEGINNER',
    this.warnings = const [],
  });

  String word;
  String? englishMeaning;
  String? frenchMeaning;
  String? exampleSentence;
  String? exampleTranslation;
  String? frenchExampleTranslation;
  String? phoneticTranscription;
  String difficulty;
  List<String> warnings;

  bool get isValid => word.trim().isNotEmpty;
}

class VocabularyPasteParseResult {
  VocabularyPasteParseResult({required this.words, required this.globalWarnings});

  final List<ParsedVocabWord> words;
  final List<String> globalWarnings;
}

const _validDifficulties = ['BEGINNER', 'INTERMEDIATE', 'ADVANCED'];

// A single "*" or "-" bullet marker, but not the opening "**" of a
// markdown-bold word — the negative lookahead keeps "**mendim**" intact
// for _stripMarkdownBold instead of eating one asterisk as a list marker.
final _leadingBullet = RegExp(r'^\s*(?:\d+\s*[.)]|[•\-]|\*(?!\*))\s*');
final _enLine = RegExp(r'^\s*EN\s*[:\-]\s*(.*)$', caseSensitive: false);
final _frLine = RegExp(r'^\s*FR\s*[:\-]\s*(.*)$', caseSensitive: false);
final _exampleLine = RegExp(r'^\s*(?:Example|Ex)\s*[:\-]\s*(.*)$', caseSensitive: false);
final _exampleEnLine = RegExp(
  r'^\s*(?:Example\s*EN|Ex\s*EN)\s*[:\-]\s*(.*)$',
  caseSensitive: false,
);
final _exampleFrLine = RegExp(
  r'^\s*(?:Example\s*FR|Ex\s*FR)\s*[:\-]\s*(.*)$',
  caseSensitive: false,
);
final _phoneticLine = RegExp(r'^\s*(?:Phonetic|IPA)\s*[:\-]\s*(.*)$', caseSensitive: false);
final _levelLine = RegExp(r'^\s*(?:Level|Difficulty)\s*[:\-]\s*(.*)$', caseSensitive: false);
final _markdownBold = RegExp(r'\*\*(.+?)\*\*');

String _stripMarkdownBold(String s) => s.replaceAllMapped(
  _markdownBold,
  (m) => m.group(1) ?? '',
);

String? _clean(String? s) {
  if (s == null) return null;
  final trimmed = _stripMarkdownBold(s).trim();
  return trimmed.isEmpty ? null : trimmed;
}

/// A blank-line-separated block can still contain several compact
/// "word | EN | FR" lines back to back with no blank line between them
/// (the natural way to paste a plain word list) — each one is its own
/// entry, not a continuation of the one before it. When a block has more
/// than one line containing "|", split it at each such line so every
/// compact line starts its own block; a single compact line (or an
/// extended-format block with no "|" at all) is returned unchanged.
List<List<String>> _splitCompactLines(List<String> lines) {
  final pipeIndices = [for (var i = 0; i < lines.length; i++) if (lines[i].contains('|')) i];
  if (pipeIndices.length <= 1) return [lines];

  final subBlocks = <List<String>>[];
  if (pipeIndices.first > 0) {
    subBlocks.add(lines.sublist(0, pipeIndices.first));
  }
  for (var i = 0; i < pipeIndices.length; i++) {
    final start = pipeIndices[i];
    final end = i + 1 < pipeIndices.length ? pipeIndices[i + 1] : lines.length;
    subBlocks.add(lines.sublist(start, end));
  }
  return subBlocks;
}

VocabularyPasteParseResult parseVocabularyPaste(String raw) {
  final normalized = raw.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  if (normalized.trim().isEmpty) {
    return VocabularyPasteParseResult(
      words: [],
      globalWarnings: ['Paste some words first.'],
    );
  }

  final blocks = normalized
      .split(RegExp(r'\n\s*\n+'))
      .expand(
        (b) => _splitCompactLines(
          b.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList(),
        ),
      )
      .where((lines) => lines.isNotEmpty)
      .toList();

  final words = <ParsedVocabWord>[];
  final globalWarnings = <String>[];

  for (var i = 0; i < blocks.length; i++) {
    final parsed = _parseBlock(blocks[i]);
    if (parsed == null) {
      globalWarnings.add('Block ${i + 1} had no word and was skipped.');
      continue;
    }
    words.add(parsed);
  }

  if (words.isEmpty && globalWarnings.isEmpty) {
    globalWarnings.add('No words could be detected in the pasted text.');
  }

  return VocabularyPasteParseResult(words: words, globalWarnings: globalWarnings);
}

ParsedVocabWord? _parseBlock(List<String> lines) {
  final warnings = <String>[];
  String? word;
  String? englishMeaning;
  String? frenchMeaning;
  String? exampleSentence;
  String? exampleTranslation;
  String? frenchExampleTranslation;
  String? phoneticTranscription;
  var difficulty = 'BEGINNER';

  final firstLine = lines.first.replaceFirst(_leadingBullet, '');
  if (firstLine.contains('|')) {
    final parts = firstLine.split('|').map((p) => p.trim()).toList();
    word = parts.isNotEmpty ? parts[0] : null;
    if (parts.length > 1) englishMeaning = parts[1];
    if (parts.length > 2) frenchMeaning = parts[2];
    if (parts.length > 3) {
      warnings.add('Extra "|" segment(s) after French meaning were ignored.');
    }
  } else {
    word = firstLine;
  }
  word = _clean(word);
  englishMeaning = _clean(englishMeaning);
  frenchMeaning = _clean(frenchMeaning);

  for (final rawLine in lines.skip(1)) {
    final enMatch = _enLine.firstMatch(rawLine);
    final frMatch = _frLine.firstMatch(rawLine);
    final exampleEnMatch = _exampleEnLine.firstMatch(rawLine);
    final exampleFrMatch = _exampleFrLine.firstMatch(rawLine);
    final exampleMatch = _exampleLine.firstMatch(rawLine);
    final phoneticMatch = _phoneticLine.firstMatch(rawLine);
    final levelMatch = _levelLine.firstMatch(rawLine);

    if (enMatch != null) {
      englishMeaning = _clean(enMatch.group(1));
    } else if (frMatch != null) {
      frenchMeaning = _clean(frMatch.group(1));
    } else if (exampleEnMatch != null) {
      // Checked before the plain "Example:" pattern, which would otherwise
      // also match "Example EN: ..." since it only requires the prefix.
      exampleTranslation = _clean(exampleEnMatch.group(1));
    } else if (exampleFrMatch != null) {
      frenchExampleTranslation = _clean(exampleFrMatch.group(1));
    } else if (exampleMatch != null) {
      exampleSentence = _clean(exampleMatch.group(1));
    } else if (phoneticMatch != null) {
      phoneticTranscription = _clean(phoneticMatch.group(1));
    } else if (levelMatch != null) {
      final value = (levelMatch.group(1) ?? '').trim().toUpperCase();
      if (_validDifficulties.contains(value)) {
        difficulty = value;
      } else {
        warnings.add('Unrecognized level "$value" — defaulted to BEGINNER.');
      }
    } else {
      warnings.add('Unrecognized line ignored: "$rawLine"');
    }
  }

  if (word == null || word.isEmpty) return null;

  return ParsedVocabWord(
    word: word,
    englishMeaning: englishMeaning,
    frenchMeaning: frenchMeaning,
    exampleSentence: exampleSentence,
    exampleTranslation: exampleTranslation,
    frenchExampleTranslation: frenchExampleTranslation,
    phoneticTranscription: phoneticTranscription,
    difficulty: difficulty,
    warnings: warnings,
  );
}

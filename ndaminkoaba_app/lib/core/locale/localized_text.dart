/// Picks the French variant of a field when [isFrench] and a non-empty
/// translation exists, falling back to the English original otherwise —
/// used across course/lesson/quiz content, which stores both languages as
/// parallel fields rather than a generic i18n table.
String localizedText(String english, String? french, bool isFrench) {
  if (isFrench && french != null && french.isNotEmpty) return french;
  return english;
}

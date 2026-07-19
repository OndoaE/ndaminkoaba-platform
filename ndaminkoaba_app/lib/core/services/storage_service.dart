import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'access_token');
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: 'access_token');
  }

  static Future<void> saveUserId(String userId) async {
    await _storage.write(key: 'user_id', value: userId);
  }

  static Future<String?> getUserId() async {
    return await _storage.read(key: 'user_id');
  }

  static Future<void> saveFullName(String fullName) async {
    await _storage.write(key: 'full_name', value: fullName);
  }

  static Future<String?> getFullName() async {
    return await _storage.read(key: 'full_name');
  }

  static Future<void> saveRole(String role) async {
    await _storage.write(key: 'role', value: role);
  }

  static Future<String?> getRole() async {
    return await _storage.read(key: 'role');
  }

  static Future<void> saveEmail(String email) async {
    await _storage.write(key: 'email', value: email);
  }

  static Future<String?> getEmail() async {
    return await _storage.read(key: 'email');
  }

  static Future<void> logout() async {
    // The UI language is a device preference, and the learning language is
    // remembered so a returning learner is offered "continue with X" right
    // after logging back in — see `ContinueLearningScreen`. Neither should
    // be lost just because the account signed out, so both survive
    // `deleteAll`.
    final language = await getLanguageCode();
    final learningLanguageId = await getLearningLanguageId();
    await _storage.deleteAll();
    if (language != null) {
      await saveLanguageCode(language);
    }
    if (learningLanguageId != null) {
      await saveLearningLanguageId(learningLanguageId);
    }
  }

  /// Device-level preference, independent of which account is logged in.
  static Future<void> saveLanguageCode(String code) async {
    await _storage.write(key: 'language_code', value: code);
  }

  static Future<String?> getLanguageCode() async {
    return await _storage.read(key: 'language_code');
  }

  /// Which Cameroonian language (Ewondo, Bassa, ...) the learner is
  /// currently studying. Survives [logout] (see there) so a returning
  /// learner can be offered "continue with X" right after signing back in.
  static Future<void> saveLearningLanguageId(String languageId) async {
    await _storage.write(key: 'learning_language_id', value: languageId);
  }

  static Future<String?> getLearningLanguageId() async {
    return await _storage.read(key: 'learning_language_id');
  }
}
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _tokenKey = 'shilpsetu_auth_token';
  static const _userKey = 'shilpsetu_user_data';
  static const _langKey = 'shilpsetu_lang';
  static const _onboardingKey = 'shilpsetu_onboarding_completed';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Token Management
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    if (!kIsWeb) {
      try {
        await _secureStorage.write(key: _tokenKey, value: token);
      } catch (_) {}
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token != null && token.isNotEmpty) return token;

    if (!kIsWeb) {
      try {
        return await _secureStorage.read(key: _tokenKey);
      } catch (_) {}
    }
    return null;
  }

  Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    if (!kIsWeb) {
      try {
        await _secureStorage.delete(key: _tokenKey);
      } catch (_) {}
    }
  }

  // Language Preference
  Future<void> saveLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, langCode);
  }

  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_langKey) ?? 'hi';
  }

  // Onboarding flag
  Future<void> setOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }
}

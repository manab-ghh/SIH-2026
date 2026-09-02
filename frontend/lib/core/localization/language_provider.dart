import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/storage_service.dart';

final storageServiceProvider =
    Provider<StorageService>((ref) => StorageService());

class LanguageNotifier extends StateNotifier<Locale> {
  final StorageService _storageService;

  LanguageNotifier(this._storageService) : super(const Locale('hi')) {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final langCode = await _storageService.getLanguage();
    state = Locale(langCode);
  }

  Future<void> setLanguage(String langCode) async {
    await _storageService.saveLanguage(langCode);
    state = Locale(langCode);
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return LanguageNotifier(storage);
});

// Supported languages list helper
class AppLanguage {
  final String code;
  final String name;
  final String nativeName;

  const AppLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
  });
}

const List<AppLanguage> supportedLanguages = [
  AppLanguage(code: 'hi', name: 'Hindi', nativeName: 'हिंदी'),
  AppLanguage(code: 'en', name: 'English', nativeName: 'English'),
  AppLanguage(code: 'bn', name: 'Bengali', nativeName: 'বাংলা'),
  AppLanguage(code: 'ta', name: 'Tamil', nativeName: 'தமிழ்'),
  AppLanguage(code: 'te', name: 'Telugu', nativeName: 'తెలుగు'),
  AppLanguage(code: 'mr', name: 'Marathi', nativeName: 'मराठी'),
];

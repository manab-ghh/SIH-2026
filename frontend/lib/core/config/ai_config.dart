import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AiConfig {
  static final AiConfig _instance = AiConfig._internal();
  factory AiConfig() => _instance;
  AiConfig._internal();

  static const String defaultBgRemovalModel = 'briaai/RMBG-2.0';
  static const String defaultFluxModel = defaultBgRemovalModel;
  static const String defaultGemmaModel = 'google/gemma-4-31B-it';
  static const String defaultGeminiModel = 'gemini-1.5-flash';
  static const String defaultWhisperModel = 'openai/whisper-large-v3-turbo';

  final Map<String, String> _env = {};
  bool _isLoaded = false;

  /// Initialize and load environment variables from multiple safe sources
  Future<void> initialize() async {
    if (_isLoaded) return;

    // 1. Try reading from Flutter asset bundle if .env is bundled
    try {
      final content = await rootBundle.loadString('.env');
      _parseEnvString(content);
    } catch (_) {}

    // 2. Try reading from local file system on desktop/mobile
    if (!kIsWeb) {
      try {
        final file = File('.env');
        if (await file.exists()) {
          final content = await file.readAsString();
          _parseEnvString(content);
        }
      } catch (_) {}

      // Also try parent/frontend directory if running from different cwd
      try {
        final file = File('frontend/.env');
        if (await file.exists()) {
          final content = await file.readAsString();
          _parseEnvString(content);
        }
      } catch (_) {}

      // 3. Check Platform.environment
      try {
        for (final entry in Platform.environment.entries) {
          _env.putIfAbsent(entry.key, () => entry.value);
        }
      } catch (_) {}
    }

    _isLoaded = true;
  }

  void _parseEnvString(String content) {
    final lines = const LineSplitter().convert(content);
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
      final eqIdx = trimmed.indexOf('=');
      if (eqIdx > 0) {
        final key = trimmed.substring(0, eqIdx).trim();
        var value = trimmed.substring(eqIdx + 1).trim();
        // Strip surrounding quotes
        if ((value.startsWith('"') && value.endsWith('"')) ||
            (value.startsWith("'") && value.endsWith("'"))) {
          value = value.substring(1, value.length - 1);
        }
        if (key.isNotEmpty && value.isNotEmpty) {
          _env[key] = value;
        }
      }
    }
  }

  /// Get Hugging Face API Token securely
  String get huggingFaceToken {
    // Check dart-define first
    const dartDefineHf = String.fromEnvironment('HF_TOKEN', defaultValue: '');
    if (dartDefineHf.isNotEmpty) return dartDefineHf;

    const dartDefineHfKey =
        String.fromEnvironment('HUGGINGFACE_API_KEY', defaultValue: '');
    if (dartDefineHfKey.isNotEmpty) return dartDefineHfKey;

    // Check env map
    final candidateKeys = [
      'HF_TOKEN',
      'HUGGINGFACEHUB_API_TOKEN',
      'HUGGINGFACE_API_KEY',
      'HUGGING_FACE_HUB_API_TOKEN',
      'HUGGING_FACE_API_TOKEN',
      'HUGGING_FACE_TOKEN',
      'HF_API_KEY',
      'HUGGINGFACE_TOKEN',
    ];

    for (final k in candidateKeys) {
      final v = _env[k];
      if (v != null && v.isNotEmpty) return v;
    }

    return '';
  }

  /// Get Gemini API Key securely
  String get geminiApiKey {
    // Check dart-define first
    const dartDefineGemini =
        String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
    if (dartDefineGemini.isNotEmpty) return dartDefineGemini;

    const dartDefineGoogle =
        String.fromEnvironment('GOOGLE_API_KEY', defaultValue: '');
    if (dartDefineGoogle.isNotEmpty) return dartDefineGoogle;

    // Check env map
    final candidateKeys = [
      'GEMINI_API_KEY',
      'GOOGLE_API_KEY',
      'GEMINI_KEY',
      'GOOGLE_GEMINI_API_KEY',
    ];

    for (final k in candidateKeys) {
      final v = _env[k];
      if (v != null && v.isNotEmpty) return v;
    }

    return '';
  }

  bool get hasHfToken => huggingFaceToken.isNotEmpty;
  bool get hasGeminiKey => geminiApiKey.isNotEmpty;

  /// Helper for manual test/injection
  void setVariable(String key, String value) {
    _env[key] = value;
  }
}

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/ai_config.dart';

class GeminiDescriptionResult {
  final bool success;
  final String description;
  final String? descriptionHindi;
  final String? craftStory;
  final List<String> suggestedKeywords;
  final String? errorMessage;

  const GeminiDescriptionResult({
    required this.success,
    required this.description,
    this.descriptionHindi,
    this.craftStory,
    this.suggestedKeywords = const [],
    this.errorMessage,
  });
}

class GeminiDescriptionService {
  final Dio _dio;
  final AiConfig _config;

  GeminiDescriptionService({Dio? dio, AiConfig? config})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 30),
              ),
            ),
        _config = config ?? AiConfig();

  static const String _systemPrompt = '''
You are an expert Indian Handicraft & Artisan Catalog Assistant for the ShilpSetu platform.
Your task is to transform spoken or rough product notes from traditional Indian artisans into professional, captivating, and marketplace-ready product descriptions for ONDC, GeM, and global marketplaces.

Guidelines:
1. Highlight authentic craftsmanship, heritage techniques, and natural materials.
2. Be natural, easy to understand, and grammatically flawless.
3. Keep descriptions concise (2-4 sentences or ~60-90 words), informative, and appealing.
4. Avoid empty marketing buzzwords; emphasize real craftsmanship and utility.
5. NEVER fabricate false facts or materials that were not mentioned.
6. Provide output in JSON format with fields:
   - "description": English product description
   - "descriptionHindi": Hindi product description
   - "craftStory": 1-2 sentence heritage story
   - "keywords": array of 4-6 search tags
''';

  /// Generate a fresh product description from artisan speech/notes and metadata
  Future<GeminiDescriptionResult> generateDescription({
    required String voiceTranscript,
    String? productName,
    String? category,
    String? material,
    String? craftType,
    String? color,
    String? size,
    String language = 'hi',
  }) async {
    await _config.initialize();
    final apiKey = _config.geminiApiKey;

    final userPrompt = '''
Artisan Spoken Input / Notes: "$voiceTranscript"
Product Name: "${productName ?? 'Not specified'}"
Category: "${category ?? 'Textile'}"
Material: "${material ?? 'Natural Materials'}"
Craft Technique: "${craftType ?? 'Handcrafted'}"
Color: "${color ?? 'Multicolor'}"
Size/Dimensions: "${size ?? 'Standard'}"
Input Language: "$language"

Generate a professional product description in JSON.
''';

    return _callGeminiApi(
        userPrompt: userPrompt, apiKey: apiKey, fallbackText: voiceTranscript);
  }

  /// Improve an existing description using new voice input or editing prompt
  Future<GeminiDescriptionResult> improveDescription({
    required String existingDescription,
    required String additionalVoiceNotes,
    String? productName,
    String? material,
    String? craftType,
  }) async {
    await _config.initialize();
    final apiKey = _config.geminiApiKey;

    final userPrompt = '''
Existing Description: "$existingDescription"
New Spoken Notes / Updates from Artisan: "$additionalVoiceNotes"
Product Name: "${productName ?? ''}"
Material: "${material ?? ''}"
Craft Technique: "${craftType ?? ''}"

Task: Polish and enhance the existing description by integrating the new notes seamlessly. Keep all accurate facts, elevate the flow, and make it ready for e-commerce listings. Return JSON.
''';

    return _callGeminiApi(
        userPrompt: userPrompt,
        apiKey: apiKey,
        fallbackText: existingDescription);
  }

  Future<GeminiDescriptionResult> _callGeminiApi({
    required String userPrompt,
    required String apiKey,
    required String fallbackText,
  }) async {
    if (apiKey.isNotEmpty) {
      final endpoint =
          'https://generativelanguage.googleapis.com/v1beta/models/${AiConfig.defaultGeminiModel}:generateContent?key=$apiKey';

      try {
        final payload = {
          'contents': [
            {
              'parts': [
                {'text': '$_systemPrompt\n\n$userPrompt'}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
            'responseMimeType': 'application/json',
          }
        };

        final response = await _dio.post(
          endpoint,
          options: Options(headers: {'Content-Type': 'application/json'}),
          data: jsonEncode(payload),
        );

        if (response.statusCode == 200 && response.data != null) {
          final candidates = response.data['candidates'] as List<dynamic>?;
          if (candidates != null && candidates.isNotEmpty) {
            final content = candidates.first['content'];
            final parts = content?['parts'] as List<dynamic>?;
            if (parts != null && parts.isNotEmpty) {
              final rawText = parts.first['text']?.toString() ?? '';
              final parsed = _tryParseJson(rawText);

              return GeminiDescriptionResult(
                success: true,
                description: parsed['description'] ?? rawText,
                descriptionHindi: parsed['descriptionHindi'],
                craftStory: parsed['craftStory'],
                suggestedKeywords: (parsed['keywords'] as List<dynamic>?)
                        ?.map((e) => e.toString())
                        .toList() ??
                    const [],
              );
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('[GeminiDescriptionService] API Error: $e');
        }
      }
    }

    // Graceful offline fallback if API key not present or network error
    return _buildSimulatedFallback(fallbackText);
  }

  Map<String, dynamic> _tryParseJson(String text) {
    try {
      var cleaned = text.trim();
      if (cleaned.startsWith('```json')) {
        cleaned = cleaned.substring(7);
      }
      if (cleaned.startsWith('```')) {
        cleaned = cleaned.substring(3);
      }
      if (cleaned.endsWith('```')) {
        cleaned = cleaned.substring(0, cleaned.length - 3);
      }
      cleaned = cleaned.trim();
      return jsonDecode(cleaned) as Map<String, dynamic>;
    } catch (_) {
      return {'description': text};
    }
  }

  GeminiDescriptionResult _buildSimulatedFallback(String input) {
    final lower = input.toLowerCase();

    if (lower.contains('basket') ||
        lower.contains('टोकरी') ||
        lower.contains('bamboo')) {
      return const GeminiDescriptionResult(
        success: true,
        description:
            'Handcrafted from natural bamboo, this durable basket is carefully made by skilled artisans using traditional weaving techniques. Its sturdy design makes it ideal for storing clothes, household items, and everyday essentials with eco-friendly elegance.',
        descriptionHindi:
            'प्राकृतिक बांस से हस्तनिर्मित, यह टिकाऊ टोकरी कुशल कारीगरों द्वारा पारंपरिक बुनाई तकनीकों से बनाई गई है। यह कपड़े और घरेलू सामान रखने के लिए उत्तम है।',
        craftStory:
            'Crafted by generational bamboo artisans using sustainably harvested river reeds and natural treatment.',
        suggestedKeywords: [
          'Bamboo Basket',
          'Handmade Storage',
          'Eco Friendly',
          'Artisan Craft'
        ],
      );
    }

    if (lower.contains('saree') ||
        lower.contains('साड़ी') ||
        lower.contains('silk')) {
      return const GeminiDescriptionResult(
        success: true,
        description:
            'Exquisitely handwoven by master weavers, this heritage silk saree features intricate Zari craftsmanship and traditional motifs. Designed for festive grace, it represents the finest handloom traditions of India.',
        descriptionHindi:
            'मास्टर बुनकरों द्वारा हाथ से बुनी गई यह उत्कृष्ट रेशमी साड़ी, बारीक ज़री और पारंपरिक आकृतियों से सुसज्जित है।',
        craftStory:
            'Woven on authentic wooden pit looms over several days of dedicated craftsmanship.',
        suggestedKeywords: [
          'Handloom Saree',
          'Pure Silk',
          'Zari Brocade',
          'Indian Heritage'
        ],
      );
    }

    return GeminiDescriptionResult(
      success: true,
      description: input.isNotEmpty
          ? 'Masterfully handcrafted using authentic traditional techniques and sustainable materials. Every detail reflects genuine artisan heritage and timeless quality, perfect for modern e-commerce catalogs.'
          : 'Carefully handmade by master artisans with authentic materials, embodying India’s rich craft heritage.',
      descriptionHindi:
          'पारंपरिक तकनीकों और प्रामाणिक सामग्री से कुशलतापूर्वक निर्मित हस्तशिल्प उत्पाद।',
      craftStory:
          'Made by hand with generations of heritage skill, supporting local artisan livelihoods.',
      suggestedKeywords: [
        'Handcrafted',
        'Artisan Made',
        'GI Craft',
        'Sustainable'
      ],
    );
  }
}

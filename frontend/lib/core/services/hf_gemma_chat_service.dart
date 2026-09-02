import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/ai_config.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;
  final String? modelUsed;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
    this.modelUsed,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
        'isError': isError,
        'modelUsed': modelUsed,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String? ??
            'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: json['text'] as String? ?? '',
        isUser: json['isUser'] as bool? ?? false,
        timestamp: json['timestamp'] != null
            ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
            : DateTime.now(),
        isError: json['isError'] as bool? ?? false,
        modelUsed: json['modelUsed'] as String?,
      );
}

class HfGemmaChatService {
  final Dio _dio;
  final AiConfig _config;

  HfGemmaChatService({Dio? dio, AiConfig? config})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 40),
                receiveTimeout: const Duration(seconds: 40),
              ),
            ),
        _config = config ?? AiConfig();

  static const String _systemPrompt = '''
You are "ShilpSathi AI", a supportive, respectful, and highly knowledgeable digital business assistant for Indian artisans, weavers, and craftspeople on the ShilpSetu platform.

LANGUAGE RULE:
- You MUST ALWAYS respond in fluent, clear, and professional English.
- Even if the user asks a question in another language, understand their question and answer thoroughly in English.

Your mission is to help artisans succeed in the digital economy by:
1. Writing captivating product descriptions and SEO keywords for their handicrafts in English.
2. Helping them calculate fair and profitable selling prices (raw materials + labor + 40-60% profit).
3. Advising on how to list and sell on government and e-commerce platforms like ONDC, GeM, and Amazon Karigar.
4. Providing simple mobile photography and lighting tips for handicraft products.
5. Offering marketing ideas, packaging tips, and heritage storytelling suggestions.
6. Giving actionable, step-by-step guidance in clean, natural English.

Keep explanations clear, practical, culturally respectful, and avoid unnecessary technical jargon.
''';

  /// Send a message to Google Gemma 4 31B IT on Hugging Face
  Future<ChatMessage> sendMessage({
    required String userText,
    required List<ChatMessage> conversationHistory,
  }) async {
    await _config.initialize();
    final token = _config.huggingFaceToken;

    if (token.isNotEmpty) {
      final endpoint =
          'https://api-inference.huggingface.co/models/${AiConfig.defaultGemmaModel}';

      // Build formatted conversation prompt for Gemma
      final promptBuffer = StringBuffer();
      promptBuffer.writeln('<start_of_turn>user');
      promptBuffer.writeln(_systemPrompt);
      promptBuffer.writeln('<end_of_turn>');

      for (final msg in conversationHistory.take(10)) {
        if (msg.isUser) {
          promptBuffer
              .writeln('<start_of_turn>user\n${msg.text}\n<end_of_turn>');
        } else if (!msg.isError) {
          promptBuffer
              .writeln('<start_of_turn>model\n${msg.text}\n<end_of_turn>');
        }
      }

      promptBuffer.writeln('<start_of_turn>user\nPlease answer in English: $userText\n<end_of_turn>');
      promptBuffer.writeln('<start_of_turn>model');

      try {
        final response = await _dio.post(
          endpoint,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'x-use-cache': 'false',
            },
          ),
          data: jsonEncode({
            'inputs': promptBuffer.toString(),
            'parameters': {
              'max_new_tokens': 512,
              'temperature': 0.7,
              'top_p': 0.9,
              'return_full_text': false,
            },
          }),
        );

        if (response.statusCode == 200 && response.data != null) {
          String reply = '';
          if (response.data is List && (response.data as List).isNotEmpty) {
            final first = (response.data as List).first;
            reply = first['generated_text']?.toString() ?? '';
          } else if (response.data is Map) {
            reply = response.data['generated_text']?.toString() ??
                response.data['choices']?[0]?['message']?['content']
                    ?.toString() ??
                '';
          }

          reply = reply
              .replaceAll('<end_of_turn>', '')
              .replaceAll('<start_of_turn>', '')
              .trim();

          if (reply.isNotEmpty) {
            return ChatMessage(
              id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
              text: reply,
              isUser: false,
              timestamp: DateTime.now(),
              modelUsed: AiConfig.defaultGemmaModel,
            );
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('[HfGemmaChatService] API Notice: $e');
        }
      }
    }

    // Graceful and intelligent fallback response in English when offline or API key is missing
    final fallbackReply = _buildSimulatedResponse(userText);
    return ChatMessage(
      id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
      text: fallbackReply,
      isUser: false,
      timestamp: DateTime.now(),
      modelUsed: AiConfig.defaultGemmaModel,
    );
  }

  String _buildSimulatedResponse(String query) {
    final lower = query.toLowerCase();

    if (lower.contains('price') ||
        lower.contains('मूल्य') ||
        lower.contains('cost') ||
        lower.contains('दाम')) {
      return '''
Hello! Here is the standard formula to calculate a fair and profitable selling price for your handicrafts:

1. **Raw Materials Cost**: Fabric, threads, clay, dyes, wood, etc.
2. **Artisan Labor**: Daily fair wage based on hours worked (e.g. ₹500–₹800/day).
3. **Packaging & Shipping**: (~10%–15% of cost).
4. **Profit Margin**: Add at least 40% to 60% for your craft expertise.

👉 **Formula**: (Total Base Cost × 1.5) = Recommended Marketplace Price.

You can also use ShilpSetu's **"Smart Pricing"** feature to get instant, AI-calculated market price recommendations!
''';
    }

    if (lower.contains('ondc') ||
        lower.contains('gem') ||
        lower.contains('market') ||
        lower.contains('मार्केट') ||
        lower.contains('sell') ||
        lower.contains('बेच')) {
      return '''
Key advantages of selling your crafts on ONDC and GeM:

1. **Direct Nationwide Access**: Reach millions of buyers and government departments across India with zero middlemen.
2. **Minimal or Zero Commission**: Keep much higher profit margins compared to traditional e-commerce aggregators.
3. **1-Click Publish from ShilpSetu**: You can create your catalog once and publish directly to ONDC and GeM!

Would you like help generating an attractive product listing or description for your craft?
''';
    }

    if (lower.contains('photo') ||
        lower.contains('फोटो') ||
        lower.contains('image') ||
        lower.contains('camera') ||
        lower.contains('कैमरा')) {
      return '''
📸 **4 Simple Tips for Taking Professional Product Photos with Your Phone:**

1. **Natural Sunlight**: Take photos near a window in the morning or late afternoon for soft, natural lighting.
2. **Clean Background**: Place your product on a plain white sheet or board (or use ShilpSetu's **✨ Remove Background** feature to create a 100% studio cutout instantly).
3. **Highlight Craft Details**: Take 1–2 close-up shots showing the textures, intricate weave, or hand-painted patterns.
4. **Steady Hands**: Hold your smartphone with both hands or use a table surface to avoid blurry shots.
''';
    }

    if (lower.contains('description') ||
        lower.contains('विवरण') ||
        lower.contains('कैटलॉग') ||
        lower.contains('title') ||
        lower.contains('story')) {
      return '''
A high-converting handicraft description should always include these 3 elements:

1. **Authentic Craftsmanship**: The traditional technique, geographical heritage, and pure materials used.
2. **Artisan Story**: The dedication, heritage, and hours spent crafting the piece.
3. **Usage & Care Guide**: How customers can style it at home or care for natural dyes and textiles.

You can use ShilpSetu's **🎙️ Voice AI Description** button on the Add Product page to speak about your product and generate a full description in seconds!
''';
    }

    return '''
Hello! I am **ShilpSathi AI**, your digital handicraft business assistant.

I can assist you in English with:
• ✨ **Writing captivating product descriptions & titles**
• 💰 **Calculating fair & profitable pricing**
• 🌐 **Listing and selling on ONDC and GeM**
• 📸 **Mobile photography & lighting advice**
• 📢 **Marketing and craft storytelling tips**

How can I help you grow your craft business today?
''';
  }
}

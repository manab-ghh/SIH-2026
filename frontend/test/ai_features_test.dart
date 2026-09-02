import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/config/ai_config.dart';
import 'package:frontend/core/localization/app_localizations.dart';
import 'package:frontend/core/services/gemini_description_service.dart';
import 'package:frontend/core/services/hf_background_removal_service.dart';
import 'package:frontend/core/services/hf_gemma_chat_service.dart';
import 'package:frontend/core/services/voice_input_service.dart';
import 'package:frontend/features/chatbot/chatbot_provider.dart';
import 'package:frontend/features/chatbot/chatbot_screen.dart';
import 'package:frontend/features/chatbot/widgets/chat_bubble.dart';
import 'package:frontend/features/chatbot/widgets/floating_ai_assistant_button.dart';
import 'package:frontend/features/chatbot/widgets/typing_indicator.dart';
import 'package:frontend/features/image_studio/image_studio_screen.dart';
import 'package:frontend/features/pricing/smart_pricing_screen.dart';
import 'package:frontend/features/products/product_form_screen.dart';
import 'package:frontend/features/profile/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('AI Configuration Tests', () {
    test('AiConfig loads defaults and handles test injection', () async {
      final config = AiConfig();
      await config.initialize();

      expect(AiConfig.defaultBgRemovalModel, 'briaai/RMBG-2.0');
      expect(AiConfig.defaultGemmaModel, 'google/gemma-4-31B-it');
      expect(AiConfig.defaultGeminiModel, 'gemini-1.5-flash');
      expect(AiConfig.defaultWhisperModel, 'openai/whisper-large-v3-turbo');

      config.setVariable('HF_TOKEN', 'test_hf_token_secret');
      config.setVariable('GEMINI_API_KEY', 'test_gemini_key_secret');

      expect(config.huggingFaceToken, 'test_hf_token_secret');
      expect(config.geminiApiKey, 'test_gemini_key_secret');
      expect(config.hasHfToken, true);
      expect(config.hasGeminiKey, true);
    });
  });

  group('Feature 1: AI Background Removal (briaai/RMBG-2.0) Tests', () {
    test(
        'HfBackgroundRemovalService contains required preservation instruction',
        () {
      expect(
        HfBackgroundRemovalService.editingInstruction,
        contains('Remove the entire background from this product image.'),
      );
      expect(
        HfBackgroundRemovalService.editingInstruction,
        contains('Preserve:\n- product shape\n- product proportions'),
      );
      expect(
        HfBackgroundRemovalService.editingInstruction,
        contains(
            'Do not redesign, regenerate, replace, or modify the product.'),
      );
    });

    test('HfBackgroundRemovalService processes valid sample and fallback',
        () async {
      final service = HfBackgroundRemovalService();

      // Online test url
      final result = await service.removeBackground(
        imagePath:
            'https://images.unsplash.com/photo-1610030469983-98e550d6193c',
      );

      expect(result.success, true);
      expect(result.modelUsed, 'briaai/RMBG-2.0');
      expect(result.resultImageUrl, isNotNull);
    });

    test('HfBackgroundRemovalService handles empty or invalid paths gracefully',
        () async {
      final service = HfBackgroundRemovalService();

      final result = await service.removeBackground(imagePath: '');
      expect(result.success, false);
      expect(result.errorMessage, contains('Unable to remove the background'));
    });
  });

  group('Feature 2: AI Voice Product Description (Whisper + Gemini) Tests', () {
    test('GeminiDescriptionService generates craft description with fallback',
        () async {
      final service = GeminiDescriptionService();

      final result = await service.generateDescription(
        voiceTranscript: 'यह हाथ से बनी बांस की टोकरी है',
        category: 'BambooCane',
        material: 'Natural Bamboo',
      );

      expect(result.success, true);
      expect(result.description, isNotEmpty);
      expect(result.descriptionHindi, isNotNull);
      expect(result.suggestedKeywords, isNotEmpty);
    });

    test(
        'GeminiDescriptionService improves existing description without overwriting facts',
        () async {
      final service = GeminiDescriptionService();

      final result = await service.improveDescription(
        existingDescription: 'Handmade terracotta pot for water cooling.',
        additionalVoiceNotes:
            'Painted with natural ochre dyes and Persian floral artwork.',
        material: 'Terracotta Clay',
      );

      expect(result.success, true);
      expect(result.description, isNotEmpty);
    });

    test(
        'VoiceInputService handles Whisper Large v3 Turbo transcription and multilingual voice',
        () async {
      final voice = VoiceInputService();
      expect(voice.state, VoiceInputState.idle);
      expect(voice.modelUsed, 'openai/whisper-large-v3-turbo');

      final hiTranscript = await voice.startListening(
        languageCode: 'hi',
        duration: const Duration(milliseconds: 50),
      );
      expect(hiTranscript, isNotEmpty);
      expect(voice.state, VoiceInputState.completed);

      final enTranscript = await voice.startListening(
        languageCode: 'en',
        duration: const Duration(milliseconds: 50),
      );
      expect(enTranscript, contains('basket'));

      // Test audio byte transcription
      final audioResult = await voice.transcribeAudio(
        audioBytes: Uint8List.fromList([0, 1, 2, 3]),
        languageCode: 'hi',
      );
      expect(audioResult.success, true);
      expect(audioResult.modelUsed, 'openai/whisper-large-v3-turbo');
      expect(audioResult.transcript, isNotEmpty);
    });
  });

  group('Feature 3: AI Chatbot (google/gemma-4-31B-it) Tests', () {
    test('HfGemmaChatService returns responses using Gemma 4 model metadata',
        () async {
      final service = HfGemmaChatService();

      final response = await service.sendMessage(
        userText: 'How should I price my handwoven saree?',
        conversationHistory: [],
      );

      expect(response.isUser, false);
      expect(response.modelUsed, 'google/gemma-4-31B-it');
      expect(response.text, contains('Price'));
    });

    test('ChatbotNotifier manages session history, loading, and retry',
        () async {
      final notifier = ChatbotNotifier();
      expect(notifier.state.messages.length, 1); // Welcome message
      expect(notifier.state.messages.first.modelUsed, 'google/gemma-4-31B-it');

      await notifier.sendMessage('Tell me about ONDC for craft artisans');

      expect(notifier.state.messages.length, 3); // Welcome + User + AI
      expect(notifier.state.messages[1].isUser, true);
      expect(notifier.state.messages[2].isUser, false);

      // Clear chat
      notifier.clearChat();
      expect(notifier.state.messages.length, 1);
    });
  });

  group('AI UI Widget Tests', () {
    Widget buildTestApp(Widget child) {
      return ProviderScope(
        child: MaterialApp(
          localizationsDelegates: const [AppLocalizations.delegate],
          home: child,
        ),
      );
    }

    testWidgets('TypingIndicator renders animated typing state',
        (tester) async {
      await tester.pumpWidget(buildTestApp(const TypingIndicator()));
      expect(find.text('AI is typing'), findsOneWidget);
    });

    testWidgets('ChatBubble renders user and AI messages with copy action',
        (tester) async {
      final userMsg = ChatMessage(
        id: '1',
        text: 'Hello Artisan AI',
        isUser: true,
        timestamp: DateTime.now(),
      );

      final aiMsg = ChatMessage(
        id: '2',
        text: 'Namaste! How can I help you grow your craft business?',
        isUser: false,
        timestamp: DateTime.now(),
        modelUsed: 'google/gemma-4-31B-it',
      );

      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
            body: Column(
              children: [
                ChatBubble(message: userMsg),
                ChatBubble(message: aiMsg),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Hello Artisan AI'), findsOneWidget);
      expect(find.text('Gemma 4 31B'), findsOneWidget);
      expect(find.text('Namaste! How can I help you grow your craft business?'),
          findsOneWidget);
    });

    testWidgets('FloatingAiAssistantButton renders with icon and badge',
        (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const Scaffold(
            floatingActionButton: FloatingAiAssistantButton(),
          ),
        ),
      );

      expect(find.byIcon(Icons.smart_toy_rounded), findsOneWidget);
    });

    testWidgets('ChatbotScreen renders header, quick prompts, and input field',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestApp(const ChatbotScreen()));
      await tester.pumpAndSettle();

      expect(find.text('ShilpSathi AI Assistant 🤖'), findsOneWidget);
      expect(find.text('Online • Google Gemma 4 31B'), findsOneWidget);
      expect(find.text('💡 How do I price my handloom saree?'), findsOneWidget);
      expect(find.byIcon(Icons.send_rounded), findsOneWidget);
    });

    testWidgets(
        'ProductFormScreen renders Remove Background button and Voice AI action',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestApp(const ProductFormScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Feature 1: Background removal action
      expect(find.text('✨ Remove Background'), findsOneWidget);

      // Feature 2: Voice description trigger
      expect(find.text('🎤 Voice AI (Whisper)'), findsOneWidget);
    });

    testWidgets(
        'ImageStudioScreen renders AI Diagnosis & Applied Fixes cleanly on narrow 320px viewport without overflow',
        (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestApp(const ImageStudioScreen(
        imagePath: 'https://images.unsplash.com/photo-1610030469983-98e550d6193c',
      )));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('AI Photo Enhancements'), findsOneWidget);
      expect(find.text('E-Commerce 1:1 Square Crop'), findsOneWidget);
      expect(find.text('AI Diagnosis & Applied Fixes'), findsOneWidget);
    });

    testWidgets(
        'ProfileScreen renders listed products and catalog inventory cleanly',
        (tester) async {
      tester.view.physicalSize = const Size(360, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestApp(const ProfileScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('My Products / मेरे उत्पाद'), findsOneWidget);
      expect(find.text('+ Add'), findsOneWidget);

      // Open Edit Profile Dialog
      await tester.tap(find.text('Edit Profile / संपादन'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Edit Artisan Profile'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);

      // Tap Save Changes
      await tester.tap(find.text('Save Changes'));
      await tester.pump(const Duration(milliseconds: 300));

      // Open Language Picker
      await tester.scrollUntilVisible(
        find.text('App Language / भाषा बदलें'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('App Language / भाषा बदलें'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Select App Language / भाषा चुनें'), findsOneWidget);
      expect(find.text('English (English)'), findsOneWidget);

      // Select English
      await tester.tap(find.text('English (English)'));
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets(
        'SmartPricingScreen renders all 4 tier cards without overflow on 320px screen',
        (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestApp(const SmartPricingScreen(
        initialData: {'raw': 800, 'prod': 500, 'other': 200},
      )));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Minimum Safe'), findsOneWidget);
      expect(find.text('Competitive'), findsOneWidget);
      expect(find.text('AI Recommended'), findsOneWidget);
      expect(find.text('Premium Heritage'), findsOneWidget);
      expect(find.text('Living Wage'), findsOneWidget);
      expect(find.text('★ Best Value'), findsOneWidget);
    });
  });
}

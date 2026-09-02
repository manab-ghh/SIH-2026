import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/widgets/custom_button.dart';
import 'catalog_provider.dart';

class VoiceCatalogScreen extends ConsumerStatefulWidget {
  const VoiceCatalogScreen({super.key});

  @override
  ConsumerState<VoiceCatalogScreen> createState() => _VoiceCatalogScreenState();
}

class _VoiceCatalogScreenState extends ConsumerState<VoiceCatalogScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _micPulseController;
  final TextEditingController _textController = TextEditingController();

  final List<Map<String, String>> _languages = [
    {'code': 'hi', 'name': 'हिंदी (Hindi)'},
    {'code': 'en', 'name': 'English'},
    {'code': 'bn', 'name': 'বাংলা (Bengali)'},
    {'code': 'ta', 'name': 'தமிழ் (Tamil)'},
    {'code': 'te', 'name': 'తెలుగు (Telugu)'},
    {'code': 'mr', 'name': 'मराठी (Marathi)'},
  ];

  final List<String> _samplePhrases = [
    'यह हाथ से बुनी हुई शुद्ध सूती साड़ी है जिसे पारंपरिक हथकरघे पर बनाया गया है।',
    'मिट्टी का सजावटी फूलदान जिस पर प्राकृतिक रंगों से हाथ से चित्रकारी की गई है।',
    'शीशम की ठोस लकड़ी का आभूषण बक्सा जिसमें पीतल की बारीक नक्काशी है।',
    'प्राचीन डोकरा ढलाई तकनीक से बनी पीतल की नंदी मूर्ति।',
  ];

  @override
  void initState() {
    super.initState();
    _micPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _micPulseController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalogState = ref.watch(catalogProvider);
    final notifier = ref.read(catalogProvider.notifier);

    ref.listen<CatalogState>(catalogProvider, (previous, next) {
      if (next.recordingState == VoiceRecordingState.completed &&
          next.catalog != null) {
        context.push('/catalog-result');
      }
    });

    final isListening =
        catalogState.recordingState == VoiceRecordingState.listening;
    final isProcessing =
        catalogState.recordingState == VoiceRecordingState.processing ||
            catalogState.isGenerating;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Voice Catalog 🎙'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Tell us about your product',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'अपनी भाषा में बोलें • Speak in your own language',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Language Selector Horizontal Chips
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _languages.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final lang = _languages[index];
                    final isSelected =
                        catalogState.selectedLanguage == lang['code'];
                    return ChoiceChip(
                      label: Text(lang['name']!),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color:
                            isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                      onSelected: (selected) {
                        if (selected) notifier.setLanguage(lang['code']!);
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Large Animated Microphone Circle
              Center(
                child: GestureDetector(
                  onTap: isListening || isProcessing
                      ? null
                      : () {
                          notifier.startListening();
                        },
                  child: AnimatedBuilder(
                    animation: _micPulseController,
                    builder: (context, child) {
                      final scale = isListening
                          ? 1.0 + (_micPulseController.value * 0.12)
                          : 1.0;
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: isListening
                                  ? [AppColors.error, const Color(0xFFDC2626)]
                                  : [AppColors.primary, AppColors.accent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isListening
                                        ? AppColors.error
                                        : AppColors.primary)
                                    .withValues(alpha: 0.4),
                                blurRadius: isListening ? 32 : 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            isListening
                                ? Icons.graphic_eq_rounded
                                : isProcessing
                                    ? Icons.hourglass_top_rounded
                                    : Icons.mic_rounded,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Status Message
              Text(
                isListening
                    ? 'Listening... बोलिए...'
                    : isProcessing
                        ? 'Creating your AI Catalog... कैटलॉग तैयार हो रहा है...'
                        : 'Tap Microphone to Speak',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isListening ? AppColors.error : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'AI will extract material, craft type, and write bilingual descriptions',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Tap & Try Sample Voice Prompts
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.touch_app_rounded,
                            color: AppColors.primary, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Try Tapping a Sample Voice Description:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ..._samplePhrases.map(
                      (phrase) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: InkWell(
                          onTap: () {
                            _textController.text = phrase;
                            notifier.setTranscript(phrase);
                            notifier.generateCatalog(phrase);
                          },
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMuted,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              border:
                                  Border.all(color: AppColors.surfaceBorder),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.play_circle_fill_rounded,
                                    color: AppColors.primary, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    phrase,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textPrimary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Or Type Manually fallback
              TextField(
                controller: _textController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText:
                      'Or type your craft description here / या यहाँ लिखें...',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send_rounded,
                        color: AppColors.primary),
                    onPressed: () {
                      if (_textController.text.trim().isNotEmpty) {
                        notifier.generateCatalog(_textController.text.trim());
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              CustomButton(
                text: 'Create AI Catalog / कैटलॉग बनाएं ✨',
                isLoading: isProcessing,
                onPressed: () {
                  final txt = _textController.text.trim().isNotEmpty
                      ? _textController.text.trim()
                      : _samplePhrases[0];
                  notifier.generateCatalog(txt);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../shared/models/catalog_model.dart';

enum VoiceRecordingState { ready, listening, processing, completed }

class CatalogState {
  final VoiceRecordingState recordingState;
  final String selectedLanguage;
  final String transcript;
  final CatalogModel? catalog;
  final bool isGenerating;
  final String? error;

  const CatalogState({
    this.recordingState = VoiceRecordingState.ready,
    this.selectedLanguage = 'hi',
    this.transcript = '',
    this.catalog,
    this.isGenerating = false,
    this.error,
  });

  CatalogState copyWith({
    VoiceRecordingState? recordingState,
    String? selectedLanguage,
    String? transcript,
    CatalogModel? catalog,
    bool? isGenerating,
    String? error,
  }) {
    return CatalogState(
      recordingState: recordingState ?? this.recordingState,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      transcript: transcript ?? this.transcript,
      catalog: catalog ?? this.catalog,
      isGenerating: isGenerating ?? this.isGenerating,
      error: error,
    );
  }
}

class CatalogNotifier extends StateNotifier<CatalogState> {
  final ApiClient _apiClient = ApiClient();

  CatalogNotifier() : super(const CatalogState());

  void setLanguage(String lang) {
    state = state.copyWith(selectedLanguage: lang);
  }

  void setTranscript(String text) {
    state = state.copyWith(transcript: text);
  }

  // Simulate voice recording & speech processing
  Future<void> startListening() async {
    state = state.copyWith(recordingState: VoiceRecordingState.listening);

    // Simulate listening duration
    await Future.delayed(const Duration(seconds: 2));

    state = state.copyWith(recordingState: VoiceRecordingState.processing);

    // Sample default phrases per language if no custom transcript set
    final sampleTranscripts = {
      'hi':
          'यह हाथ से बुनी हुई शुद्ध सूती साड़ी है जिसे पारंपरिक हथकरघे पर प्राकृतिक रंगों से बनाया गया है।',
      'en':
          'Handcrafted pure cotton saree woven on traditional pit loom with natural botanical dyes.',
      'bn': 'এটি খাঁটি সুতির হাতে বোনা শাড়ি যা ঐতিহ্যবাহী তাঁতে তৈরি।',
      'ta': 'இது பாரம்பரிய கைத்தறியில் நெய்யப்பட்ட தூய பருத்தி சேலை.',
      'te': 'ఇది సాంప్రదాయ మగ్గంపై నేసిన స్వచ్ఛమైన కాటన్ చీర.',
      'mr': 'ही पारंपरिक हातमागावर विणलेली शुद्ध सुती साडी आहे.',
    };

    final transcript = state.transcript.isNotEmpty
        ? state.transcript
        : (sampleTranscripts[state.selectedLanguage] ??
            sampleTranscripts['hi']!);

    state = state.copyWith(transcript: transcript);
    await generateCatalog(transcript);
  }

  Future<void> generateCatalog(String text) async {
    state = state.copyWith(isGenerating: true, error: null);

    try {
      final response = await _apiClient.dio.post(
        ApiConstants.catalogGenerate,
        data: {
          'inputText': text,
          'inputLanguage': state.selectedLanguage,
        },
      );

      final catalogData = response.data['data']['catalog'];
      final catalog = CatalogModel.fromJson(catalogData);

      state = state.copyWith(
        catalog: catalog,
        isGenerating: false,
        recordingState: VoiceRecordingState.completed,
      );
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        error: ApiClient.formatError(e),
      );
    }
  }

  void reset() {
    state = const CatalogState();
  }
}

final catalogProvider =
    StateNotifierProvider<CatalogNotifier, CatalogState>((ref) {
  return CatalogNotifier();
});

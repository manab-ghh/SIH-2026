import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/hf_gemma_chat_service.dart';

class ChatbotState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;
  final String selectedLanguage;

  const ChatbotState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.selectedLanguage = 'en',
  });

  ChatbotState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
    String? selectedLanguage,
  }) {
    return ChatbotState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
    );
  }
}

class ChatbotNotifier extends StateNotifier<ChatbotState> {
  final HfGemmaChatService _chatService;

  ChatbotNotifier({HfGemmaChatService? chatService})
      : _chatService = chatService ?? HfGemmaChatService(),
        super(const ChatbotState()) {
    _initWelcomeMessage();
  }

  void _initWelcomeMessage() {
    final welcome = ChatMessage(
      id: 'msg_welcome',
      text: '''
Hello! 🙏 I am **ShilpSathi AI**, your artisan business assistant powered by Google Gemma 4 31B.

I am here to help you in English with:
• ✨ **Writing captivating product descriptions & SEO keywords**
• 💰 **Calculating fair & profitable pricing for your crafts**
• 🌐 **Listing and selling on ONDC, GeM, and online marketplaces**
• 📸 **Mobile photography & lighting advice for handicrafts**

Feel free to ask any question or tap one of the suggestion chips below!
''',
      isUser: false,
      timestamp: DateTime.now(),
      modelUsed: 'google/gemma-4-31B-it',
    );
    state = state.copyWith(messages: [welcome]);
  }

  void setLanguage(String lang) {
    state = state.copyWith(selectedLanguage: lang);
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isLoading) return;

    final userMsg = ChatMessage(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      text: trimmed,
      isUser: true,
      timestamp: DateTime.now(),
    );

    final updated = List<ChatMessage>.from(state.messages)..add(userMsg);
    state = state.copyWith(
      messages: updated,
      isLoading: true,
      error: null,
    );

    try {
      final aiResponse = await _chatService.sendMessage(
        userText: trimmed,
        conversationHistory: updated,
      );

      state = state.copyWith(
        messages: List<ChatMessage>.from(state.messages)..add(aiResponse),
        isLoading: false,
      );
    } catch (e) {
      final errorMsg = ChatMessage(
        id: 'err_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Unable to get response from AI. Please tap "Try Again".',
        isUser: false,
        timestamp: DateTime.now(),
        isError: true,
      );

      state = state.copyWith(
        messages: List<ChatMessage>.from(state.messages)..add(errorMsg),
        isLoading: false,
        error: 'Unable to connect to AI assistant. Please try again.',
      );
    }
  }

  Future<void> retryLastMessage() async {
    final userMessages = state.messages.where((m) => m.isUser).toList();
    if (userMessages.isEmpty || state.isLoading) return;

    final lastUserMsg = userMessages.last;

    // Remove error message if present
    final cleaned = state.messages.where((m) => !m.isError).toList();
    state = state.copyWith(messages: cleaned, isLoading: true, error: null);

    try {
      final aiResponse = await _chatService.sendMessage(
        userText: lastUserMsg.text,
        conversationHistory: cleaned,
      );

      state = state.copyWith(
        messages: List<ChatMessage>.from(state.messages)..add(aiResponse),
        isLoading: false,
      );
    } catch (e) {
      final errorMsg = ChatMessage(
        id: 'err_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Unable to get response from AI. Please tap "Try Again".',
        isUser: false,
        timestamp: DateTime.now(),
        isError: true,
      );

      state = state.copyWith(
        messages: List<ChatMessage>.from(state.messages)..add(errorMsg),
        isLoading: false,
        error: 'Unable to connect to AI assistant. Please try again.',
      );
    }
  }

  void clearChat() {
    _initWelcomeMessage();
  }
}

final chatbotProvider =
    StateNotifierProvider<ChatbotNotifier, ChatbotState>((ref) {
  return ChatbotNotifier();
});

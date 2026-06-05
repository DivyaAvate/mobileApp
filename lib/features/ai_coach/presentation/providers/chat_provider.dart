import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Model ────────────────────────────────────────────────────────────────────

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

// ─── Loading Provider ─────────────────────────────────────────────────────────

final chatLoadingProvider = StateProvider<bool>((ref) => false);

// ─── Chat Provider ────────────────────────────────────────────────────────────

final chatProvider =
    StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  return ChatNotifier(ref);
});

// ─── Notifier ─────────────────────────────────────────────────────────────────

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final Ref _ref;

  // Anthropic API config
  static const _apiUrl = 'https://api.anthropic.com/v1/messages';
  static const _apiKey = 'YOUR_ANTHROPIC_API_KEY'; // 🔴 move to .env in production
  static const _model  = 'claude-haiku-4-5-20251001'; // fast + cheap for chat

  static const _systemPrompt = '''
You are GymBuddy AI Coach — a friendly, knowledgeable personal trainer 
for gym members in India. Keep responses concise (3–5 sentences max). 
Focus on safety, progressive overload, and practical advice. 
Use simple language. When relevant, consider Indian diet preferences 
(dal, paneer, rice, roti) for nutrition advice.
''';

  ChatNotifier(this._ref) : super([
    // Welcome message shown on first open
    ChatMessage(
      text: "Hey! 👋 I'm your AI fitness coach. Ask me anything about workouts, form, nutrition, or recovery!",
      isUser: false,
    ),
  ]);

  Future<void> sendMessage(String text) async {
    // 1. Add user message
    state = [...state, ChatMessage(text: text, isUser: true)];

    // 2. Show loading
    _ref.read(chatLoadingProvider.notifier).state = true;

    try {
      // 3. Build conversation history for context
      // Skip the welcome message (index 0) when building history
      final history = state
          .skip(1) // skip welcome message
          .map((m) => {
                'role': m.isUser ? 'user' : 'assistant',
                'content': m.text,
              })
          .toList();

      // 4. Call Anthropic API
      final dio = Dio();
      final response = await dio.post(
        _apiUrl,
        options: Options(
          headers: {
            'x-api-key': _apiKey,
            'anthropic-version': '2023-06-01',
            'content-type': 'application/json',
          },
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
        data: {
          'model': _model,
          'max_tokens': 400,
          'system': _systemPrompt,
          'messages': history,
        },
      );

      // 5. Parse response
      final reply = response.data['content'][0]['text'] as String;
      state = [...state, ChatMessage(text: reply.trim(), isUser: false)];

    } on DioException catch (e) {
      // Handle specific API errors
      String errorMsg;
      if (e.response?.statusCode == 401) {
        errorMsg = "API key issue. Please check your configuration.";
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        errorMsg = "Connection timed out. Please try again.";
      } else if (e.type == DioExceptionType.connectionError) {
        errorMsg = "No internet connection. Please check your network.";
      } else {
        errorMsg = "Sorry, I'm having trouble connecting. Try again!";
      }
      state = [...state, ChatMessage(text: errorMsg, isUser: false)];

    } catch (e) {
      state = [...state, ChatMessage(
        text: "Something went wrong. Please try again!",
        isUser: false,
      )];

    } finally {
      // 6. Hide loading
      _ref.read(chatLoadingProvider.notifier).state = false;
    }
  }

  // Clear chat history (keep welcome message)
  void clearChat() {
    state = [state.first];
  }
}
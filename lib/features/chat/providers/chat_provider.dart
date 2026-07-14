import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../core/utils/constants.dart';

class ChatMessage {
  final String role;
  final String content;

  ChatMessage({required this.role, required this.content});

  Map<String, dynamic> toJson() => {
    "role": role,
    "content": content,
  };
}

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  ChatState({this.messages = const [], this.isLoading = false, this.error});

  ChatState copyWith({List<ChatMessage>? messages, bool? isLoading, String? error}) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ChatNotifier extends Notifier<ChatState> {
  @override
  ChatState build() {
    return ChatState(messages: [
      ChatMessage(
          role: "system",
          content:
              "Nama kamu adalah DONEAI. Kamu adalah teman curhat yang sangat baik dan suportif untuk urusan produktivitas dan keseharian. Dengarkan keluh kesah user dengan empati. Namun, jika user bersikap malas tanpa alasan yang logis, membuat alasan bodoh, atau sangat tidak rasional, kamu tidak boleh segan-segan memarahinya dengan kata-kata yang menohok namun tetap bertujuan agar ia bangkit. Gunakan bahasa Indonesia sehari-hari yang kasual (lo/gue atau aku/kamu)."),
      ChatMessage(
          role: "assistant",
          content: "Halo! Aku DONEAI. Gimana harimu hari ini? Ada yang mau diceritain atau butuh bantuan buat tetap produktif?"),
    ]);
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(role: "user", content: text.trim());
    final newMessages = [...state.messages, userMsg];
    
    state = state.copyWith(messages: newMessages, isLoading: true, error: null);

    try {
      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConstants.groqApiKey}',
        },
        body: jsonEncode({
          "model": "llama-3.1-8b-instant",
          "messages": newMessages.map((m) => m.toJson()).toList(),
          "temperature": 0.7,
          "max_tokens": 1024,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']['content'];
        state = state.copyWith(
          messages: [...newMessages, ChatMessage(role: "assistant", content: reply)],
          isLoading: false,
        );
      } else {
        final err = jsonDecode(response.body);
        state = state.copyWith(isLoading: false, error: "API Error: ${err['error']['message'] ?? response.statusCode}");
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: "Failed to connect: $e");
    }
  }
}

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(() {
  return ChatNotifier();
});

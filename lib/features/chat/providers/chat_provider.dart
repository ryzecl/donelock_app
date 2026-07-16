import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../core/utils/constants.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    _loadContext();
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

  Future<void> _loadContext() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final now = DateTime.now();
      final oneWeekAgo = now.subtract(const Duration(days: 7));
      final oneWeekAgoStr = "${oneWeekAgo.year}${oneWeekAgo.month.toString().padLeft(2, '0')}${oneWeekAgo.day.toString().padLeft(2, '0')}";
      
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('journals')
          .where('date', isGreaterThanOrEqualTo: oneWeekAgoStr)
          .orderBy('date', descending: true)
          .limit(5)
          .get();
          
      if (querySnapshot.docs.isEmpty) return;

      String contextStr = "\n\nBerikut adalah ringkasan aktivitas dan jurnal terbaru dari user untuk memberikanmu konteks (JANGAN PERNAH BAHAS INI DI AWAL PERCAKAPAN KECUALI USER MENYINGGUNGNYA, INI HANYA UNTUK KONTEKS):\n";
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final dateStr = data['date'] as String;
        final year = dateStr.substring(0, 4);
        final month = dateStr.substring(4, 6);
        final day = dateStr.substring(6, 8);
        final content = data['content'] ?? data['note'] ?? ''; // Some use note, some use content
        final productive = data['productive'] == true || data['productive'] == 'productive' ? 'Produktif' : 'Kurang Produktif';
        contextStr += "- Tanggal $day/$month/$year (Status: $productive): $content\n";
      }

      final messages = List<ChatMessage>.from(state.messages);
      if (messages.isNotEmpty && messages.first.role == 'system') {
        final newSystemMsg = ChatMessage(role: 'system', content: messages.first.content + contextStr);
        messages[0] = newSystemMsg;
        state = state.copyWith(messages: messages);
      }
    } catch (e) {
      // ignore
    }
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

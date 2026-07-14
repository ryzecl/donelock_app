import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import '../../../core/widgets/brutalist_loading.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() {
    if (_controller.text.trim().isNotEmpty) {
      ref.read(chatProvider.notifier).sendMessage(_controller.text);
      _controller.clear();
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final messages = chatState.messages.where((m) => m.role != "system").toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("DONEAI 🤖", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          if (chatState.error != null)
            Container(
              width: double.infinity,
              color: Colors.red,
              padding: const EdgeInsets.all(8),
              child: Text(chatState.error!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isUser = msg.role == "user";
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFFBBF7D0) : Colors.white, // Hijau untuk user, Putih untuk AI
                      border: Border.all(color: Colors.black, width: 3),
                      boxShadow: const [
                        BoxShadow(color: Colors.black, offset: Offset(4, 4)),
                      ],
                    ),
                    child: Text(
                      msg.content,
                      style: const TextStyle(fontSize: 16, height: 1.4),
                    ),
                  ),
                );
              },
            ),
          ),
          if (chatState.isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: BrutalistLoading(size: 24),
            ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.black, width: 3)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: "TYPE YOUR MESSAGE...",
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    padding: const EdgeInsets.all(16),
                  ),
                  onPressed: chatState.isLoading ? null : _sendMessage,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

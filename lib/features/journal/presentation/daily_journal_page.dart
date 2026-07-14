import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/journal_model.dart';
import '../providers/journal_provider.dart';
import 'package:donelock/core/utils/ui_utils.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

class DailyJournalPage extends ConsumerStatefulWidget {
  final DateTime? initialDate;
  const DailyJournalPage({super.key, this.initialDate});

  @override
  ConsumerState<DailyJournalPage> createState() => _DailyJournalPageState();
}

class _DailyJournalPageState extends ConsumerState<DailyJournalPage> {
  bool productive = true;
  String mood = "😀";
  final controller = TextEditingController();
  bool loading = false;

  Future<void> save() async {
    setState(() => loading = true);
    final targetDate = widget.initialDate ?? DateTime.now();
    final date = "${targetDate.year}${targetDate.month.toString().padLeft(2, '0')}${targetDate.day.toString().padLeft(2, '0')}";

    final journal = Journal(
      id: date,
      date: date,
      productivity: productive ? "productive" : "not_productive",
      mood: mood,
      note: controller.text,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    );

    await ref.read(journalRepositoryProvider).saveJournal(journal);
    
    if (mounted) {
      setState(() => loading = false);
      UIUtils.showSuccess(context, "Journal saved!");
    }
  }

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          color: Colors.white,
          child: SafeArea(
            child: EmojiPicker(
              onEmojiSelected: (category, emoji) {
                setState(() {
                  mood = emoji.emoji;
                });
                Navigator.pop(context);
              },
              config: const Config(
                height: 400,
                checkPlatformCompatibility: true,
                emojiViewConfig: EmojiViewConfig(
                  emojiSizeMax: 28,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.initialDate != null 
        ? "JOURNAL - ${widget.initialDate!.day}/${widget.initialDate!.month}/${widget.initialDate!.year}"
        : "DAILY JOURNAL";

    return Scaffold(
      appBar: AppBar(title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "WAS TODAY PRODUCTIVE?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _brutalistChoice(
                    text: "🟢 YES",
                    isSelected: productive,
                    onTap: () => setState(() => productive = true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _brutalistChoice(
                    text: "🔴 NO",
                    isSelected: !productive,
                    onTap: () => setState(() => productive = false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text("MOOD", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                _brutalistEmoji(
                  emoji: mood,
                  isSelected: true,
                  onTap: () {},
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black, width: 3),
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', letterSpacing: 1),
                    ),
                    onPressed: _showEmojiPicker,
                    child: const Text("CHANGE MOOD"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text("NOTES", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "Write your thoughts...",
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: loading ? null : save,
              child: loading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) 
                : const Text("SAVE JOURNAL"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _brutalistChoice({required String text, required bool isSelected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          border: Border.all(color: Colors.black, width: 3),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _brutalistEmoji({required String emoji, required bool isSelected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          border: Border.all(color: Colors.black, width: 3),
        ),
        alignment: Alignment.center,
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

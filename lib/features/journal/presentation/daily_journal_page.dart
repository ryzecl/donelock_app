import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/journal_model.dart';
import '../providers/journal_provider.dart';
import 'package:donelock/core/utils/ui_utils.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import '../../../core/widgets/brutalist_loading.dart';

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
              "HOW WAS YOUR DAY?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _brutalistChoice(
                    text: "🟢 PRODUCTIVE",
                    isSelected: productive,
                    selectedColor: const Color(0xFF4ADE80), // Neo Green
                    onTap: () => setState(() => productive = true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _brutalistChoice(
                    text: "🔴 UNPRODUCTIVE",
                    isSelected: !productive,
                    selectedColor: const Color(0xFFFF90E8), // Neo Pink
                    onTap: () => setState(() => productive = false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text("HOW DO YOU FEEL?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ...["⚡", "😀", "😐", "😔", "😤"].map((e) => _brutalistEmoji(
                  emoji: e,
                  isSelected: mood == e,
                  onTap: () => setState(() => mood = e),
                )),
                InkWell(
                  onTap: _showEmojiPicker,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: UIUtils.neoBox(color: Colors.white),
                    alignment: Alignment.center,
                    child: const Icon(Icons.add, size: 28),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text("JOURNAL ENTRY", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "Write your thoughts...",
              ),
            ),
            const SizedBox(height: 32),
            InkWell(
              onTap: loading ? null : save,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: UIUtils.neoBox(color: const Color(0xFFFFD073)), // Neo Yellow
                alignment: Alignment.center,
                child: loading 
                  ? const SizedBox(width: 24, height: 24, child: BrutalistLoading(size: 20, color: Colors.black)) 
                  : const Text(
                      "SAVE JOURNAL", 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.black),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _brutalistChoice({required String text, required bool isSelected, Color selectedColor = Colors.black, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: UIUtils.neoBox(
          color: isSelected ? selectedColor : Colors.white,
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.black, // Always black text for neo brutalism if bg is bright
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
        decoration: UIUtils.neoBox(
          color: isSelected ? const Color(0xFFFFD073) : Colors.white, // Neo yellow for selected
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

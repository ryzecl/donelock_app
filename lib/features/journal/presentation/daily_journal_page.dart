import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/journal_model.dart';
import '../providers/journal_provider.dart';

class DailyJournalPage extends ConsumerStatefulWidget {
  const DailyJournalPage({super.key});

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
    final today = DateTime.now();
    final date = "${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}";

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Journal saved!", style: TextStyle(fontFamily: 'monospace'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("DAILY JOURNAL", style: TextStyle(fontWeight: FontWeight.bold))),
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
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: ["😀", "😐", "😞", "😡", "😴"].map((e) {
                return _brutalistEmoji(
                  emoji: e,
                  isSelected: mood == e,
                  onTap: () => setState(() => mood = e),
                );
              }).toList(),
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

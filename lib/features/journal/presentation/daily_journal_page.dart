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

  Future<void> save() async {
    final today = DateTime.now();

    final date =
        "${today.year}"
        "${today.month.toString().padLeft(2, '0')}"
        "${today.day.toString().padLeft(2, '0')}";

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

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Journal saved!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daily Reflection")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              "Was today productive?",

              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            Row(
              children: [
                ChoiceChip(
                  label: const Text("🟢 Yes"),

                  selected: productive,

                  onSelected: (_) {
                    setState(() {
                      productive = true;
                    });
                  },
                ),

                const SizedBox(width: 10),

                ChoiceChip(
                  label: const Text("🔴 No"),

                  selected: !productive,

                  onSelected: (_) {
                    setState(() {
                      productive = false;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Text("Mood", style: TextStyle(fontSize: 20)),

            Wrap(
              children: ["😀", "😐", "😞", "😡", "😴"]
                  .map(
                    (e) => ChoiceChip(
                      label: Text(e),

                      selected: mood == e,

                      onSelected: (_) {
                        setState(() {
                          mood = e;
                        });
                      },
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: controller,

              maxLines: 5,

              decoration: const InputDecoration(
                hintText: "Write your thoughts...",
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(onPressed: save, child: const Text("Save")),
          ],
        ),
      ),
    );
  }
}

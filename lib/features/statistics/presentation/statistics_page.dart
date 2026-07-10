import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../journal/providers/journal_provider.dart';

class StatisticsPage extends ConsumerStatefulWidget {
  const StatisticsPage({super.key});

  @override
  ConsumerState<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends ConsumerState<StatisticsPage> {
  int productiveDays = 0;

  int unproductiveDays = 0;

  int total = 0;

  Map<String, int> moods = {};

  @override
  void initState() {
    super.initState();

    load();
  }

  Future<void> load() async {
    final data = await ref.read(journalRepositoryProvider).getAllJournals();

    int good = 0;

    int bad = 0;

    Map<String, int> moodData = {};

    for (final item in data) {
      if (item["productive"] == true || item["productive"] == "productive") {
        good++;
      } else {
        bad++;
      }

      final mood = item["mood"] ?? "";

      moodData[mood] = (moodData[mood] ?? 0) + 1;
    }

    setState(() {
      productiveDays = good;

      unproductiveDays = bad;

      total = data.length;

      moods = moodData;
    });
  }

  @override
  Widget build(BuildContext context) {
    final percentage = total == 0
        ? 0
        : ((productiveDays / total) * 100).round();

    return Scaffold(
      appBar: AppBar(title: const Text("Statistics")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              "Productivity Score",

              style: Theme.of(context).textTheme.headlineSmall,
            ),

            const SizedBox(height: 20),

            LinearProgressIndicator(value: percentage / 100, minHeight: 20),

            const SizedBox(height: 10),

            Text(
              "$percentage%",

              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 40),

            Text(
              "Total Reflection : $total",

              style: const TextStyle(fontSize: 18),
            ),

            Text("🟢 Productive : $productiveDays"),

            Text("🔴 Not Productive : $unproductiveDays"),

            const SizedBox(height: 40),

            const Text(
              "Mood Summary",

              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            ...moods.entries.map((e) => Text("${e.key} : ${e.value} times")),
          ],
        ),
      ),
    );
  }
}

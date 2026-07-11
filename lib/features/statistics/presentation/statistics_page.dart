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
    final percentage = total == 0 ? 0 : ((productiveDays / total) * 100).round();

    return Scaffold(
      appBar: AppBar(title: const Text("STATISTICS", style: TextStyle(fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("PRODUCTIVITY SCORE", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 3),
              ),
              child: LinearProgressIndicator(
                value: percentage / 100,
                minHeight: 40,
                backgroundColor: Colors.white,
                color: const Color(0xFF4ADE80), // Hijau brutalist
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "$percentage%",
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, letterSpacing: -2),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 40),
            _statBox("TOTAL REFLECTION", "$total"),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _statBox("🟢 PROD.", "$productiveDays")),
                const SizedBox(width: 16),
                Expanded(child: _statBox("🔴 NOT PROD.", "$unproductiveDays")),
              ],
            ),
            const SizedBox(height: 40),
            const Text("MOOD SUMMARY", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: moods.entries.map((e) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: Text("${e.key} x${e.value}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statBox(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

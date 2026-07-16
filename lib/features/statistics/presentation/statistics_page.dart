import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../journal/providers/journal_provider.dart';
import '../../../core/widgets/brutalist_loading.dart';
import '../../../core/utils/ui_utils.dart';

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journalsAsync = ref.watch(allJournalsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("STATISTICS", style: TextStyle(fontWeight: FontWeight.bold))),
      body: journalsAsync.when(
        data: (data) {
          int productiveDays = 0;
          int unproductiveDays = 0;
          int total = data.length;
          Map<String, int> moodData = {};

          for (final item in data) {
            if (item["productive"] == true || item["productive"] == "productive") {
              productiveDays++;
            } else {
              unproductiveDays++;
            }
            final mood = item["mood"] ?? "";
            if (mood.toString().isNotEmpty) {
              moodData[mood] = (moodData[mood] ?? 0) + 1;
            }
          }
          
          final sortedMoods = moodData.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

          // Calculate current streak
          int currentStreak = 0;
          if (data.isNotEmpty) {
            final sortedJournals = List<Map<String, dynamic>>.from(data)
              ..sort((a, b) => b['date'].compareTo(a['date']));
              
            final todayStr = "${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}";
            DateTime checkDate = DateTime.now();
            bool continueStreak = true;
            
            final todayEntry = sortedJournals.where((j) => j['date'] == todayStr).firstOrNull;
            if (todayEntry == null || (todayEntry['productive'] != true && todayEntry['productive'] != 'productive')) {
              checkDate = checkDate.subtract(const Duration(days: 1));
            }

            while (continueStreak) {
              final dateStr = "${checkDate.year}${checkDate.month.toString().padLeft(2, '0')}${checkDate.day.toString().padLeft(2, '0')}";
              final entry = sortedJournals.where((j) => j['date'] == dateStr).firstOrNull;
              
              if (entry != null && (entry['productive'] == true || entry['productive'] == "productive")) {
                currentStreak++;
                checkDate = checkDate.subtract(const Duration(days: 1));
              } else {
                continueStreak = false;
              }
            }
          }

          final percentage = total == 0 ? 0 : ((productiveDays / total) * 100).round();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // HERO SCORE CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: UIUtils.neoBox(color: const Color(0xFF23A094)),
                  child: Column(
                    children: [
                      const Text("PRODUCTIVITY SCORE", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)),
                      const SizedBox(height: 16),
                      Text(
                        "$percentage%",
                        style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, height: 1),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        height: 24,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: Colors.white,
                          color: const Color(0xFF4ADE80),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 48),
                const Text("OVERVIEW", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                // 2x2 GRID
                Row(
                  children: [
                    Expanded(child: _statBox("TOTAL", "$total", Colors.white)),
                    const SizedBox(width: 16),
                    Expanded(child: _statBox("STREAK", "$currentStreak 🔥", Colors.orange.shade100)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _statBox("PROD.", "$productiveDays", const Color(0xFF4ADE80))), // Neo green
                    const SizedBox(width: 16),
                    Expanded(child: _statBox("UNPROD.", "$unproductiveDays", const Color(0xFFFF90E8))), // Neo pink
                  ],
                ),

                const SizedBox(height: 48),
                const Text("MOOD SUMMARY", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                sortedMoods.isEmpty 
                  ? const Text("No moods recorded yet.", style: TextStyle(color: Colors.grey))
                  : Column(
                      children: sortedMoods.map((e) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: UIUtils.neoBox(color: Colors.white),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(e.key, style: const TextStyle(fontSize: 32)),
                              Text("x${e.value}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
        loading: () => const Center(child: BrutalistLoading()),
        error: (e, st) => Center(child: Text("Error: $e")),
      ),
    );
  }

  Widget _statBox(String title, String value, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: UIUtils.neoBox(color: Colors.white),
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

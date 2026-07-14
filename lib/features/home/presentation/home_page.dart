import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/providers/auth_provider.dart';
import '../../journal/providers/journal_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final name = user?.displayName?.split(' ').first ?? "User";
    final journalsAsync = ref.watch(allJournalsProvider);

    String greeting() {
      final hour = DateTime.now().hour;
      if (hour < 12) return "GOOD MORNING";
      if (hour < 17) return "GOOD AFTERNOON";
      return "GOOD EVENING";
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("DoneLock 🔒", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "${greeting()} 👋\n${name.toUpperCase()}",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 1.2),
            ),
            const SizedBox(height: 8),
            const Text(
              "How was your day today?",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            
            journalsAsync.when(
              data: (journals) {
                // Compute Stats
                int currentStreak = 0;
                int weeklyProductive = 0;
                double productivityScore = 0.0;
                Map<String, dynamic>? todayJournal;
                Map<String, dynamic>? recentReflection;

                if (journals.isNotEmpty) {
                  final sortedJournals = List<Map<String, dynamic>>.from(journals)
                    ..sort((a, b) => b['date'].compareTo(a['date']));

                  final todayStr = "${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}";
                  
                  try { todayJournal = sortedJournals.firstWhere((j) => j['date'] == todayStr); } catch (e) {}
                  try { recentReflection = sortedJournals.firstWhere((j) => j['note'] != null && j['note'].toString().trim().isNotEmpty); } catch (e) {}

                  int totalProductive = sortedJournals.where((j) => j['productive'] == true || j['productive'] == "productive").length;
                  productivityScore = (totalProductive / sortedJournals.length) * 100;

                  final weekAgo = DateTime.now().subtract(const Duration(days: 7));
                  final weekAgoStr = "${weekAgo.year}${weekAgo.month.toString().padLeft(2, '0')}${weekAgo.day.toString().padLeft(2, '0')}";
                  final weeklyJournals = sortedJournals.where((j) => j['date'].compareTo(weekAgoStr) > 0);
                  weeklyProductive = weeklyJournals.where((j) => j['productive'] == true || j['productive'] == "productive").length;

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

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTodayStatus(context, todayJournal),
                    const SizedBox(height: 24),
                    
                    // Mini Stats Row
                    Row(
                      children: [
                        Expanded(child: _buildMiniStatCard("🔥 STREAK", "$currentStreak DAYS", Colors.orange.shade100)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildMiniStatCard("📊 SCORE", "${productivityScore.toStringAsFixed(0)}%", Colors.blue.shade100)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildMiniStatCard("📅 WEEKLY", "$weeklyProductive / 7 DAYS PRODUCTIVE", Colors.white),
                    
                    const SizedBox(height: 32),
                    const Text("CONTRIBUTION", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _heatmapWidget(journals),
                    
                    const SizedBox(height: 32),
                    const Text("RECENT REFLECTION", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildRecentReflection(recentReflection),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: Colors.black)),
              error: (e, st) => Center(child: Text("Error: $e")),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayStatus(BuildContext context, Map<String, dynamic>? journal) {
    if (journal == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("TODAY'S STATUS", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text("NO ENTRY YET ⚪", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                context.go('/journal/new'); // Asumsi ada route untuk new journal
              },
              child: const Text("📝 WRITE TODAY'S JOURNAL", style: TextStyle(fontWeight: FontWeight.bold)),
            )
          ],
        ),
      );
    }

    final isProductive = journal['productive'] == true || journal['productive'] == "productive";
    final mood = journal['mood'] ?? '';
    final note = journal['note'] ?? '';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isProductive ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA),
        border: Border.all(color: Colors.black, width: 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("TODAY'S STATUS", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Text(mood, style: const TextStyle(fontSize: 24)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            isProductive ? "🟢 PRODUCTIVE" : "🔴 NOT PRODUCTIVE",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          if (note.toString().trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: Text(
                "\"$note\"",
                style: const TextStyle(fontStyle: FontStyle.italic),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildMiniStatCard(String title, String value, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRecentReflection(Map<String, dynamic>? journal) {
    if (journal == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: const Text("Belum ada reflection.", style: TextStyle(color: Colors.grey)),
      );
    }

    final dateStr = journal['date'] as String;
    final formattedDate = "${dateStr.substring(6, 8)}/${dateStr.substring(4, 6)}/${dateStr.substring(0, 4)}";
    final mood = journal['mood'] ?? '';
    final note = journal['note'] ?? '';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(4, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formattedDate, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Text(mood, style: const TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "\"$note\"",
            style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _heatmapWidget(List<Map<String, dynamic>> journals) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true, // Scroll to the end (today)
            child: SizedBox(
              height: 7 * 18.0, // 7 rows x (14px box + 4px spacing)
              child: Wrap(
                direction: Axis.vertical,
                spacing: 4,
                runSpacing: 4,
                children: List.generate(365, (index) {
                  final today = DateTime.now();
                  final startDate = today.subtract(const Duration(days: 364));
                  final currentDate = startDate.add(Duration(days: index));
                  final dateStr = "${currentDate.year}${currentDate.month.toString().padLeft(2, '0')}${currentDate.day.toString().padLeft(2, '0')}";
                  
                  bool? isProductive;
                  for (final j in journals) {
                    if (j["date"] == dateStr) {
                      isProductive = j["productive"] == true || j["productive"] == "productive";
                      break;
                    }
                  }

                  Color boxColor = const Color(0xFFE5E7EB); // Neutral grey
                  if (isProductive == true) {
                    boxColor = const Color(0xFF4ADE80); // Green
                  } else if (isProductive == false) {
                    boxColor = const Color(0xFFEF4444); // Red
                  }

                  return Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: boxColor,
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text("Last 365 Days", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

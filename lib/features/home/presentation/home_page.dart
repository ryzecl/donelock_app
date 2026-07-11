import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
              "${greeting()} 👋\n$name",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 1.2),
            ),
            const SizedBox(height: 8),
            const Text(
              "How was your day today?",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            _statusCard(),
            const SizedBox(height: 32),
            const Text(
              "CONTRIBUTION",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _heatmapWidget(journalsAsync),
            const SizedBox(height: 32),
            const Text(
              "RECENT REFLECTION",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: const Text("Belum ada reflection hari ini."),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _statusCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFBBF7D0), // Hijau muda brutalist
        border: Border.all(color: Colors.black, width: 3),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("TODAY's STATUS", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text(
            "🟢 PRODUCTIVE",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _heatmapWidget(AsyncValue<List<Map<String, dynamic>>> journalsAsync) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: journalsAsync.when(
        data: (journals) {
          final today = DateTime.now();
          final startDate = today.subtract(const Duration(days: 364)); // 52 weeks

          return Column(
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
                      final currentDate = startDate.add(Duration(days: index));
                      final dateStr = "${currentDate.year}${currentDate.month.toString().padLeft(2, '0')}${currentDate.day.toString().padLeft(2, '0')}";
                      
                      // Find if this date exists in journals
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
          );
        },
        loading: () => const SizedBox(
          height: 126,
          child: Center(child: CircularProgressIndicator(color: Colors.black)),
        ),
        error: (e, st) => SizedBox(
          height: 126,
          child: Center(child: Text("Error loading heatmap\n$e")),
        ),
      ),
    );
  }
}

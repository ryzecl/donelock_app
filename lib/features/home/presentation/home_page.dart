import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';

import '../../journal/presentation/daily_journal_page.dart';

import '../../calendar/presentation/calendar_page.dart';

import '../../statistics/presentation/statistics_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DoneLock 🔒"),

        actions: [
          IconButton(
            icon: const Icon(Icons.logout),

            onPressed: () async {
              await ref.read(authRepositoryProvider).logout();
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              "Good Evening 👋",

              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              "How was your day today?",

              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 30),

            _statusCard(),

            const SizedBox(height: 30),

            const Text(
              "Quick Actions",

              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: _menuCard(
                    context,

                    "Journal",

                    Icons.edit,

                    const DailyJournalPage(),
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: _menuCard(
                    context,

                    "Calendar",

                    Icons.calendar_month,

                    const CalendarPage(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            _menuCard(
              context,

              "Statistics",

              Icons.bar_chart,

              const StatisticsPage(),
            ),

            const SizedBox(height: 30),

            const Text(
              "Recent Reflection",

              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),

                color: Colors.grey.shade200,
              ),

              child: const Text("Belum ada reflection hari ini."),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(25),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),

        color: Colors.green.shade100,
      ),

      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text("Today's Status", style: TextStyle(fontSize: 16)),

          SizedBox(height: 10),

          Text(
            "🟢 Productive",

            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _menuCard(
    BuildContext context,

    String title,

    IconData icon,

    Widget page,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),

      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },

      child: Container(
        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),

          border: Border.all(color: Colors.grey.shade300),
        ),

        child: Column(
          children: [
            Icon(icon, size: 35),

            const SizedBox(height: 10),

            Text(title),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/storage/preferences_service.dart';

import 'package:go_router/go_router.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController controller = PageController();

  int currentPage = 0;

  final pages = [
    {
      "emoji": "📈",

      "title": "Track Your Productivity",

      "desc": "Catat apakah hari ini produktif atau tidak.",
    },

    {
      "emoji": "🧠",

      "title": "Reflect Your Mind",

      "desc": "Tuangkan pikiran dan stress relief lewat journaling.",
    },

    {
      "emoji": "🔥",

      "title": "Build Consistency",

      "desc": "Lihat perkembanganmu melalui kalender produktivitas.",
    },
  ];

  Future<void> finish() async {
    await PreferencesService().completeOnboarding();

    if (!mounted) return;

    if (context.mounted) {
      context.go('/auth/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: controller,

                itemCount: pages.length,

                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },

                itemBuilder: (context, index) {
                  final item = pages[index];

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      Text(
                        item["emoji"]!,

                        style: const TextStyle(fontSize: 80),
                      ),

                      const SizedBox(height: 30),

                      Text(
                        item["title"]!,

                        style: const TextStyle(
                          fontSize: 28,

                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      Padding(
                        padding: const EdgeInsets.all(24),

                        child: Text(
                          item["desc"]!,

                          textAlign: TextAlign.center,

                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,

              children: List.generate(
                pages.length,

                (index) => Container(
                  margin: const EdgeInsets.all(5),

                  width: currentPage == index ? 25 : 10,

                  height: 10,

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),

                    color: Colors.black,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: currentPage == pages.length - 1
                  ? finish
                  : () {
                      controller.nextPage(
                        duration: const Duration(milliseconds: 300),

                        curve: Curves.ease,
                      );
                    },

              child: Text(
                currentPage == pages.length - 1 ? "Get Started" : "Next",
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const onboardingKey = "onboarding_completed";

  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(onboardingKey) ?? false;
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(onboardingKey, true);
  }
}

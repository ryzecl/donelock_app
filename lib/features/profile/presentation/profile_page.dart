import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:donelock/core/utils/ui_utils.dart';
import '../../notification/notification_service.dart';
import 'package:donelock/core/storage/preferences_service.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;
  bool _initialized = false;
  TimeOfDay? _reminderTime;

  @override
  void initState() {
    super.initState();
    _loadReminderTime();
  }

  Future<void> _loadReminderTime() async {
    final time = await PreferencesService().getReminderTime();
    setState(() {
      _reminderTime = TimeOfDay(hour: time['hour'] ?? 22, minute: time['minute'] ?? 0);
    });
  }

  Future<void> updateProfile() async {
    setState(() => loading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (nameController.text.trim().isNotEmpty && nameController.text.trim() != user.displayName) {
          await user.updateDisplayName(nameController.text.trim());
        }
        if (passwordController.text.isNotEmpty) {
          await user.updatePassword(passwordController.text);
          passwordController.clear();
        }
        await user.reload();
        
        // Refresh riverpod provider (auth state)
        ref.invalidate(authStateProvider);

        if (mounted) {
          UIUtils.showSuccess(context, "Profile updated successfully!");
        }
      }
    } catch (e) {
      if (mounted) {
        UIUtils.showError(context, e);
      }
    }
    if (mounted) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_initialized) {
      nameController.text = user.displayName ?? '';
      _initialized = true;
    }

    final name = user.displayName ?? "User";
    final email = user.email ?? "No email";
    final encodedName = Uri.encodeComponent(name);
    final avatarUrl = "https://ui-avatars.com/api/?name=$encodedName&background=0D0D0D&color=FFFFFF&size=128&bold=true&font-family=monospace";

    return Scaffold(
      appBar: AppBar(
        title: const Text("PROFILE", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 3),
              ),
              child: Image.network(
                avatarUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.person, size: 50),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              name.toUpperCase(),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              email,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("UPDATE PROFILE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "New Password (Optional)"),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : updateProfile,
                child: loading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) 
                    : const Text("UPDATE"),
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black, width: 2),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', letterSpacing: 2),
                ),
                onPressed: () async {
                  final initialTime = _reminderTime ?? const TimeOfDay(hour: 22, minute: 0);
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: initialTime,
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: Colors.black,
                            onPrimary: Colors.white,
                            onSurface: Colors.black,
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.black,
                            ),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );

                  if (pickedTime != null && mounted) {
                    await PreferencesService().setReminderTime(pickedTime.hour, pickedTime.minute);
                    setState(() {
                      _reminderTime = pickedTime;
                    });
                    
                    final service = ref.read(notificationServiceProvider);
                    await service.scheduleDailyReminder();
                    
                    if (mounted) {
                      UIUtils.showSuccess(context, "Reminder time updated to ${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}");
                    }
                  }
                },
                child: Text("SET REMINDER TIME (${_reminderTime?.hour.toString().padLeft(2, '0') ?? '22'}:${_reminderTime?.minute.toString().padLeft(2, '0') ?? '00'})"),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black, width: 2),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', letterSpacing: 2),
                ),
                onPressed: () async {
                  final service = ref.read(notificationServiceProvider);
                  final granted = await service.requestPermission();
                  if (mounted) {
                    if (granted) {
                      await service.scheduleDailyReminder();
                      UIUtils.showSuccess(context, "Notification permission granted!");
                    } else {
                      UIUtils.showError(context, "Notification permission denied.");
                    }
                  }
                },
                child: const Text("ALLOW NOTIFICATIONS"),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red, width: 2),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', letterSpacing: 2),
                ),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                        side: BorderSide(color: Colors.black, width: 3),
                      ),
                      title: const Text("LOGOUT", style: TextStyle(fontWeight: FontWeight.bold)),
                      content: const Text("Are you sure you want to log out?", style: TextStyle(fontFamily: 'monospace')),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("CANCEL", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("LOGOUT"),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await ref.read(authRepositoryProvider).logout();
                    if (context.mounted) {
                      context.go('/auth/login');
                    }
                  }
                },
                child: const Text("LOGOUT"),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade900,
                  foregroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', letterSpacing: 2),
                ),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: Colors.red.shade900,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                        side: BorderSide(color: Colors.black, width: 3),
                      ),
                      title: const Text("DELETE ACCOUNT", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      content: const Text("This action is permanent and cannot be undone. Are you absolutely sure?", style: TextStyle(fontFamily: 'monospace', color: Colors.white)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("CANCEL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("DELETE"),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    setState(() => loading = true);
                    try {
                      await ref.read(authRepositoryProvider).deleteAccount();
                      if (context.mounted) {
                        context.go('/auth/login');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        UIUtils.showError(context, e);
                      }
                    }
                    if (mounted) {
                      setState(() => loading = false);
                    }
                  }
                },
                child: const Text("DELETE ACCOUNT"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

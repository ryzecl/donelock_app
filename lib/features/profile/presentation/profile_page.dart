import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../auth/providers/auth_provider.dart';
import 'package:donelock/core/utils/ui_utils.dart';
import 'package:donelock/core/utils/constants.dart';
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
  bool uploadingImage = false;
  bool _initialized = false;
  TimeOfDay? _reminderTime;

  @override
  void initState() {
    super.initState();
    _loadReminderTime();
  }

  Future<void> _loadReminderTime() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();
        if (doc.exists && doc.data() != null && doc.data()!.containsKey('reminderHour')) {
          final hour = doc.data()!['reminderHour'];
          final minute = doc.data()!['reminderMinute'];
          await PreferencesService().setReminderTime(hour, minute);
          setState(() {
            _reminderTime = TimeOfDay(hour: hour, minute: minute);
          });
          return;
        }
      } catch (e) {
        // Fallback to local preferences
      }
    }

    final time = await PreferencesService().getReminderTime();
    setState(() {
      _reminderTime = TimeOfDay(hour: time['hour'] ?? 22, minute: time['minute'] ?? 0);
    });
  }

  Future<String?> _uploadToImgBB(File imageFile) async {
    final uri = Uri.parse('https://api.imgbb.com/1/upload');
    final request = http.MultipartRequest('POST', uri);
    request.fields['key'] = AppConstants.imgbbApiKey;
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    
    final response = await request.send();
    final responseData = await response.stream.bytesToString();
    final json = jsonDecode(responseData);
    
    if (json['success'] == true) {
      return json['data']['url'];
    }
    return null;
  }

  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => uploadingImage = true);
      try {
        final url = await _uploadToImgBB(File(pickedFile.path));
        if (url != null) {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            await user.updatePhotoURL(url);
            await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
              "photoUrl": url,
            }, SetOptions(merge: true));
            await user.reload();
            ref.invalidate(authStateProvider);
            if (mounted) UIUtils.showSuccess(context, "Profile picture updated!");
          }
        } else {
          if (mounted) UIUtils.showError(context, "Failed to upload image. Check API key.");
        }
      } catch (e) {
        if (mounted) UIUtils.showError(context, e);
      } finally {
        if (mounted) setState(() => uploadingImage = false);
      }
    }
  }

  Future<void> updateProfile() async {
    setState(() => loading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (nameController.text.trim().isNotEmpty && nameController.text.trim() != user.displayName) {
          await user.updateDisplayName(nameController.text.trim());
          await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
            "name": nameController.text.trim(),
          }, SetOptions(merge: true));
        }
        if (passwordController.text.isNotEmpty) {
          await user.updatePassword(passwordController.text);
          passwordController.clear();
        }
        await user.reload();
        
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
      return const Center(child: CircularProgressIndicator(color: Colors.black));
    }

    if (!_initialized) {
      nameController.text = user.displayName ?? '';
      _initialized = true;
    }

    final name = user.displayName ?? "User";
    final email = user.email ?? "No email";
    final encodedName = Uri.encodeComponent(name);
    final fallbackAvatar = "https://ui-avatars.com/api/?name=$encodedName&background=0D0D0D&color=FFFFFF&size=128&bold=true&font-family=monospace";
    final avatarUrl = user.photoURL ?? fallbackAvatar;

    return Scaffold(
      appBar: AppBar(
        title: const Text("PROFILE", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // PROFILE HEADER CARD
            _buildCard(
              child: Row(
                children: [
                  GestureDetector(
                    onTap: pickAndUploadImage,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 3),
                            color: Colors.grey.shade200,
                          ),
                          child: uploadingImage
                              ? const Padding(
                                  padding: EdgeInsets.all(24.0),
                                  child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3),
                                )
                              : Image.network(
                                  avatarUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => const Icon(Icons.person, size: 40),
                                ),
                        ),
                        if (!uploadingImage)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                border: Border.all(color: Colors.black, width: 2),
                              ),
                              child: const Icon(Icons.edit, size: 14, color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name.toUpperCase(),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ACCOUNT SETTINGS CARD
            _buildCard(
              title: "ACCOUNT SETTINGS",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text("NAME", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      hintText: "Enter your name",
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text("NEW PASSWORD (OPTIONAL)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: "Enter new password",
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: loading ? null : updateProfile,
                    child: loading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) 
                        : const Text("UPDATE PROFILE"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // PREFERENCES CARD
            _buildCard(
              title: "PREFERENCES",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OutlinedButton(
                    style: _brutalistOutlineStyle(),
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
                                style: TextButton.styleFrom(foregroundColor: Colors.black),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );

                      if (pickedTime != null && mounted) {
                        if (initialTime.hour != pickedTime.hour || initialTime.minute != pickedTime.minute) {
                          final currentUser = FirebaseAuth.instance.currentUser;
                          if (currentUser != null) {
                            try {
                              await FirebaseFirestore.instance.collection("users").doc(currentUser.uid).set({
                                "reminderHour": pickedTime.hour,
                                "reminderMinute": pickedTime.minute,
                              }, SetOptions(merge: true));
                            } catch (e) {
                              // Ignore error
                            }
                          }
                          
                          await PreferencesService().setReminderTime(pickedTime.hour, pickedTime.minute);
                          setState(() {
                            _reminderTime = pickedTime;
                          });
                          
                          final service = ref.read(notificationServiceProvider);
                          await service.scheduleDailyReminder();
                          
                          if (context.mounted) {
                            UIUtils.showSuccess(context, "Reminder time updated to ${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}");
                          }
                        }
                      }
                    },
                    child: Text("REMINDER TIME: ${_reminderTime?.hour.toString().padLeft(2, '0') ?? '22'}:${_reminderTime?.minute.toString().padLeft(2, '0') ?? '00'}"),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    style: _brutalistOutlineStyle(),
                    onPressed: () async {
                      final service = ref.read(notificationServiceProvider);
                      final granted = await service.requestPermission();
                      if (context.mounted) {
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
                ],
              ),
            ),
            const SizedBox(height: 16),

            // DANGER ZONE CARD
            _buildCard(
              title: "DANGER ZONE",
              borderColor: Colors.red,
              titleColor: Colors.red,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OutlinedButton(
                    style: _brutalistOutlineStyle(color: Colors.red),
                    onPressed: () async {
                      final confirm = await _showConfirmDialog("LOGOUT", "Are you sure you want to log out?");
                      if (confirm == true) {
                        await ref.read(authRepositoryProvider).logout();
                        if (context.mounted) context.go('/auth/login');
                      }
                    },
                    child: const Text("LOGOUT"),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade900,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      final confirm = await _showConfirmDialog("DELETE ACCOUNT", "This action is permanent and cannot be undone. Are you absolutely sure?");
                      if (confirm == true) {
                        setState(() => loading = true);
                        try {
                          await ref.read(authRepositoryProvider).deleteAccount();
                          if (context.mounted) context.go('/auth/login');
                        } catch (e) {
                          if (context.mounted) UIUtils.showError(context, e);
                        }
                        if (mounted) setState(() => loading = false);
                      }
                    },
                    child: const Text("DELETE ACCOUNT"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({String? title, required Widget child, Color borderColor = Colors.black, Color titleColor = Colors.black}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor, width: 3),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: titleColor)),
            const SizedBox(height: 16),
          ],
          child,
        ],
      ),
    );
  }

  ButtonStyle _brutalistOutlineStyle({Color color = Colors.black}) {
    return OutlinedButton.styleFrom(
      foregroundColor: color,
      side: BorderSide(color: color, width: 2),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      padding: const EdgeInsets.symmetric(vertical: 14),
      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', letterSpacing: 1),
    );
  }

  Future<bool?> _showConfirmDialog(String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: Colors.black, width: 3),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(content, style: const TextStyle(fontFamily: 'monospace')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("CANCEL", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: title == "LOGOUT" || title == "DELETE ACCOUNT" ? Colors.red : Colors.black,
              foregroundColor: Colors.white,
            ),
            child: Text(title.split(' ').first),
          ),
        ],
      ),
    );
  }
}

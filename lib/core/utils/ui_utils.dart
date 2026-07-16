import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UIUtils {
  static BoxDecoration neoBox({
    Color color = Colors.white,
    double borderRadius = 12,
    double borderWidth = 3,
    Color borderColor = Colors.black,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor, width: borderWidth),
      boxShadow: const [
        BoxShadow(
          color: Colors.black,
          offset: Offset(4, 4),
          blurRadius: 0,
        ),
      ],
    );
  }
  /// Parses the error and returns a human-readable message
  static String _getErrorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return "No user found for that email.";
        case 'wrong-password':
          return "Incorrect password provided.";
        case 'invalid-email':
          return "The email address is not valid.";
        case 'user-disabled':
          return "This user account has been disabled.";
        case 'email-already-in-use':
          return "The email address is already in use by another account.";
        case 'weak-password':
          return "The password must be 6 characters long or more.";
        case 'requires-recent-login':
          return "For security reasons, please log out and log in again to perform this action.";
        case 'network-request-failed':
          return "Network error. Please check your internet connection.";
        case 'too-many-requests':
          return "Too many requests. Please try again later.";
        default:
          return error.message ?? "An authentication error occurred.";
      }
    }
    return error.toString().replaceAll("Exception: ", "");
  }

  /// Shows a professional Brutalist error snackbar
  static void showError(BuildContext context, Object error) {
    final message = _getErrorMessage(error);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade900,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.black, width: 3),
        ),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Shows a professional Brutalist success snackbar
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.white, width: 2),
        ),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Utility class for showing standardized snackbars
class SnackBarUtils {
  
  /// Shows an error snackbar with red background
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color.fromARGB(255, 236, 62, 62),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Shows a success snackbar with green background
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color.fromARGB(255, 76, 175, 80),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Shows an info snackbar with blue background
  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color.fromARGB(255, 33, 150, 243),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Shows a warning snackbar with orange background
  static void showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color.fromARGB(255, 255, 152, 0),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
import 'package:flutter/material.dart';

/// Shared floating SnackBar presenter, centralizing the SnackBar styling
/// that was previously duplicated at every call site.
class AppSnackBar {
  AppSnackBar._();

  static void success(BuildContext context, String message) =>
      _show(context, message, Colors.green.shade700);

  static void info(BuildContext context, String message) =>
      _show(context, message, Colors.blue.shade700);

  static void error(BuildContext context, String message) =>
      _show(context, message, Colors.red.shade700);

  static void warning(BuildContext context, String message) =>
      _show(context, message, Colors.orange.shade700);

  static void _show(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
      ),
    );
  }
}

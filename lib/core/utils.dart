import 'package:flutter/material.dart';

/// 🔹 Show a modern snackbar
void showSnackBar(BuildContext context, String message, {bool isError = false}) {
  final snackBar = SnackBar(
    content: Text(message),
    backgroundColor: isError ? Colors.red : Colors.green,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    duration: const Duration(seconds: 2),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

/// 🔹 Format confidence as percentage
String formatConfidence(double confidence) {
  return "${(confidence * 100).toStringAsFixed(1)}%";
}

/// 🔹 Email Validator
String? validateEmail(String? value) {
  if (value == null || value.isEmpty) return "Email is required";
  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  if (!emailRegex.hasMatch(value)) return "Enter a valid email";
  return null;
}

/// 🔹 Password Validator
String? validatePassword(String? value) {
  if (value == null || value.isEmpty) return "Password is required";
  if (value.length < 6) return "Password must be at least 6 characters";
  return null;
}

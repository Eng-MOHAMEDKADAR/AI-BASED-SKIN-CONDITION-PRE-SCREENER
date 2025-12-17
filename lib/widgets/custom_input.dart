import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool isPassword;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;

  const CustomInput({
    super.key,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.validator,
    this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: validator,
      onSaved: onSaved,
    );
  }
}

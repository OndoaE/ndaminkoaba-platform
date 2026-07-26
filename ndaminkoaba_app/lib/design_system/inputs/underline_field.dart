import 'package:flutter/material.dart';

import '../colors/app_colors.dart';

/// Minimalist underlined input used on the auth screens (Login/Signup) — a
/// gold icon + gold placeholder text sitting directly on a gold baseline,
/// no fill or outline box.
class UnderlineField extends StatelessWidget {
  const UnderlineField({
    super.key,
    required this.icon,
    required this.hint,
    required this.controller,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
  });

  final IconData icon;
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
      cursorColor: AppColors.secondary,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.secondary, size: 20),
        prefixIconConstraints: const BoxConstraints(minWidth: 34, minHeight: 20),
        suffixIcon: suffixIcon,
        hintText: hint,
        hintStyle: const TextStyle(
          color: AppColors.secondary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.secondary, width: 1.2),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.secondary, width: 1.2),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.secondary, width: 1.8),
        ),
      ),
    );
  }
}

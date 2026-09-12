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
    this.outlined = true,
  });

  final bool outlined;
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
        prefixIconConstraints: BoxConstraints(
          minWidth: outlined ? 52 : 34,
          minHeight: 24,
        ),
        suffixIcon: suffixIcon,
        hintText: hint,
        hintStyle: TextStyle(
          color: outlined ? AppColors.textSecondary : AppColors.secondary,
          fontSize: 16,
          fontWeight: outlined ? FontWeight.w400 : FontWeight.w600,
        ),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          vertical: outlined ? 19 : 12,
          horizontal: outlined ? 16 : 0,
        ),
        border: outlined
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: AppColors.secondary),
              )
            : const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.secondary, width: 1.2),
              ),
        enabledBorder: outlined
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: AppColors.secondary),
              )
            : const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.secondary, width: 1.2),
              ),
        focusedBorder: outlined
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: AppColors.secondary),
              )
            : const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.secondary, width: 1.8),
              ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AuthField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final bool isPassword;
  final String? Function(String?)? validator;

  const AuthField({
    super.key,
    required this.hintText,
    required this.controller,
    this.isPassword = false,
    this.validator,
  });

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller:  widget.controller,
      obscureText: widget.isPassword && _obscure,
      validator:   widget.validator,
      style: const TextStyle(
        color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText:  widget.hintText,
        hintStyle: const TextStyle(
          color: AppColors.textMuted, fontSize: 14),
        filled:     true,
        fillColor:  AppColors.bgCard,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.accentGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.error, width: 1.5),
        ),
        // Show/hide toggle for password fields
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textMuted, size: 20),
                onPressed: () =>
                    setState(() => _obscure = !_obscure),
              )
            : null,
      ),
    );
  }
}
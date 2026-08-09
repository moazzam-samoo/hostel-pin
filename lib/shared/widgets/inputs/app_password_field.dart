import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'app_text_field.dart';

class AppPasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final String? errorText;
  final bool enabled;

  const AppPasswordField({
    super.key,
    this.controller,
    required this.hintText,
    this.errorText,
    this.enabled = true,
  });

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscureText = true;

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: widget.controller,
      hintText: widget.hintText,
      obscureText: _obscureText,
      enabled: widget.enabled,
      errorText: widget.errorText,
      // No leading icon for password as per plan section 1.4
      trailing: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: AppColors.textSecondary,
          size: 20,
        ),
        onPressed: widget.enabled ? _toggleVisibility : null,
        splashRadius: 20,
      ),
    );
  }
}

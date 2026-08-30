import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_text_field.dart';
import 'field_label.dart';
import '../../../core/theme/app_spacing.dart';

/// A wrapper around [AppTextField] and [FieldLabel] that adds a standard
/// [FormField] for validation, matching the pattern established by EditProfileView
/// and AddListingView.
class ValidatedTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?) validator;
  final TextInputType? keyboardType;
  final IconData? leadingIcon;
  final bool enabled;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final VoidCallback? onTap;

  const ValidatedTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.hintText,
    required this.validator,
    this.keyboardType,
    this.leadingIcon,
    this.enabled = true,
    this.maxLines = 1,
    this.inputFormatters,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label),
        SizedBox(height: AppSpacing.xs),
        FormField<String>(
          validator: (_) => validator(controller.text),
          builder: (state) => AppTextField(
            controller: controller,
            hintText: hintText,
            keyboardType: keyboardType,
            leadingIcon: leadingIcon,
            enabled: enabled,
            maxLines: maxLines,
            inputFormatters: inputFormatters,
            readOnly: readOnly,
            onTap: onTap,
            errorText: state.errorText,
            onChanged: (val) {
              state.didChange(val);
              if (state.hasError) state.validate();
            },
          ),
        ),
      ],
    );
  }
}

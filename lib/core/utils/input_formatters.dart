import 'package:flutter/services.dart';

/// Formats a Pakistani CNIC as the user types: 13 digits as `#####-#######-#`
/// (e.g. `42101-1234567-1`). Strips anything non-digit first, so paste and
/// backspace both behave — the dashes are re-inserted from the raw digits,
/// never treated as literal characters the user typed.
class CnicInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final truncated = digits.length > 13 ? digits.substring(0, 13) : digits;

    final buffer = StringBuffer();
    for (var i = 0; i < truncated.length; i++) {
      if (i == 5 || i == 12) buffer.write('-');
      buffer.write(truncated[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

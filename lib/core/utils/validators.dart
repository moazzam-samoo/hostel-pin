import '../constants/app_strings.dart';

class Validators {
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.errorRequired;
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.errorEmailRequired;
    }
    final emailRegex = RegExp(r'^[\w\-.+]+@([\w\-]+\.)+[A-Za-z]{2,24}$');
    if (!emailRegex.hasMatch(value)) {
      return AppStrings.errorEmailInvalid;
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.errorPasswordRequired;
    }
    if (value.length < 8) {
      return AppStrings.errorPasswordLength;
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return AppStrings.errorPasswordUpper;
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return AppStrings.errorPasswordNumber;
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.errorConfirmPasswordRequired;
    }
    if (value != password) {
      return AppStrings.errorConfirmPasswordMatch;
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.errorPhoneRequired;
    }
    final clean = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final pakPhoneRegex = RegExp(r'^(?:\+92|92|0)?3[0-9]{9}$');
    if (!pakPhoneRegex.hasMatch(clean)) {
      return AppStrings.errorPhoneInvalid;
    }
    return null;
  }

  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.errorRequired;
    }
    final parsed = double.tryParse(value.trim());
    // Server rules require pricePerMonth > 0 — reject zero/negative/absurd
    // values here instead of after a full photo upload.
    if (parsed == null || !parsed.isFinite || parsed <= 0 || parsed > 10000000) {
      return AppStrings.errorPriceInvalid;
    }
    return null;
  }

  static String? rooms(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.errorRequired;
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed < 1 || parsed > 10000) {
      return AppStrings.errorRoomsInvalid;
    }
    return null;
  }

  static String? beds(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.errorRequired;
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed < 1 || parsed > 100000) {
      return AppStrings.errorBedsInvalid;
    }
    return null;
  }

  static String? cnic(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.errorRequired;
    }
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 13) {
      return AppStrings.errorCnicInvalid;
    }
    return null;
  }

  static String? dateOfBirth(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.errorDobRequired;
    }
    return null;
  }
}

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
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
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
    if (!value.startsWith('+92') || value.length != 13) {
      return AppStrings.errorPhoneInvalid;
    }
    return null;
  }

  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.errorRequired;
    }
    if (double.tryParse(value) == null) {
      return AppStrings.errorPriceInvalid;
    }
    return null;
  }

  static String? rooms(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.errorRequired;
    }
    if (int.tryParse(value) == null) {
      return AppStrings.errorRoomsInvalid;
    }
    return null;
  }
}

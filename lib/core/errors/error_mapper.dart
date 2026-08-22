import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_strings.dart';
import 'failure.dart';

class ErrorMapper {
  static Failure fromException(dynamic exception) {
    if (exception is FirebaseAuthException) {
      switch (exception.code) {
        case 'user-not-found':
          return const Failure(message: AppStrings.errorUserNotFound);
        case 'wrong-password':
          return const Failure(message: AppStrings.errorWrongPassword);
        case 'invalid-credential':
          return const Failure(message: AppStrings.errorInvalidCredential);
        case 'email-already-in-use':
          return const Failure(message: AppStrings.errorEmailInUse);
        case 'account-exists-with-different-credential':
          return const Failure(
              message: AppStrings.errorAccountExistsWithDifferentCredential);
        case 'weak-password':
          return const Failure(message: AppStrings.errorWeakPassword);
        case 'operation-not-allowed':
          return const Failure(message: AppStrings.errorOperationNotAllowed);
        case 'too-many-requests':
          return const Failure(message: AppStrings.errorTooManyRequests);
        case 'user-disabled':
          return const Failure(message: AppStrings.errorUserDisabled);
        case 'network-request-failed':
          return const Failure(message: AppStrings.errorNetwork);
        case 'invalid-email':
          return const Failure(message: AppStrings.errorEmailInvalid);
        case 'requires-recent-login':
          return const Failure(message: AppStrings.errorRequiresRecentLogin);
        default:
          return Failure(message: exception.message ?? AppStrings.errorGeneric, error: exception);
      }
    }

    return Failure(
      message: AppStrings.errorGeneric,
      error: exception,
    );
  }
}

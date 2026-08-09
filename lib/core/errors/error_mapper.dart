import 'failure.dart';

class ErrorMapper {
  static Failure fromException(dynamic exception) {
    // TODO: Map specific exceptions like FirebaseAuthException to Failure
    return Failure(
      message: 'An unexpected error occurred. Please try again.',
      error: exception,
    );
  }
}

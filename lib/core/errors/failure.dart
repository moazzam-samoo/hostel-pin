class Failure {
  final String message;
  final String? code;
  final dynamic error;

  const Failure({
    required this.message,
    this.code,
    this.error,
  });

  @override
  String toString() => 'Failure(message: $message, code: $code, error: $error)';
}

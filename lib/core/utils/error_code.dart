import 'package:cloud_firestore/cloud_firestore.dart';

/// Short, user-safe description of why a load failed, for support/debugging:
/// the Firebase error code (e.g. `permission-denied`, `failed-precondition`)
/// or the exception type for anything else.
String errorCode(Object error) {
  if (error is FirebaseException) return error.code;
  return error.runtimeType.toString();
}

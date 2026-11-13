import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import '../../core/enums/user_role.dart';
import '../../core/errors/error_mapper.dart';
import 'package:get/get.dart';

/// Result of a Google sign-in attempt, already reconciled against the
/// Block F returning-user role decision: a brand-new Google identity gets
/// `fallbackRole` (the value picked at Role Selection); a returning identity
/// with an existing `users/{uid}` doc keeps its **stored** role, silently
/// ignoring whatever was just picked at Role Selection this session.
class GoogleSignInResolution {
  final UserRole role;
  final bool isNewUser;
  const GoogleSignInResolution({required this.role, required this.isNewUser});
}

class AuthRepository {
  final AuthService _authService = Get.find<AuthService>();
  final UserRepository _userRepository = Get.find<UserRepository>();

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw ErrorMapper.fromException(e);
    }
  }

  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw ErrorMapper.fromException(e);
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      return await _authService.signInWithGoogle();
    } catch (e) {
      throw ErrorMapper.fromException(e);
    }
  }

  /// Google Sign-In, with the Block F returning-user role conflict resolved
  /// in one place (both LoginController and SignupController call this
  /// instead of each re-implementing the new-vs-returning branch):
  /// - New Google identity (no existing users/{uid} doc): the doc is created
  ///   with [fallbackRole] (the value just picked at Role Selection).
  /// - Returning Google identity (doc already exists): the **stored** role
  ///   wins — [fallbackRole] is ignored entirely for this call.
  /// Returns null if the user cancelled the Google picker.
  Future<GoogleSignInResolution?> signInWithGoogleAndResolveRole({
    required UserRole fallbackRole,
  }) async {
    try {
      final credential = await _authService.signInWithGoogle();
      if (credential == null || credential.user == null) return null;

      final firebaseUser = credential.user!;
      final existing = await _userRepository.getUserDoc(firebaseUser.uid);
      if (existing != null) {
        return GoogleSignInResolution(role: existing.role, isNewUser: false);
      }

      final newUserDoc = UserModel(
        uid: firebaseUser.uid,
        displayName: firebaseUser.displayName ?? 'Hostel User',
        email: firebaseUser.email ?? '',
        photoUrl: firebaseUser.photoURL,
        role: fallbackRole,
      );
      await _userRepository.createUserDoc(newUserDoc);
      return GoogleSignInResolution(role: fallbackRole, isNewUser: true);
    } catch (e) {
      throw ErrorMapper.fromException(e);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
    } catch (e) {
      throw ErrorMapper.fromException(e);
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
    } catch (e) {
      throw ErrorMapper.fromException(e);
    }
  }

  Future<void> reauthenticateWithCredential(String currentPassword) async {
    try {
      await _authService.reauthenticateWithCredential(currentPassword);
    } catch (e) {
      throw ErrorMapper.fromException(e);
    }
  }

  bool get usesPasswordProvider => _authService.usesPasswordProvider;

  /// Returns false when the user cancelled the Google account picker.
  Future<bool> reauthenticateWithGoogle() async {
    try {
      return await _authService.reauthenticateWithGoogle();
    } catch (e) {
      throw ErrorMapper.fromException(e);
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _authService.updatePassword(newPassword);
    } catch (e) {
      throw ErrorMapper.fromException(e);
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _authService.deleteAccount();
    } catch (e) {
      throw ErrorMapper.fromException(e);
    }
  }

  /// The signed-in user's email, sourced from FirebaseAuth via AuthService —
  /// the layered replacement for a controller reaching for
  /// `FirebaseAuth.instance` directly (MVVM boundary table, AGENTS.md §7).
  String? get currentUserEmail => _authService.currentUser?.email;

  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      throw ErrorMapper.fromException(e);
    }
  }
}

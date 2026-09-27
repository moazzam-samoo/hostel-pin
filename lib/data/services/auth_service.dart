import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Lazy, and never touched on web: this app's web build only ever serves
  // the admin panel (email/password sign-in only, no Google button
  // anywhere in features/admin/), and google_sign_in_web's plugin fails an
  // internal assertion at construction time without a configured web OAuth
  // client ID — never set up in this project since it isn't needed there.
  // Building this eagerly as a field initializer crashed app boot on every
  // web load, before InitialBinding even finished. Both call sites below
  // guard on kIsWeb so the getter is simply never reached on web.
  GoogleSignIn? _googleSignInInstance;
  GoogleSignIn get _googleSignIn => _googleSignInInstance ??= GoogleSignIn();

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential?> signInWithGoogle() async {
    if (kIsWeb) {
      throw UnsupportedError(
        'Google Sign-In is not available on web in this app.',
      );
    }
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // user canceled

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return _auth.signInWithCredential(credential);
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> sendEmailVerification() {
    if (currentUser == null) throw Exception('No user signed in');
    return currentUser!.sendEmailVerification();
  }

  /// Re-authenticates the current email/password user with their current
  /// password. Required by Firebase before a sensitive operation (e.g.
  /// `updatePassword`) if the session is no longer "recent" — surfaces as a
  /// `requires-recent-login` FirebaseAuthException otherwise (see D.4).
  Future<void> reauthenticateWithCredential(String currentPassword) {
    final user = currentUser;
    if (user == null || user.email == null) {
      throw Exception('No signed-in email/password user to reauthenticate');
    }
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    return user.reauthenticateWithCredential(credential);
  }

  Future<void> updatePassword(String newPassword) {
    if (currentUser == null) throw Exception('No user signed in');
    return currentUser!.updatePassword(newPassword);
  }

  Future<void> deleteAccount() {
    if (currentUser == null) throw Exception('No user signed in');
    return currentUser!.delete();
  }

  Future<void> signOut() async {
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
    await _auth.signOut();
  }
}

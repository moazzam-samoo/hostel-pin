import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'auth_service.dart';
import '../repositories/user_repository.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../shared/widgets/feedback/app_snackbar.dart';

class SessionService extends GetxService {
  final Rxn<UserModel> currentUser = Rxn<UserModel>();

  StreamSubscription<User?>? _authSub;
  StreamSubscription<UserModel?>? _userSub;

  @override
  void onInit() {
    super.onInit();
    wireAuthState();
  }

  @override
  void onClose() {
    _userSub?.cancel();
    _authSub?.cancel();
    super.onClose();
  }

  // A separate, overridable method rather than inline in onInit(): a
  // test-only subclass can override just this to skip real Firebase
  // entirely (AuthService/UserRepository both touch real Firebase
  // singletons at construction time, which throws in a plain widget test
  // with no Firebase.initializeApp()), while still going through the
  // normal, @mustCallSuper-compliant onInit() lifecycle. See
  // test/responsive/screen_size_test.dart's _FakeSessionService.
  @visibleForTesting
  void wireAuthState() {
    final authService = Get.find<AuthService>();
    final userRepository = Get.find<UserRepository>();
    _authSub = authService.authStateChanges.listen((User? firebaseUser) {
      // Always drop the previous account's Firestore listener first. Without
      // this, every auth change stacked another live listener: after logout
      // the old one hit permission-denied, and after switching accounts a
      // stale stream could overwrite `currentUser` with the previous user.
      _userSub?.cancel();
      _userSub = null;

      if (firebaseUser == null) {
        currentUser.value = null;
        return;
      }

      _userSub = userRepository.userStream(firebaseUser.uid).listen(
        (UserModel? userDoc) {
          if (userDoc != null && userDoc.status == 'blocked') {
            _handleBlockedUser(authService);
            return;
          }
          currentUser.value = userDoc;
        },
        onError: (Object _) {
          // Typically permission-denied while signing out, or offline with no
          // cached document. Never leave a stale identity behind.
          currentUser.value = null;
        },
      );
    });
  }

  /// An admin blocked this account (users/{uid}.status == 'blocked'): end the
  /// session immediately and send the user back to Login with a clear reason.
  Future<void> _handleBlockedUser(AuthService authService) async {
    currentUser.value = null;
    try {
      await authService.signOut();
    } catch (_) {
      // Signing out failing must not leave the blocked user inside the app.
    }
    Get.offAllNamed(Routes.login);
    AppSnackbar.showGlobal(
      message: AppStrings.errorAccountBlocked,
      type: SnackbarType.error,
    );
  }
}

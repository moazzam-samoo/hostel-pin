import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'auth_service.dart';
import '../repositories/user_repository.dart';

class SessionService extends GetxService {
  final Rxn<UserModel> currentUser = Rxn<UserModel>();

  @override
  void onInit() {
    super.onInit();
    wireAuthState();
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
    authService.authStateChanges.listen((User? firebaseUser) {
      if (firebaseUser == null) {
        currentUser.value = null;
      } else {
        userRepository.userStream(firebaseUser.uid).listen((UserModel? userDoc) {
          currentUser.value = userDoc;
        });
      }
    });
  }
}

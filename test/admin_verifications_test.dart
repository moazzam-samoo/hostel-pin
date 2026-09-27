import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:hostel_finder_app/data/repositories/verification_repository.dart';
import 'package:hostel_finder_app/data/repositories/hostel_repository.dart';
import 'package:hostel_finder_app/data/services/auth_service.dart';
import 'package:hostel_finder_app/features/admin/verifications/admin_verifications_controller.dart';
import 'package:hostel_finder_app/features/admin/verifications/admin_verifications_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FakeAuthService extends GetxService implements AuthService {
  @override
  User? get currentUser => null;
  @override
  Stream<User?> get authStateChanges => const Stream.empty();
  // ignore: annotate_overrides
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('AdminVerificationsView smoke test', (tester) async {
    final fakeFirestore = FakeFirebaseFirestore();
    
    // Add a fake document so the list isn't empty!
    await fakeFirestore.collection('verifications').doc('123').set({
      'uid': '123',
      'status': 'pending',
      'personalInfo': {'fullName': 'John Doe'},
      'submittedAt': Timestamp.now(),
    });

    Get.put(VerificationRepository(firestore: fakeFirestore));
    Get.put(HostelRepository(firestore: fakeFirestore));
    Get.put<AuthService>(FakeAuthService());
    
    Get.put(AdminVerificationsController());

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1440, 900),
        builder: (context, _) => const GetMaterialApp(
          home: Scaffold(
            body: AdminVerificationsView(),
          ),
        ),
      ),
    );
    
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

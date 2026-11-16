import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:hostel_finder_app/data/repositories/verification_repository.dart';
import 'package:hostel_finder_app/data/repositories/activity_repository.dart';
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
  tearDown(() => Get.reset());
  adminMultiHostelTests();
  adminApproveTests();

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

void _setUpRepos(FakeFirebaseFirestore db) {
  Get.reset();
  Get.put(VerificationRepository(firestore: db));
  Get.put(HostelRepository(firestore: db));
  Get.put<AuthService>(FakeAuthService());
}

void adminMultiHostelTests() {
  test('review shows ALL of the owner\'s hostels in review, not only the linked one',
      () async {
    final db = FakeFirebaseFirestore();
    _setUpRepos(db);
    await db.collection('verifications').doc('o1').set({
      'uid': 'o1',
      'status': 'pending',
      'hostelId': 'h1',
      'personalInfo': {'fullName': 'Ali'},
      'submittedAt': Timestamp.now(),
    });
    for (final e in {'h1': 'pending', 'h2': 'pending', 'h3': 'pending', 'h4': 'draft'}.entries) {
      await db.collection('hostels').doc(e.key).set({
        'ownerId': 'o1', 'name': 'Hostel ${e.key}', 'status': e.value,
        'city': 'C', 'pricePerMonth': 10,
      });
    }
    await db.collection('hostels').doc('other').set({
      'ownerId': 'o2', 'name': 'Other', 'status': 'pending', 'city': 'C', 'pricePerMonth': 10,
    });

    final c = Get.put(AdminVerificationsController());
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await c.selectSubmission(c.all.first);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(c.ownerHostels.map((h) => h.id).toSet(), {'h1', 'h2', 'h3'});

    await c.approveHostel(c.ownerHostels.firstWhere((h) => h.id == 'h2'));
    await c.rejectHostel(c.ownerHostels.firstWhere((h) => h.id == 'h3'), 'Bad photos');
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect((await db.collection('hostels').doc('h2').get())['status'], 'published');
    final h3 = (await db.collection('hostels').doc('h3').get()).data()!;
    expect(h3['status'], 'rejected');
    expect(h3['rejectionReason'], 'Bad photos');
    expect((await db.collection('hostels').doc('h1').get())['status'], 'pending');
  });
}

void adminApproveTests() {
  Future<FakeFirebaseFirestore> seed({required String? hostelStatus}) async {
    final db = FakeFirebaseFirestore();
    _setUpRepos(db);
    await db.collection('users').doc('o1').set({'role': 'owner', 'verificationStatus': 'unverified'});
    await db.collection('verifications').doc('o1').set({
      'uid': 'o1',
      'status': 'pending',
      'hostelId': 'h1',
      'personalInfo': {'fullName': 'Ali'},
      'submittedAt': Timestamp.now(),
    });
    if (hostelStatus != null) {
      await db.collection('hostels').doc('h1').set({
        'ownerId': 'o1', 'name': 'H', 'status': hostelStatus, 'city': 'C', 'pricePerMonth': 10,
      });
    }
    return db;
  }

  Future<void> approve(FakeFirebaseFirestore db) {
    return VerificationRepository(firestore: db).approveSubmission(
      verificationId: 'o1',
      userId: 'o1',
      adminId: 'admin',
      hostelId: 'h1',
    );
  }

  test('approving works even when the linked hostel no longer exists', () async {
    final db = await seed(hostelStatus: null);
    await approve(db);
    expect((await db.collection('users').doc('o1').get())['verificationStatus'], 'verified');
    expect((await db.collection('verifications').doc('o1').get())['status'], 'approved');
  });

  test('approving publishes a pending linked hostel', () async {
    final db = await seed(hostelStatus: 'pending');
    await approve(db);
    expect((await db.collection('hostels').doc('h1').get())['status'], 'published');
  });

  test('approving the identity does not re-publish a hostel the admin rejected', () async {
    final db = await seed(hostelStatus: 'rejected');
    await approve(db);
    expect((await db.collection('hostels').doc('h1').get())['status'], 'rejected');
    expect((await db.collection('users').doc('o1').get())['verificationStatus'], 'verified');
  });

  test('approving the identity tells the owner they are verified', () async {
    final db = await seed(hostelStatus: 'pending');
    await VerificationRepository(firestore: db).approveSubmission(
      verificationId: 'o1', userId: 'o1', adminId: 'admin', hostelId: 'h1');
    // The controller is what notifies; drive it the way the panel does.
    Get.put(ActivityRepository(firestore: db));
    final c = Get.put(AdminVerificationsController());
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await c.notifyIdentityApproved('o1', hostelName: 'H', hostelPublished: true);
    final feed = (await db.collection('activities').where('ownerId', isEqualTo: 'o1').get()).docs;
    expect(feed.map((d) => d['type']).toSet(), {'account_verified', 'hostel_approved'});
  });
}

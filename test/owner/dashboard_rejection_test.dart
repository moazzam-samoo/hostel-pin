import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hostel_finder_app/core/constants/app_strings.dart';
import 'package:hostel_finder_app/core/enums/user_role.dart';
import 'package:hostel_finder_app/core/theme/app_theme.dart';
import 'package:hostel_finder_app/data/models/hostel_model.dart';
import 'package:hostel_finder_app/data/models/user_model.dart';
import 'package:hostel_finder_app/data/repositories/activity_repository.dart';
import 'package:hostel_finder_app/data/repositories/hostel_repository.dart';
import 'package:hostel_finder_app/data/services/session_service.dart';
import 'package:hostel_finder_app/features/owner/dashboard/dashboard_controller.dart';
import 'package:hostel_finder_app/features/owner/dashboard/dashboard_view.dart';

class _FakeSessionService extends SessionService {
  @override
  void wireAuthState() {}
}

late FakeFirebaseFirestore db;
Object? openedArguments;

Future<void> _hostel(String id, String name, String status, {String? reason}) {
  return db.collection('hostels').doc(id).set({
    'ownerId': 'o1',
    'name': name,
    'status': status,
    'city': 'Hyderabad',
    'pricePerMonth': 1000,
    if (reason != null) 'rejectionReason': reason,
  });
}

Future<void> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(375, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  Get.put(DashboardController());
  await tester.pumpWidget(ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (context, _) => GetMaterialApp(
      theme: AppTheme.light,
      home: const DashboardView(),
      getPages: [
        GetPage(
          name: '/owner/edit',
          page: () {
            openedArguments = Get.arguments;
            return const Scaffold(body: Text('EDIT SCREEN'));
          },
        ),
      ],
    ),
  ));
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUp(() {
    Get.reset();
    openedArguments = null;
    db = FakeFirebaseFirestore();
    Get.put(HostelRepository(firestore: db));
    Get.put(ActivityRepository(firestore: db));
    final s = _FakeSessionService();
    Get.put<SessionService>(s);
    s.currentUser.value = const UserModel(
        uid: 'o1', displayName: 'Ali', email: 'a@x.com', role: UserRole.owner);
  });

  testWidgets('a rejected hostel shows its name and the admin reason',
      (tester) async {
    await _hostel('1', 'Sunrise Hostel', 'rejected', reason: 'Photos are blurry');
    await _pump(tester);
    expect(find.text(AppStrings.rejectedHostelTitle('Sunrise Hostel')), findsOneWidget);
    expect(find.text('Photos are blurry'), findsOneWidget);
  });

  testWidgets('a rejection without a reason shows the fallback text',
      (tester) async {
    await _hostel('1', 'Old Hostel', 'rejected');
    await _pump(tester);
    expect(find.text(AppStrings.rejectedHostelFallbackReason), findsOneWidget);
  });

  testWidgets('two rejected hostels show two alerts', (tester) async {
    await _hostel('1', 'One', 'rejected', reason: 'r1');
    await _hostel('2', 'Two', 'rejected', reason: 'r2');
    await _pump(tester);
    expect(find.text(AppStrings.rejectedHostelTitle('One')), findsOneWidget);
    expect(find.text(AppStrings.rejectedHostelTitle('Two')), findsOneWidget);
    expect(find.text(AppStrings.rejectedHostelFixButton), findsNWidgets(2));
  });

  testWidgets('pending, published and draft hostels never show a rejection',
      (tester) async {
    await _hostel('1', 'P', 'pending');
    await _hostel('2', 'Q', 'published');
    await _hostel('3', 'R', 'draft');
    await _pump(tester);
    expect(find.text(AppStrings.rejectedHostelFixButton), findsNothing);
    expect(find.text(AppStrings.rejectedHostelFallbackReason), findsNothing);
  });

  testWidgets('Fix and resubmit opens that hostel in the edit form',
      (tester) async {
    await _hostel('1', 'Sunrise Hostel', 'rejected', reason: 'Photos are blurry');
    await _pump(tester);
    await tester.tap(find.text(AppStrings.rejectedHostelFixButton));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('EDIT SCREEN'), findsOneWidget);
    expect(openedArguments, isA<HostelModel>());
    expect((openedArguments as HostelModel).id, '1');
  });
}

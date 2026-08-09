import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hostel_finder_app/app.dart';

void main() {
  testWidgets('HostelFinderApp builds and reaches the splash route without throwing', (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => const HostelFinderApp(),
      ),
    );
    await tester.pump();

    expect(find.byType(HostelFinderApp), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

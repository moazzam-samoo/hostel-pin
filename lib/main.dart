import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Offline persistence (FIX-7.6). Every list screen is a live `snapshots()`
  // stream; without this the app renders empty state the moment connectivity
  // drops. With it, the last-synced documents are served from disk and writes
  // are queued until the device is back online. Must be set BEFORE any other
  // Firestore call — the SDK locks its settings on first use.
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(
    LayoutBuilder(
      builder: (context, constraints) {
        final Size designSize;
        if (kIsWeb) {
          final width = constraints.maxWidth;
          if (width < 600) {
            designSize = const Size(375, 812);
          } else if (width < 1024) {
            designSize = const Size(768, 1024);
          } else {
            designSize = const Size(1440, 900);
          }
        } else {
          designSize = const Size(375, 812);
        }

        return ScreenUtilInit(
          designSize: designSize,
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) => const HostelFinderApp(),
        );
      },
    ),
  );
}

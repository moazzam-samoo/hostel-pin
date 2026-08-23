package com.hostelfinder.hostel_finder_app;

import io.flutter.embedding.android.FlutterActivity;

/**
 * Flutter's host Activity.
 *
 * Deliberately Java, not Kotlin. This project builds with AGP 9 where
 * `android.builtInKotlin=false` (Flutter's own template default) and the
 * Kotlin Gradle Plugin is intentionally not applied to the app module
 * (Flutter warns that doing so "will cause build failures in future
 * versions of Flutter"). In that configuration nothing compiled
 * src/main/kotlin into the APK: MainActivity.kt produced a .class file but
 * was never merged into any classes*.dex, so the app installed and then
 * died instantly with
 *   ClassNotFoundException: com.hostelfinder.hostel_finder_app.MainActivity
 * while Java sources in src/main/java (e.g. GeneratedPluginRegistrant)
 * dexed normally.
 *
 * This class is pure boilerplate with no Kotlin-specific behaviour, and
 * Flutter fully supports a Java host (see the SDK's own android-java
 * template), so keeping it in Java sidesteps the toolchain gap entirely.
 * All Dart code and all plugin Kotlin/Java code are unaffected.
 */
public class MainActivity extends FlutterActivity {
}

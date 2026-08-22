// Applies to every test under test/ (and subdirectories), per flutter_test's
// own convention for this file. Loads the app's real bundled fonts
// (Poppins/Inter) before any test runs — without this, golden captures use
// flutter_test's default "Ahem" placeholder font, which renders every
// character as a solid block and makes golden diffs meaningless. See
// TASK-Phase-5.md §5.C: goldens are pinned to a single platform
// (TargetPlatform.android, set explicitly by each golden test's own
// MaterialApp wrapper) so font-rendering differences across the dev
// machine's OS don't produce false golden diffs.
import 'dart:async';

import 'package:golden_toolkit/golden_toolkit.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  return GoldenToolkit.runWithConfiguration(
    () async {
      await loadAppFonts();
      await testMain();
    },
    config: GoldenToolkitConfiguration(
      // Real device pixel ratios only inflate golden PNG sizes for no
      // benefit in this repo's CI-less, single-machine setup — keep the
      // toolkit's default (opaque, deterministic) shadow rendering too.
      defaultDevices: const [Device.phone],
    ),
  );
}

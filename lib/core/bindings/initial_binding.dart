import 'package:get/get.dart';

import '../../data/services/auth_service.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/hostel_repository.dart';
import '../../data/repositories/saved_repository.dart';
import '../../data/repositories/activity_repository.dart';
import '../../data/repositories/verification_repository.dart';
import '../../data/services/session_service.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/location_service.dart';
import '../../data/services/cloudinary_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // MockDataService removed in Phase 7

    Get.put(AuthService(), permanent: true);
    Get.put(UserRepository(), permanent: true);
    Get.put(AuthRepository(), permanent: true);
    Get.put(SessionService(), permanent: true);

    // Phase 7: every student/owner controller (Home, Map, Saved, Search,
    // Profile, Dashboard, Listings, AddListing, HostelDetail,
    // OwnerProfile) calls Get.find<...>() on these directly in a field
    // initializer, which runs eagerly the moment GetX builds the
    // controller — they must be registered here as app-wide singletons
    // (the same permanent-in-InitialBinding pattern already used for
    // AuthRepository/UserRepository/SessionService above), not lazily
    // per-feature, or the very first real screen crashes with
    // "X not found. You need to call Get.put(X())".
    Get.put(HostelRepository(), permanent: true);
    Get.put(SavedRepository(), permanent: true);
    Get.put(ActivityRepository(), permanent: true);
    // Registered as its own singleton (not just the private instance
    // StorageService constructs for itself) because Phase 8's
    // VerificationController calls Get.find<CloudinaryService>() directly
    // for the signed-upload path (uploadSignedDocument) — StorageService's
    // unsigned-preset pipeline doesn't cover that. Without this line the
    // wizard's document-upload step throws "CloudinaryService not found"
    // the first time an owner reaches it.
    Get.put(CloudinaryService(), permanent: true);
    Get.put(StorageService(), permanent: true);
    Get.put(LocationService(), permanent: true);
    Get.put(VerificationRepository(), permanent: true);
  }
}

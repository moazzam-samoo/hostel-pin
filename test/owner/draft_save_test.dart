import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hostel_finder_app/core/enums/user_role.dart';
import 'package:hostel_finder_app/data/models/user_model.dart';
import 'package:hostel_finder_app/data/repositories/activity_repository.dart';
import 'package:hostel_finder_app/data/repositories/hostel_repository.dart';
import 'package:hostel_finder_app/data/services/cloudinary_service.dart';
import 'package:hostel_finder_app/data/services/location_service.dart';
import 'package:hostel_finder_app/data/services/session_service.dart';
import 'package:hostel_finder_app/data/services/storage_service.dart';
import 'package:hostel_finder_app/features/owner/add_listing/add_listing_controller.dart';

class _FakeSession extends SessionService {
  @override
  void wireAuthState() {}
}

void main() {
  late FakeFirebaseFirestore db;
  late AddListingController c;

  setUp(() {
    Get.reset();
    db = FakeFirebaseFirestore();
    Get.put(HostelRepository(firestore: db));
    Get.put(ActivityRepository(firestore: db));
    Get.put(StorageService());
    Get.put(LocationService());
    Get.put(CloudinaryService());
    final s = _FakeSession();
    Get.put<SessionService>(s);
    s.currentUser.value = const UserModel(
        uid: 'o1', displayName: 'Ali', email: 'a@x.com', role: UserRole.owner);
    c = Get.put(AddListingController());
  });

  Future<int> hostelCount() async =>
      (await db.collection('hostels').get()).docs.length;

  test('Save as draft with only a name saves a draft', () async {
    c.nameController.text = 'My Hostel';
    c.saveAsDraft();
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final docs = (await db.collection('hostels').get()).docs;
    expect(docs.length, 1);
    expect(docs.first['status'], 'draft');
    expect(docs.first['name'], 'My Hostel');
    expect(docs.first['ownerId'], 'o1');
  });

  test('Save as draft without a name saves nothing', () async {
    c.nameController.text = '   ';
    c.saveAsDraft();
    await Future<void>.delayed(const Duration(milliseconds: 300));
    expect(await hostelCount(), 0);
  });
}

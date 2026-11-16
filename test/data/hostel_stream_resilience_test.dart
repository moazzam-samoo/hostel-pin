import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hostel_finder_app/data/repositories/hostel_repository.dart';

/// One malformed hostel document must never blank out every list: the owner's
/// listings, the admin Hostels tab and the student feed all read through
/// these streams.
void main() {
  late FakeFirebaseFirestore db;
  late HostelRepository repo;

  setUp(() async {
    db = FakeFirebaseFirestore();
    repo = HostelRepository(firestore: db);
    await db.collection('hostels').doc('1003').set({
      'ownerId': 'o1', 'name': 'Good Two', 'status': 'published',
      'city': 'C', 'pricePerMonth': 5000,
    });
    // Wrong types on purpose: a string where a number belongs.
    await db.collection('hostels').doc('1002').set({
      'ownerId': 'o1', 'name': 'Broken', 'status': 'published',
      'city': 'C', 'pricePerMonth': 'abc', 'latitude': 'x',
    });
    await db.collection('hostels').doc('1001').set({
      'ownerId': 'o1', 'name': 'Good One', 'status': 'published',
      'city': 'C', 'pricePerMonth': 4000,
    });
  });

  test('streamByOwner skips the broken document and returns the rest', () async {
    final list = await repo.streamByOwner('o1').first;
    expect(list.map((h) => h.name).toSet(), {'Good One', 'Good Two'});
  });

  test('streamAllAdmin skips the broken document', () async {
    final list = await repo.streamAllAdmin(limit: 10).first;
    expect(list.map((h) => h.name).toSet(), {'Good One', 'Good Two'});
  });

  test('streamAllPublished skips the broken document', () async {
    final list = await repo.streamAllPublished(limit: 10).first;
    expect(list.map((h) => h.name).toSet(), {'Good One', 'Good Two'});
  });
}

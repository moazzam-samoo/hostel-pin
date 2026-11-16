import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hostel_finder_app/core/enums/listing_status.dart';
import 'package:hostel_finder_app/data/repositories/activity_repository.dart';
import 'package:hostel_finder_app/data/repositories/hostel_repository.dart';
import 'package:hostel_finder_app/features/admin/hostels/admin_hostels_controller.dart';

late FakeFirebaseFirestore db;
late HostelRepository repo;

Future<Map<String, dynamic>> _doc(String id) async =>
    (await db.collection('hostels').doc(id).get()).data()!;

void main() {
  setUp(() async {
    Get.reset();
    db = FakeFirebaseFirestore();
    repo = HostelRepository(firestore: db);
    Get.put(repo);
    Get.put(ActivityRepository(firestore: db));
    await db.collection('hostels').doc('h1').set({
      'ownerId': 'o1',
      'name': 'Hostel One',
      'status': 'pending',
      'city': 'Hyderabad',
      'pricePerMonth': 1000,
    });
  });

  test('setStatus(published) changes only the status and clears a reason', () async {
    await db.collection('hostels').doc('h1').update({'rejectionReason': 'old'});
    await repo.setStatus('h1', ListingStatus.published);
    final d = await _doc('h1');
    expect(d['status'], 'published');
    expect(d.containsKey('rejectionReason'), isFalse);
    expect(d['name'], 'Hostel One');
    expect(d['city'], 'Hyderabad');
  });

  test('setStatus(rejected) stores the reason', () async {
    await repo.setStatus('h1', ListingStatus.rejected,
        rejectionReason: 'Photos are blurry');
    final d = await _doc('h1');
    expect(d['status'], 'rejected');
    expect(d['rejectionReason'], 'Photos are blurry');
    expect(d['name'], 'Hostel One');
  });

  test('setStatus(rejected) without a reason is refused', () async {
    expect(() => repo.setStatus('h1', ListingStatus.rejected),
        throwsArgumentError);
    expect(() => repo.setStatus('h1', ListingStatus.rejected, rejectionReason: '  '),
        throwsArgumentError);
    expect((await _doc('h1'))['status'], 'pending');
  });

  test('model round-trips rejectionReason', () async {
    await repo.setStatus('h1', ListingStatus.rejected, rejectionReason: 'No ownership proof');
    final h = (await repo.getById('h1'))!;
    expect(h.status, ListingStatus.rejected);
    expect(h.rejectionReason, 'No ownership proof');
    expect(h.toFirestore()['rejectionReason'], 'No ownership proof');
    expect(h.copyWith(rejectionReason: 'x').rejectionReason, 'x');
  });

  test('controller approve publishes and reject stores the reason', () async {
    final c = AdminHostelsController();
    final h = (await repo.getById('h1'))!;
    await c.approve(h);
    expect((await _doc('h1'))['status'], 'published');

    await db.collection('hostels').doc('h1').update({'status': 'pending'});
    final h2 = (await repo.getById('h1'))!;
    await c.reject(h2, 'Address does not exist');
    final d = await _doc('h1');
    expect(d['status'], 'rejected');
    expect(d['rejectionReason'], 'Address does not exist');
  });

  test('controller reject with an empty reason changes nothing', () async {
    final c = AdminHostelsController();
    final h = (await repo.getById('h1'))!;
    await c.reject(h, '   ');
    expect((await _doc('h1'))['status'], 'pending');
  });

  test('approving a hostel tells the owner (activity feed)', () async {
    final c = AdminHostelsController();
    await c.approve((await repo.getById('h1'))!);
    final feed = (await db.collection('activities').where('ownerId', isEqualTo: 'o1').get()).docs;
    expect(feed.length, 1);
    expect(feed.first['type'], 'hostel_approved');
    expect(feed.first['message'], contains('Hostel One'));
    expect(feed.first['hostelId'], 'h1');
  });

  test('rejecting a hostel tells the owner the reason', () async {
    final c = AdminHostelsController();
    await c.reject((await repo.getById('h1'))!, 'Photos are blurry');
    final feed = (await db.collection('activities').where('ownerId', isEqualTo: 'o1').get()).docs;
    expect(feed.length, 1);
    expect(feed.first['type'], 'hostel_rejected');
    expect(feed.first['message'], contains('Photos are blurry'));
  });

  test('a failed status change tells the owner nothing', () async {
    final c = AdminHostelsController();
    await c.reject((await repo.getById('h1'))!, '   ');
    expect((await db.collection('activities').get()).docs, isEmpty);
  });
}

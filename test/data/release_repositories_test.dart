import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hostel_finder_app/core/constants/legal_content.dart';
import 'package:hostel_finder_app/data/models/report_model.dart';
import 'package:hostel_finder_app/data/repositories/account_repository.dart';
import 'package:hostel_finder_app/data/repositories/hostel_repository.dart';
import 'package:hostel_finder_app/data/repositories/report_repository.dart';

void main() {
  group('HostelRepository.streamAllPublished', () {
    test('returns the NEWEST listings first, not the oldest page', () async {
      final db = FakeFirebaseFirestore();
      // 15 published listings with epoch-style ascending ids, plus a draft.
      for (var i = 1; i <= 15; i++) {
        await db.collection('hostels').doc('${1000 + i}').set({
          'status': 'published',
          'name': 'Hostel $i',
        });
      }
      await db.collection('hostels').doc('9999').set({
        'status': 'draft',
        'name': 'Draft',
      });

      final repo = HostelRepository(firestore: db);
      final firstPage = await repo.streamAllPublished(limit: 10).first;

      expect(firstPage.length, 10);
      // Newest (highest id) first; the 5 oldest are NOT in the first page.
      expect(firstPage.first.id, '1015');
      expect(firstPage.last.id, '1006');
      expect(firstPage.any((h) => h.name == 'Draft'), isFalse);
    });
  });

  group('AccountRepository.deleteUserData', () {
    test('owner: removes saved, hostels, activities, verification and profile',
        () async {
      final db = FakeFirebaseFirestore();
      await db.collection('users').doc('o1').set({'role': 'owner'});
      await db.collection('users').doc('o1').collection('saved').doc('h9').set({'x': 1});
      await db.collection('hostels').doc('h1').set({'ownerId': 'o1'});
      await db.collection('hostels').doc('h2').set({'ownerId': 'o1'});
      await db.collection('hostels').doc('other').set({'ownerId': 'o2'});
      await db.collection('activities').doc('a1').set({'ownerId': 'o1'});
      await db.collection('verifications').doc('o1').set({'status': 'pending'});

      await AccountRepository(firestore: db).deleteUserData('o1', isOwner: true);

      expect((await db.collection('users').doc('o1').get()).exists, isFalse);
      expect((await db.collection('users').doc('o1').collection('saved').get()).docs, isEmpty);
      expect((await db.collection('hostels').doc('h1').get()).exists, isFalse);
      expect((await db.collection('hostels').doc('h2').get()).exists, isFalse);
      expect((await db.collection('activities').doc('a1').get()).exists, isFalse);
      expect((await db.collection('verifications').doc('o1').get()).exists, isFalse);
      // Someone else's data is untouched.
      expect((await db.collection('hostels').doc('other').get()).exists, isTrue);
    });

    test('student: removes saved + profile and leaves other collections alone',
        () async {
      final db = FakeFirebaseFirestore();
      await db.collection('users').doc('s1').set({'role': 'student'});
      await db.collection('users').doc('s1').collection('saved').doc('h1').set({'x': 1});
      await db.collection('hostels').doc('h1').set({'ownerId': 'o1'});

      await AccountRepository(firestore: db).deleteUserData('s1', isOwner: false);

      expect((await db.collection('users').doc('s1').get()).exists, isFalse);
      expect((await db.collection('users').doc('s1').collection('saved').get()).docs, isEmpty);
      expect((await db.collection('hostels').doc('h1').get()).exists, isTrue);
    });

    test('handles more than one batch of saved hostels', () async {
      final db = FakeFirebaseFirestore();
      await db.collection('users').doc('s1').set({'role': 'student'});
      for (var i = 0; i < 450; i++) {
        await db.collection('users').doc('s1').collection('saved').doc('h$i').set({'i': i});
      }
      await AccountRepository(firestore: db).deleteUserData('s1', isOwner: false);
      expect((await db.collection('users').doc('s1').collection('saved').get()).docs, isEmpty);
    });
  });

  group('ReportRepository.createReport', () {
    test('writes one report per (hostel, reporter) with status open', () async {
      final db = FakeFirebaseFirestore();
      final repo = ReportRepository(firestore: db);
      await repo.createReport(ReportModel(
        id: 'h1_u1',
        hostelId: 'h1',
        reportedBy: 'u1',
        reason: 'Scam or fraud',
        details: '',
        status: 'open',
        createdAt: DateTime(2026, 11, 13),
      ));

      final doc = await db.collection('reports').doc('h1_u1').get();
      expect(doc.exists, isTrue);
      expect(doc.data()!['reportedBy'], 'u1');
      expect(doc.data()!['status'], 'open');
      expect(doc.data()!['createdAt'], isA<Timestamp>());
    });
  });

  group('LegalContent', () {
    test('documents are non-empty and have no unfilled placeholders', () {
      for (final doc in [LegalContent.privacyPolicy, LegalContent.termsOfService]) {
        expect(doc, isNotEmpty);
        for (final section in doc) {
          expect(section.title, isNotEmpty);
          expect(section.paragraphs, isNotEmpty);
          for (final p in section.paragraphs) {
            expect(p.contains('{'), isFalse, reason: 'unfilled placeholder in: $p');
          }
        }
      }
    });

    test('privacy policy covers the data Play requires us to disclose', () {
      final text = LegalContent.privacyPolicy
          .expand((s) => [s.title, ...s.paragraphs])
          .join(' ')
          .toLowerCase();
      for (final term in ['location', 'cnic', 'selfie', 'delete', 'cloudinary', 'firebase', 'children']) {
        expect(text.contains(term), isTrue, reason: 'policy should mention "$term"');
      }
    });
  });
}

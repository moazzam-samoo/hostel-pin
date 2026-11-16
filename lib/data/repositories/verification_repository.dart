import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/verification_model.dart';
import '../../core/utils/logger.dart';

class VerificationRepository {
  final FirebaseFirestore _firestore;

  VerificationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<VerificationModel> _getCollection() {
    return _firestore.collection('verifications').withConverter<VerificationModel>(
          fromFirestore: VerificationModel.fromFirestore,
          toFirestore: (model, _) => model.toFirestore(),
        );
  }

  Stream<VerificationModel?> streamVerification(String uid) {
    return _getCollection().doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return snapshot.data();
      }
      return null;
    });
  }

  Future<void> updateVerification(VerificationModel verification) async {
    try {
      await _getCollection().doc(verification.uid).set(
            verification,
            SetOptions(merge: true),
          );
    } catch (e) {
      Logger.e('Error updating verification: $e');
      rethrow;
    }
  }

  Future<void> deleteVerification(String uid) async {
    try {
      await _getCollection().doc(uid).delete();
    } catch (e) {
      Logger.e('Error deleting verification: $e');
      rethrow;
    }
  }

  // Admin Methods (Block G) — the Verification Queue's list view needs a
  // genuinely new method (Before-starting row 11): the owner-scoped methods
  // above only ever read a single uid's own doc.
  //
  // `pending` covers a fresh submission; `changesRequested` submissions
  // re-enter the same queue on resubmission (still shown here so an admin
  // can see what's awaiting the owner's fix, per Block G.1's "Changes
  // Required" tab). `draft` (not yet submitted) and terminal states
  // (`approved`/`rejected`) are excluded — this is the *queue*, not a full
  // history.
  Stream<List<VerificationModel>> streamAllForAdmin() {
    return _getCollection()
        .where('status', whereIn: ['pending', 'changesRequested'])
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) => doc.data()).toList();
      list.sort((a, b) => (b.submittedAt ?? DateTime(2000)).compareTo(a.submittedAt ?? DateTime(2000)));
      return list;
    });
  }

  // Retained for anything that still wants pending-only (e.g. Dashboard-style
  // counts); streamAllForAdmin() above is the queue's real source now.
  Stream<List<VerificationModel>> streamPendingVerifications() {
    return _getCollection().where('status', isEqualTo: 'pending').snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) => doc.data()).toList();
      list.sort((a, b) => (a.submittedAt ?? DateTime.now()).compareTo(b.submittedAt ?? DateTime.now()));
      return list;
    });
  }

  Stream<List<VerificationModel>> streamHistory({int limit = 20}) {
    return _getCollection()
        .where('status', whereIn: ['approved', 'rejected'])
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) => doc.data()).toList();
      list.sort((a, b) => (b.reviewedAt ?? DateTime.now()).compareTo(a.reviewedAt ?? DateTime.now()));
      return list;
    });
  }

  /// Block G.5 — the single highest-blast-radius write in this phase.
  /// Flips 3 fields across 2 (or 3, if a hostel is attached) collections
  /// atomically via a WriteBatch: `verifications/{uid}.status -> approved`
  /// (+ reviewedAt/reviewedBy), `users/{uid}.verificationStatus -> verified`,
  /// and — when this submission is tied to a hostel — `hostels/{hostelId}
  /// .status -> published`. A `hostelId`-less submission (identity-only)
  /// only touches the first two; nothing here silently drops the hostel
  /// flip when one legitimately exists.
  ///
  /// Requires `firestore.rules`' isAdmin()-gated update rules on all three
  /// collections (added alongside this method) — without them this batch
  /// fails with permission-denied on every field, since the pre-existing
  /// owner-scoped rules never granted an admin session write access here.
  Future<void> approveSubmission({
    required String verificationId,
    required String userId,
    required String adminId,
    String? hostelId,
  }) async {
    // Only publish the linked hostel if it still exists AND is still waiting
    // for review. A batch update on a deleted hostel fails with not-found and
    // used to make the whole approval fail; a hostel the admin already
    // rejected must not be silently re-published by approving the identity.
    var publishHostel = false;
    if (hostelId != null && hostelId.isNotEmpty) {
      final hostelDoc =
          await _firestore.collection('hostels').doc(hostelId).get();
      publishHostel = hostelDoc.exists && hostelDoc.data()?['status'] == 'pending';
    }

    final batch = _firestore.batch();

    batch.update(_getCollection().doc(verificationId), {
      'status': 'approved',
      'reviewedBy': adminId,
      'reviewedAt': FieldValue.serverTimestamp(),
      'rejectionReason': null,
    });

    batch.update(_firestore.collection('users').doc(userId), {
      'verificationStatus': 'verified',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (publishHostel) {
      batch.update(_firestore.collection('hostels').doc(hostelId!), {
        'status': 'published',
      });
    }

    await batch.commit();
  }

  /// Block G.6 — Reject. `users/{uid}.verificationStatus` moves to the new
  /// `rejected` VerificationStatus value (not reused `unverified` — see the
  /// enum's own doc comment), distinguishing "rejected" from "never
  /// submitted." Does not touch any tied hostel's status.
  Future<void> rejectSubmission({
    required String verificationId,
    required String userId,
    required String adminId,
    required String reason,
  }) async {
    final batch = _firestore.batch();

    batch.update(_getCollection().doc(verificationId), {
      'status': 'rejected',
      'reviewedBy': adminId,
      'reviewedAt': FieldValue.serverTimestamp(),
      'rejectionReason': reason,
    });

    batch.update(_firestore.collection('users').doc(userId), {
      'verificationStatus': 'rejected',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  /// Block G.7 — Request Changes. Distinct from Reject: the submission
  /// stays recoverable (owner's wizard reopens at the flagged step showing
  /// `rejectionReason`, per VerificationController — see that controller's
  /// own status handling) rather than terminal. Does not touch
  /// `users/{uid}.verificationStatus` at all — an owner asked for changes
  /// is not "rejected," they're mid-review still.
  Future<void> requestChanges({
    required String verificationId,
    required String adminId,
    required String reason,
  }) async {
    await _getCollection().doc(verificationId).update({
      'status': 'changesRequested',
      'reviewedBy': adminId,
      'reviewedAt': FieldValue.serverTimestamp(),
      'rejectionReason': reason,
    });
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/errors/error_mapper.dart';
import '../../core/utils/logger.dart';

/// Removes everything the app stores about one user (Google Play's in-app
/// account-deletion requirement). Client-side by necessity — the project has
/// no deployed Cloud Functions (Spark plan) — so it only deletes what the
/// Firestore security rules let the user delete themselves.
///
/// Not covered (needs a server): photos and verification documents held at
/// Cloudinary. The Privacy Policy promises their removal within 30 days of
/// deletion, which is an operational task for the app owner.
class AccountRepository {
  final FirebaseFirestore _firestore;

  AccountRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Order matters: `verifications`/`hostels`/`activities` deletes are
  /// authorised via the owner's `users/{uid}` role (rules `isOwner()`), so the
  /// profile document is deleted LAST. Owner-only collections are skipped for
  /// students — the rules would (correctly) reject even an empty query there.
  ///
  /// Each step is named in the error log, so a `permission-denied` points at
  /// the exact collection whose rule rejected it (typically: the deployed
  /// Firestore rules are older than this app version).
  Future<void> deleteUserData(String uid, {required bool isOwner}) async {
    var step = 'start';
    try {
      step = 'saved hostels (users/$uid/saved)';
      await _deleteQuery(
          _firestore.collection('users').doc(uid).collection('saved'));
      if (isOwner) {
        step = 'owner listings (hostels where ownerId == uid)';
        await _deleteQuery(
            _firestore.collection('hostels').where('ownerId', isEqualTo: uid));
        step = 'owner activities (activities where ownerId == uid)';
        await _deleteQuery(_firestore
            .collection('activities')
            .where('ownerId', isEqualTo: uid));
        step = 'verification record (verifications/$uid)';
        await _firestore.collection('verifications').doc(uid).delete();
      }
      step = 'profile (users/$uid)';
      await _firestore.collection('users').doc(uid).delete();
    } catch (e) {
      Logger.e('Account data deletion failed at step "$step": $e');
      throw ErrorMapper.fromException(e);
    }
  }

  Future<void> _deleteQuery(Query<Map<String, dynamic>> query) async {
    final snapshot = await query.get();
    // Batches are capped at 500 operations.
    for (var i = 0; i < snapshot.docs.length; i += 400) {
      final batch = _firestore.batch();
      for (final doc in snapshot.docs.skip(i).take(400)) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }
}

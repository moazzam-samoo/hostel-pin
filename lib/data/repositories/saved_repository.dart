import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/saved_model.dart';
import '../models/hostel_model.dart';
import '../../core/utils/logger.dart';

class SavedRepository {
  final FirebaseFirestore _firestore;

  SavedRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<SavedModel> _savedRef(String uid) => _firestore
      .collection('users')
      .doc(uid)
      .collection('saved')
      .withConverter<SavedModel>(
        fromFirestore: SavedModel.fromFirestore,
        toFirestore: (model, options) => model.toFirestore(),
      );

  Stream<List<SavedModel>> streamSaved(String uid) {
    return _savedRef(uid)
        .orderBy('savedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Saves [hostel] for [uid], denormalizing a small summary
  /// (`name, ownerName, coverPhoto, price, rating, city`, per Appendix C)
  /// onto the saved doc at write time, so `streamSaved` never needs a
  /// second read against `hostels` to render the Saved tab.
  Future<void> save(String uid, HostelModel hostel) async {
    try {
      await _savedRef(uid).doc(hostel.id).set(
            SavedModel(
              id: hostel.id, // doc ID is same as hostel ID
              hostelId: hostel.id,
              savedAt: DateTime.now(),
              name: hostel.name,
              ownerName: hostel.ownerName,
              coverPhoto:
                  hostel.photos.isNotEmpty ? hostel.photos.first.url : '',
              price: hostel.pricePerMonth,
              rating: hostel.rating,
              city: hostel.city,
            ),
          );
    } catch (e) {
      Logger.e('Error saving hostel ${hostel.id}: $e');
      throw Exception('Failed to save hostel');
    }
  }

  Future<void> unsave(String uid, String hostelId) async {
    try {
      await _savedRef(uid).doc(hostelId).delete();
    } catch (e) {
      Logger.e('Error unsaving hostel $hostelId: $e');
      throw Exception('Failed to unsave hostel');
    }
  }

  /// Convenience wrapper over [save]/[unsave] for heart-toggle call sites
  /// that already know the current saved state. [hostel] is required only
  /// when saving (unsaving just needs the ID) — denormalizing the summary
  /// is the whole point of C.2, so there's no code path that saves without
  /// a real hostel to summarize.
  Future<void> toggleSave(
    String uid,
    String hostelId,
    bool currentlySaved, {
    HostelModel? hostel,
  }) {
    if (currentlySaved) return unsave(uid, hostelId);
    if (hostel == null) {
      // A real runtime check (an assert is stripped from release builds and
      // would surface as an uncatchable null-check error). Returned as a
      // failed Future so callers' catchError rolls the optimistic UI back.
      return Future<void>.error(
        Exception('Cannot save a hostel that has not loaded yet'),
      );
    }
    return save(uid, hostel);
  }
}

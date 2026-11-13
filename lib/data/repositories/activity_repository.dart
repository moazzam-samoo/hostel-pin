import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/activity_model.dart';
import '../../core/utils/logger.dart';

class ActivityRepository {
  final FirebaseFirestore _firestore;

  ActivityRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<ActivityModel> get _activitiesRef => _firestore
      .collection('activities')
      .withConverter<ActivityModel>(
        fromFirestore: ActivityModel.fromFirestore,
        toFirestore: (model, options) => model.toFirestore(),
      );

  Stream<List<ActivityModel>> streamByOwner(String ownerId) {
    return _activitiesRef
        .where('ownerId', isEqualTo: ownerId)
        // Newest 10 straight from the server (index: ownerId ASC, createdAt
        // DESC in firestore.indexes.json) instead of downloading the owner's
        // whole history just to keep ten rows.
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> create(ActivityModel activity) async {
    try {
      await _activitiesRef.doc(activity.id).set(activity);
    } catch (e) {
      Logger.e('Error creating activity: $e');
      throw Exception('Failed to create activity');
    }
  }
}

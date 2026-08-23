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
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs.map((doc) => doc.data()).toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list.take(10).toList();
        });
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

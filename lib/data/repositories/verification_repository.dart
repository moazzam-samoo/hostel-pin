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
}

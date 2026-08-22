import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../../core/errors/error_mapper.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _users => _firestore.collection('users');

  Future<void> createUserDoc(UserModel user) async {
    try {
      await _users.doc(user.uid).set({
        ...user.toFirestore(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ErrorMapper.fromException(e);
    }
  }

  Future<UserModel?> getUserDoc(String uid) async {
    try {
      final doc = await _users.doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw ErrorMapper.fromException(e);
    }
  }

  Future<void> updateUserDoc(UserModel user) async {
    try {
      await _users.doc(user.uid).update({
        ...user.toFirestore(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ErrorMapper.fromException(e);
    }
  }

  Stream<UserModel?> userStream(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
    });
  }
}

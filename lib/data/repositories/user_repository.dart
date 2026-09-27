import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../../core/errors/error_mapper.dart';
import '../../core/enums/user_role.dart';
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

  Stream<List<UserModel>> streamAllUsers({
    int limit = 10,
    UserRole? roleFilter,
    String? statusFilter,
  }) {
    Query query = _users;

    if (roleFilter != null) {
      query = query.where('role', isEqualTo: roleFilter.name);
    }

    if (statusFilter != null) {
      query = query.where('status', isEqualTo: statusFilter);
    }

    return query.limit(limit).snapshots().map((snapshot) {
      final list = snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      list.sort((a, b) => b.uid.compareTo(a.uid));
      return list;
    });
  }

  Future<int> countByRole(UserRole role) async {
    try {
      final aggregateQuery = await _users.where('role', isEqualTo: role.name).count().get();
      return aggregateQuery.count ?? 0;
    } catch (e) {
      throw ErrorMapper.fromException(e);
    }
  }

  Future<Map<int, int>> getUserGrowth(int year, UserRole role) async {
    try {
      final counts = <int, int>{};
      for (var month = 1; month <= 12; month++) {
        final start = DateTime(year, month, 1);
        final end = month < 12 ? DateTime(year, month + 1, 1) : DateTime(year + 1, 1, 1);
        final countQuery = await _users
            .where('role', isEqualTo: role.name)
            .where('createdAt', isGreaterThanOrEqualTo: start)
            .where('createdAt', isLessThan: end)
            .count()
            .get();
        counts[month] = countQuery.count ?? 0;
      }
      return counts;
    } catch (e) {
      throw ErrorMapper.fromException(e);
    }
  }

  Future<void> updateStatus(String uid, String status) async {
    try {
      await _users.doc(uid).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ErrorMapper.fromException(e);
    }
  }

  Future<void> deleteUserDoc(String uid) async {
    try {
      await _users.doc(uid).delete();
    } catch (e) {
      throw ErrorMapper.fromException(e);
    }
  }
}

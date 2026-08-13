import '../models/user_model.dart';
import '../../core/enums/user_role.dart';

const mockUser = UserModel(
  uid: 'student_123',
  displayName: 'Alex Johnson',
  email: 'alex.johnson@example.com',
  role: UserRole.student,
  photoUrl: null,
  savedHostelIds: ['hostel_1', 'hostel_4'],
);

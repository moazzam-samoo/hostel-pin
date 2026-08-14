import '../models/user_model.dart';
import '../../core/enums/user_role.dart';

const mockUser = UserModel(
  uid: 'student_123',
  displayName: 'Usaid Khan',
  email: 'usaidKhanChandio@gmail.com',
  role: UserRole.student,
  photoUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&q=80',
  savedHostelIds: ['hostel_1', 'hostel_4', 'hostel_6', 'hostel_7'],
);

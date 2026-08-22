import 'package:get/get.dart';
import '../../data/services/mock_data_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/session_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.putAsync(() => MockDataService().init(), permanent: true);
    
    Get.put(AuthService(), permanent: true);
    Get.put(UserRepository(), permanent: true);
    Get.put(AuthRepository(), permanent: true);
    Get.put(SessionService(), permanent: true);
  }
}

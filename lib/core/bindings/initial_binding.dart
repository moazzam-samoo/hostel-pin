import 'package:get/get.dart';
import '../../data/services/mock_data_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.putAsync(() => MockDataService().init(), permanent: true);
    // TODO: Inject global services here (e.g. AuthService, NetworkInfo)
  }
}

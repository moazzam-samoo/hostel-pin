import 'package:get/get.dart';

class AuthController extends GetxController {
  // Shared state across auth screens
  final selectedRole = Rx<String?>(null);

  // You can place global mock session methods here if needed, 
  // but form submission logic belongs in the screen controllers.
}

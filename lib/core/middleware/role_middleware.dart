import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class RoleMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // TODO(Phase 6): redirect to /role-selection when role == null
    return null;
  }
}

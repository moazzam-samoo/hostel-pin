import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // TODO(Phase 6): redirect to /login when signed out
    return null;
  }
}

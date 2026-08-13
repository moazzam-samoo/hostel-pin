import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../features/splash/splash_view.dart';
import '../../features/splash/splash_binding.dart';
import '../../features/welcome/welcome_view.dart';
import '../../features/welcome/welcome_binding.dart';
import '../../features/auth/view/login_view.dart';
import '../../features/auth/view/signup_view.dart';
import '../../features/auth/view/forgot_password_view.dart';
import '../../features/auth/view/check_email_view.dart';
import '../../features/auth/view/change_password_view.dart';
import '../../features/auth/view/password_success_view.dart';
import '../../features/auth/view/otp_view.dart';
import '../../features/auth/auth_binding.dart';
import '../../features/role_selection/view/role_selection_view.dart';
import '../../features/role_selection/role_selection_binding.dart';
import '../../features/student/shell/student_shell_view.dart';
import '../../features/student/shell/student_shell_binding.dart';
import '../../features/student/hostel_detail/hostel_detail_view.dart';
import '../../features/student/hostel_detail/hostel_detail_binding.dart';
import '../../features/student/search/search_view.dart';
import '../../features/student/search/search_binding.dart';
import '../../features/student/profile/edit_profile_view.dart';
import '../../features/student/profile/edit_profile_controller.dart';
import '../../features/student/profile/settings_view.dart';
import '../../features/student/profile/privacy_settings_view.dart';
import '../../shared/widget_gallery/widget_gallery_view.dart';
import 'app_routes.dart';
class AppPages {
  static final List<GetPage> pages = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.widgetGallery,
      page: () => const WidgetGalleryView(),
    ),
    GetPage(
      name: Routes.welcome,
      page: () => const WelcomeView(),
      binding: WelcomeBinding(),
    ),
    GetPage(
      name: Routes.roleSelection,
      page: () => const RoleSelectionView(),
      binding: RoleSelectionBinding(),
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.signup,
      page: () => const SignupView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.forgotPassword,
      page: () => const ForgotPasswordView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.checkEmail,
      page: () => const CheckEmailView(),
    ),
    GetPage(
      name: Routes.changePassword,
      page: () => const ChangePasswordView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.passwordSuccess,
      page: () => const PasswordSuccessView(),
    ),
    GetPage(
      name: Routes.otp,
      page: () => const OtpView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.studentShell,
      page: () => const StudentShellView(),
      binding: StudentShellBinding(),
    ),
    GetPage(
      name: Routes.studentHome,
      page: () => const Scaffold(body: Center(child: Text('Student Home'))),
    ),
    GetPage(
      name: Routes.studentSearch,
      page: () => const SearchView(),
      binding: SearchBinding(),
    ),
    GetPage(
      name: Routes.studentHostelDetail,
      page: () => const HostelDetailView(),
      binding: HostelDetailBinding(),
    ),
    GetPage(
      name: Routes.studentMap,
      page: () => const Scaffold(body: Center(child: Text('Student Map'))),
    ),
    GetPage(
      name: Routes.studentSaved,
      page: () => const Scaffold(body: Center(child: Text('Student Saved'))),
    ),
    GetPage(
      name: Routes.studentProfile,
      page: () => const Scaffold(body: Center(child: Text('Student Profile'))),
    ),
    GetPage(
      name: Routes.studentPhotos,
      page: () => const Scaffold(body: Center(child: Text('Student Photos'))),
    ),
    GetPage(
      name: Routes.studentEditProfile,
      page: () => const EditProfileView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<EditProfileController>(() => EditProfileController());
      }),
    ),
    GetPage(
      name: Routes.studentSettings,
      page: () => const SettingsView(),
    ),
    GetPage(
      name: Routes.studentPrivacy,
      page: () => const PrivacySettingsView(),
    ),
    GetPage(
      name: Routes.ownerShell,
      page: () => const Scaffold(body: Center(child: Text('Owner Shell'))),
    ),
    GetPage(
      name: Routes.ownerDashboard,
      page: () => const Scaffold(body: Center(child: Text('Owner Dashboard'))),
    ),
    GetPage(
      name: Routes.ownerListings,
      page: () => const Scaffold(body: Center(child: Text('Owner Listings'))),
    ),
    GetPage(
      name: Routes.ownerAddListing,
      page: () => const Scaffold(body: Center(child: Text('Add Listing'))),
    ),
    GetPage(
      name: Routes.ownerProfile,
      page: () => const Scaffold(body: Center(child: Text('Owner Profile'))),
    ),
    GetPage(
      name: Routes.ownerEdit,
      page: () => const Scaffold(body: Center(child: Text('Owner Edit Listing'))),
    ),
    GetPage(
      name: Routes.ownerLocationPicker,
      page: () => const Scaffold(body: Center(child: Text('Location Picker'))),
    ),
    GetPage(
      name: Routes.ownerVerification,
      page: () => const Scaffold(body: Center(child: Text('Verification'))),
    ),
    GetPage(
      name: Routes.ownerPublishSuccess,
      page: () => const Scaffold(body: Center(child: Text('Publish Success'))),
    ),
  ];
}

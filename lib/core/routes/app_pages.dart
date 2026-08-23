import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
import '../../features/owner/shell/owner_shell_view.dart';
import '../../features/owner/shell/owner_shell_binding.dart';
import '../../features/owner/add_listing/add_listing_view.dart';
import '../../features/owner/add_listing/add_listing_controller.dart';
import '../../features/owner/add_listing/add_listing_binding.dart';
import '../../features/owner/profile/verification_center_view.dart';
import '../../features/owner/profile/verification_center_controller.dart';
import '../../features/owner/profile/account_settings_view.dart';
import '../../features/owner/profile/owner_edit_profile_view.dart';
import '../../features/owner/profile/owner_edit_profile_controller.dart';
import '../../features/owner/add_listing/widgets/location_picker_view.dart';
import '../../features/owner/add_listing/publish_success_view.dart';
import '../../shared/widget_gallery/widget_gallery_view.dart';
import '../middleware/auth_middleware.dart';
import '../middleware/role_middleware.dart';
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
      middlewares: [AuthMiddleware(), RoleMiddleware()],
    ),
    GetPage(
      name: Routes.studentHome,
      page: () => const Scaffold(body: Center(child: Text('Student Home'))),
    ),
    GetPage(
      name: Routes.studentSearch,
      page: () => const SearchView(),
      binding: SearchBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.studentHostelDetail,
      page: () => const HostelDetailView(),
      binding: HostelDetailBinding(),
      middlewares: [AuthMiddleware()],
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
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.studentSettings,
      page: () => const SettingsView(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.studentPrivacy,
      page: () => const PrivacySettingsView(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.ownerShell,
      page: () => const OwnerShellView(),
      binding: OwnerShellBinding(),
      middlewares: [AuthMiddleware(), RoleMiddleware()],
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
      page: () => const AddListingView(),
      binding: AddListingBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.ownerProfile,
      page: () => const Scaffold(body: Center(child: Text('Owner Profile'))),
    ),
    GetPage(
      name: Routes.ownerEdit,
      page: () => const AddListingView(tag: 'edit'),
      binding: BindingsBuilder(() {
        Get.lazyPut<AddListingController>(() => AddListingController(), tag: 'edit', fenix: true);
      }),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.ownerLocationPicker,
      page: () {
        final args = Get.arguments;
        return LocationPickerView(
          initialLocation: args is LatLng ? args : const LatLng(25.3960, 68.3722),
        );
      },
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.ownerVerification,
      page: () => const VerificationCenterView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<VerificationCenterController>(
            () => VerificationCenterController());
      }),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.ownerPublishSuccess,
      page: () => const PublishSuccessView(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.ownerEditProfile,
      page: () => const OwnerEditProfileView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<OwnerEditProfileController>(
            () => OwnerEditProfileController());
      }),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.ownerAccountSettings,
      page: () => const AccountSettingsView(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}

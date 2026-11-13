import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../features/splash/splash_view.dart';
import '../../features/splash/splash_binding.dart';
import '../../features/welcome/welcome_view.dart';
import '../../features/welcome/welcome_binding.dart';
import '../../features/welcome/dept_welcome_view.dart';
import '../../features/welcome/dept_welcome_binding.dart';
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
import '../../features/owner/verification/verification_center_view.dart';
import '../../features/owner/verification/verification_binding.dart';
import '../../features/owner/profile/account_settings_view.dart';
import '../../features/owner/profile/owner_edit_profile_view.dart';
import '../../features/owner/profile/owner_edit_profile_controller.dart';
import '../../features/owner/add_listing/widgets/location_picker_view.dart';
import '../../features/owner/add_listing/publish_success_view.dart';
import '../../shared/widget_gallery/widget_gallery_view.dart';
import '../../features/legal/legal_view.dart';
import '../../core/constants/legal_content.dart';
import '../../core/constants/app_strings.dart';
import '../../features/account/account_binding.dart';
import '../../features/admin/auth/admin_login_view.dart';
import '../../features/admin/auth/admin_login_binding.dart';
import '../../features/admin/shell/admin_shell_view.dart';
import '../../features/admin/shell/admin_shell_binding.dart';
import '../middleware/admin_middleware.dart';
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
    // Legal documents are public on purpose: they must be readable before
    // signup (the Terms checkbox links here) and by Play reviewers.
    GetPage(
      name: Routes.privacyPolicy,
      page: () => const LegalView(
        title: AppStrings.privacyPolicyTitle,
        sections: LegalContent.privacyPolicy,
      ),
    ),
    GetPage(
      name: Routes.termsOfService,
      page: () => const LegalView(
        title: AppStrings.termsTitle,
        sections: LegalContent.termsOfService,
      ),
    ),
    GetPage(
      name: Routes.welcome,
      page: () => const WelcomeView(),
      binding: WelcomeBinding(),
    ),
    GetPage(
      name: Routes.deptWelcome,
      page: () => const DeptWelcomeView(),
      binding: DeptWelcomeBinding(),
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
      binding: AccountBinding(),
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
      binding: VerificationBinding(),
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
      binding: AccountBinding(),
      middlewares: [AuthMiddleware()],
    ),
    // Admin — login route has NO middleware (it IS the guard target)
    GetPage(
      name: Routes.adminLogin,
      page: () => const AdminLoginView(),
      binding: AdminLoginBinding(),
    ),
    // Every /admin/* route below (including adminShell itself) uses ONLY
    // AdminMiddleware, not AuthMiddleware too. AdminMiddleware's own
    // redirect already covers "not signed in at all" (SessionService's
    // currentUser is null, which fails the role == UserRole.admin check the
    // same as any wrong role would) and sends unauthenticated visitors to
    // /admin/login. Stacking AuthMiddleware() in front of it was a real bug:
    // GetX evaluates middlewares in order and stops at the first non-null
    // redirect, so an unauthenticated admin-route visit was being bounced to
    // the mobile /login screen instead of /admin/login, before
    // AdminMiddleware ever ran.
    GetPage(
      name: Routes.adminShell,
      page: () => const AdminShellView(),
      binding: AdminShellBinding(),
      middlewares: [AdminMiddleware()],
    ),
    // These 7 used to be dead placeholder Scaffolds ("Admin Dashboard" etc.
    // literal text) even after the real section views existed — harmless on
    // mobile, where the equivalent studentHome/ownerDashboard-style
    // sub-routes are genuinely unused, but a real bug on the web: this is a
    // real deployed web app, so a bookmarked or refreshed /admin/users URL
    // must render actual content, not a fake label. All 7 now resolve to
    // the same shared shell; AdminShellController reads Get.currentRoute to
    // land on the matching tab instead of always defaulting to Dashboard.
    GetPage(
      name: Routes.adminDashboard,
      page: () => const AdminShellView(),
      binding: AdminShellBinding(),
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: Routes.adminUsers,
      page: () => const AdminShellView(),
      binding: AdminShellBinding(),
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: Routes.adminOwners,
      page: () => const AdminShellView(),
      binding: AdminShellBinding(),
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: Routes.adminHostels,
      page: () => const AdminShellView(),
      binding: AdminShellBinding(),
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: Routes.adminNotifications,
      page: () => const AdminShellView(),
      binding: AdminShellBinding(),
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: Routes.adminVerification,
      page: () => const AdminShellView(),
      binding: AdminShellBinding(),
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: Routes.adminReview,
      page: () => const AdminShellView(),
      binding: AdminShellBinding(),
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: Routes.adminSettings,
      page: () => const AdminShellView(),
      binding: AdminShellBinding(),
      middlewares: [AdminMiddleware()],
    ),
  ];
}


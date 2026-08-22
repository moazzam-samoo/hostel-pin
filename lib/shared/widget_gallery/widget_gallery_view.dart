import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_assets.dart';
import '../../core/enums/amenity.dart';

// Buttons
import '../widgets/buttons/primary_button.dart';
import '../widgets/buttons/secondary_button.dart';
import '../widgets/buttons/text_link_button.dart';
import '../widgets/buttons/google_auth_button.dart';
import '../widgets/buttons/icon_square_button.dart';
import '../widgets/buttons/icon_circle_button.dart';

// Cards
import '../widgets/cards/hostel_card.dart';
import '../widgets/cards/facility_tile.dart';
import '../widgets/cards/auth_form_card.dart';
import '../widgets/cards/alert_card.dart';
import '../widgets/cards/stat_row_tile.dart';
import '../widgets/cards/activity_row.dart';
import '../widgets/cards/promo_card.dart';

// Inputs
import '../widgets/inputs/app_text_field.dart';
import '../widgets/inputs/app_password_field.dart';
import '../widgets/inputs/app_search_bar.dart';
import '../widgets/inputs/app_switch.dart';
import '../widgets/inputs/field_label.dart';
import '../widgets/inputs/otp_field_row.dart';
import '../widgets/inputs/amenity_selector.dart';
import '../widgets/inputs/app_dropdown_field.dart';

// Navigation
import '../widgets/navigation/app_top_bar.dart';
import '../widgets/navigation/app_bottom_nav.dart';
import '../widgets/navigation/nav_item.dart';

// Layout
import '../widgets/layout/app_scaffold.dart';
import '../widgets/layout/auth_hero_sheet.dart';
import '../widgets/layout/highlighted_body_text.dart';
import '../widgets/layout/price_label.dart';
import '../widgets/layout/section_header.dart';
import '../widgets/layout/form_section_header.dart';
import '../widgets/layout/screen_title_block.dart';
import '../widgets/layout/rating_badge.dart';
import '../widgets/layout/location_tag.dart';
import '../widgets/layout/settings_row.dart';
import '../widgets/layout/status_chip.dart';
import '../widgets/layout/heart_toggle.dart';
import '../widgets/layout/profile_header_block.dart';
import '../widgets/layout/tonal_icon_tile.dart';
import '../widgets/layout/app_gap.dart';
import '../widgets/layout/keyboard_dismiss_wrapper.dart';

// Feedback
import '../widgets/feedback/app_loader.dart';
import '../widgets/feedback/empty_state.dart';
import '../widgets/feedback/error_state.dart';
import '../widgets/feedback/shimmer_box.dart';
import '../widgets/feedback/app_snackbar.dart';
import '../widgets/feedback/confirm_dialog.dart';
import '../widgets/feedback/state_view.dart';

// Media
import '../widgets/media/network_image_box.dart';
import '../widgets/media/user_avatar.dart';
import '../widgets/media/image_carousel.dart';
import '../widgets/media/photo_grid.dart';
import '../widgets/media/upload_placeholder.dart';
import '../widgets/media/file_attachment_tile.dart';
import '../widgets/media/confetti_dots.dart';
import '../widgets/media/map_panel.dart';

class WidgetGalleryView extends StatefulWidget {
  const WidgetGalleryView({super.key});

  @override
  State<WidgetGalleryView> createState() => _WidgetGalleryViewState();
}

class _WidgetGalleryViewState extends State<WidgetGalleryView> {
  bool _switchValue = false;
  bool _heartLiked = false;
  String? _dropdownValue;
  final Set<Amenity> _selectedAmenities = {};
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: AppTopBar(
        variant: AppTopBarVariant.titled,
        title: 'Widget Gallery',
        onBack: () => Get.back(),
      ),
      bottomNav: AppBottomNav(
        currentIndex: _navIndex,
        onTabSelected: (v) => setState(() => _navIndex = v),
        items: const [
          NavItem(label: 'Home', icon: Icons.home, route: ''),
          NavItem(label: 'Saved', icon: Icons.favorite, route: ''),
          NavItem(label: 'Profile', icon: Icons.person, route: ''),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
        children: [
          _buildSection('Buttons', _buildButtons()),
          _buildSection('Cards', _buildCards()),
          _buildSection('Inputs', _buildInputs()),
          _buildSection('Layout', _buildLayouts()),
          _buildSection('Feedback', _buildFeedback(context)),
          _buildSection('Media', _buildMedia()),
          AppGap.xl(),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title),
        AppGap.md(),
        ...children.map((child) => Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.lg),
              child: child,
            )),
        const Divider(),
        AppGap.lg(),
      ],
    );
  }

  List<Widget> _buildButtons() {
    return [
      PrimaryButton(text: 'Primary Button', onPressed: () {}),
      PrimaryButton(text: 'Primary With Icon', icon: const Icon(Icons.add), onPressed: () {}),
      PrimaryButton(text: 'Primary Loading', isLoading: true, onPressed: () {}),
      SecondaryButton(text: 'Secondary Button', onPressed: () {}),
      SecondaryButton(text: 'Secondary Loading', isLoading: true, onPressed: () {}),
      TextLinkButton(text: 'Text Link Button', onPressed: () {}),
      GoogleAuthButton(onPressed: () {}),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconSquareButton(icon: Icons.arrow_back, onPressed: () {}),
          IconCircleButton(icon: Icons.close, onPressed: () {}),
          IconCircleButton(icon: Icons.edit, onPressed: () {}),
        ],
      ),
    ];
  }

  List<Widget> _buildCards() {
    return [
      HostelCard(
        id: '1',
        name: 'Sunshine Hostel',
        location: 'Downtown City',
        price: 15000,
        rating: 4.5,
        imageUrl: 'https://via.placeholder.com/300',
        layout: HostelCardLayout.featured,
        onTap: () {},
      ),
      HostelCard(
        id: '2',
        name: 'Moonlight Dorms',
        location: 'University Road',
        price: 8000,
        rating: 4.2,
        imageUrl: 'https://via.placeholder.com/150',
        layout: HostelCardLayout.compact,
        isSaved: true,
        onTap: () {},
      ),
      const FacilityTile(
        icon: Icons.wifi,
        title: 'Free Wi-Fi',
        subtitle: '',
        style: FacilityTileStyle.read,
      ),
      AuthFormCard(
        child: Column(
          children: [
            Text('Sign In', style: AppTextStyles.authTitle),
            AppGap.md(),
            const AppTextField(hintText: 'Email', leadingIcon: Icons.email),
            AppGap.md(),
            PrimaryButton(text: 'Login', onPressed: () {}),
          ],
        ),
      ),
      const AlertCard(
        title: 'Incomplete Profile',
        message: 'Your profile is incomplete. Please add a photo.',
      ),
      const StatRowTile(title: 'Total Views', value: '1,240', icon: Icons.visibility),
      StatRowTile(
        layout: StatRowTileLayout.card,
        title: 'Total Listing',
        value: '08',
        icon: Icons.apartment_rounded,
        tileColor: AppColors.secondaryContainer,
        iconColor: AppColors.secondary,
        trailing: Text('Active', style: AppTextStyles.labelMicro.copyWith(color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 13)),
      ),
      const ActivityRow(
        title: 'New Booking',
        timeAgo: '2 hours ago',
        icon: Icons.bookmark,
      ),
      PromoCard(
        title: 'Get 20% Off',
        subtitle: 'On your first month',
        buttonText: 'Claim Now',
        onPressed: () {},
        imagePath: AppAssets.appLogo,
      ),
    ];
  }

  List<Widget> _buildInputs() {
    return [
      const FieldLabel('Full Name', isRequired: true),
      const AppTextField(hintText: 'Enter your name', leadingIcon: Icons.person),
      AppGap.md(),
      const FieldLabel('Password'),
      const AppPasswordField(hintText: 'Enter your password'),
      AppGap.md(),
      const AppSearchBar(hintText: 'Search hostels...'),
      AppGap.md(),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Enable Notifications', style: AppTextStyles.body),
          AppSwitch(
            value: _switchValue,
            onChanged: (v) => setState(() => _switchValue = v),
          ),
        ],
      ),
      AppGap.md(),
      OtpFieldRow(onResend: () {}),
      AppGap.md(),
      const FormSectionHeader(title: 'Select Amenities', description: 'Choose what you offer'),
      AppGap.md(),
      AmenitySelector(
        selectedAmenities: _selectedAmenities,
        onToggle: (amenity) {
          setState(() {
            if (_selectedAmenities.contains(amenity)) {
              _selectedAmenities.remove(amenity);
            } else {
              _selectedAmenities.add(amenity);
            }
          });
        },
      ),
      AppGap.md(),
      AppDropdownField<String>(
        value: _dropdownValue,
        hintText: 'Select City',
        items: const [
          DropdownMenuItem(value: '1', child: Text('City A')),
          DropdownMenuItem(value: '2', child: Text('City B')),
        ],
        onChanged: (v) => setState(() => _dropdownValue = v),
      ),
    ];
  }

  List<Widget> _buildLayouts() {
    return [
      SizedBox(
        height: 320,
        child: AuthHeroSheet(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome Back', style: AppTextStyles.authTitle),
                AppGap.sm(),
                Text('Hello there, sign in to continue', style: AppTextStyles.screenSubtitle),
              ],
            ),
          ),
        ),
      ),
      const ScreenTitleBlock(title: 'Welcome Back!', subtitle: 'Here is your dashboard'),
      const HighlightedBodyText(
        textBefore: 'We sent an email to ',
        highlightedText: 'test@example.com',
        textAfter: '. Please check your inbox.',
      ),
      const PriceLabel(price: 15500),
      const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          RatingBadge(rating: 4.8),
          LocationTag(location: 'Near Campus'),
        ],
      ),
      const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          StatusChip(type: StatusChipType.active),
          StatusChip(type: StatusChipType.pending),
          StatusChip(type: StatusChipType.available),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HeartToggle(
            isLiked: _heartLiked,
            onToggle: (v) => setState(() => _heartLiked = v),
          ),
        ],
      ),
      ProfileHeaderBlock(name: 'Moazzam Samoo', email: 'moazzam@example.com', onEdit: () {}),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TonalIconTile(icon: Icons.map, title: 'Map View', onTap: () {}),
          TonalIconTile(icon: Icons.support, title: 'Support', onTap: () {}),
        ],
      ),
      KeyboardDismissWrapper(
        child: Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceTonal,
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Text(
            'KeyboardDismissWrapper — tap anywhere in this box to dismiss a focused field',
            style: AppTextStyles.caption,
          ),
        ),
      ),
      SettingsRow(icon: Icons.person, title: 'Account Settings', onTap: () {}),
      SettingsRow(
        icon: Icons.delete,
        title: 'Delete Account',
        isDestructive: true,
        trailing: SettingsRowTrailing.none,
        onTap: () {},
      ),
    ];
  }

  List<Widget> _buildFeedback(BuildContext context) {
    return [
      const AppLoader(message: 'Loading your data...'),
      const EmptyState(
        title: 'No Hostels Found',
        message: 'Try adjusting your search filters.',
        icon: Icons.search_off,
      ),
      const ErrorState(
        message: 'Could not connect to the server.',
      ),
      const ShimmerBox(height: 100, width: double.infinity),
      const SizedBox(
        height: 100,
        child: StateView(
          state: StateViewStatus.loading,
          contentBuilder: SizedBox.shrink(),
        ),
      ),
      const SizedBox(
        height: 100,
        child: StateView(
          state: StateViewStatus.empty,
          contentBuilder: SizedBox.shrink(),
          emptyBuilder: EmptyState(
            title: 'Nothing here',
            message: 'StateView empty state',
            icon: Icons.inbox_outlined,
          ),
        ),
      ),
      const SizedBox(
        height: 100,
        child: StateView(
          state: StateViewStatus.content,
          contentBuilder: Center(child: Text('StateView content state')),
        ),
      ),
      PrimaryButton(
        text: 'Show Success Snackbar',
        onPressed: () => AppSnackbar.show(context, message: 'Saved successfully', type: SnackbarType.success),
      ),
      PrimaryButton(
        text: 'Show Error Snackbar',
        onPressed: () => AppSnackbar.show(context, message: 'Failed to save', type: SnackbarType.error),
      ),
      PrimaryButton(
        text: 'Show Confirm Dialog',
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => ConfirmDialog(
              title: 'Log Out',
              message: 'Are you sure you want to log out?',
              onConfirm: () => Navigator.pop(ctx),
              onCancel: () => Navigator.pop(ctx),
              confirmText: 'Log Out',
              isDestructive: true,
            ),
          );
        },
      ),
    ];
  }

  List<Widget> _buildMedia() {
    return [
      const NetworkImageBox(
        imageUrl: 'https://via.placeholder.com/400x200',
        height: 200,
        width: double.infinity,
      ),
      const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          UserAvatar(name: 'Ali Khan', size: 60),
          UserAvatar(name: 'Moazzam Samoo', imageUrl: 'https://via.placeholder.com/100', size: 60),
        ],
      ),
      const ImageCarousel(
        imageUrls: [
          'https://via.placeholder.com/400x250?text=1',
          'https://via.placeholder.com/400x250?text=2',
        ],
      ),
      PhotoGrid(
        imageUrls: const [
          'https://via.placeholder.com/200',
          'https://via.placeholder.com/100',
          'https://via.placeholder.com/100',
          'https://via.placeholder.com/100',
          'https://via.placeholder.com/100',
        ],
        onSeeAll: () {},
      ),
      UploadPlaceholder(onTap: () {}),
      FileAttachmentTile(fileName: 'hostel_license.pdf', fileSize: '2.4 MB', onRemove: () {}),
      Center(
        child: ConfettiDots(
          canvasSize: AppSizes.authLogo + 40,
          child: ClipOval(
            child: Image.asset(
              AppAssets.appLogo,
              width: AppSizes.authLogo,
              height: AppSizes.authLogo,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(
                width: AppSizes.authLogo,
                height: AppSizes.authLogo,
                color: AppColors.primary,
                child: const Icon(Icons.home, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
      AppGap.md(),
      const MapPanel(mode: MapPanelMode.readonly),
      AppGap.md(),
      MapPanel(mode: MapPanelMode.picker, onTap: () {}),
    ];
  }
}

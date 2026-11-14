class AppStrings {
  // App
  static const String appName = 'HostelPin';

  // Onboarding
  static const String welcome = 'Welcome!';
  static const String welcomeTo = 'To HostelPin App';
  static const String continueButton = 'Continue';
  static const String hostelPinApp = 'HostelPin App';
  static const String developedBy = 'Developed By ';
  static const String imcsStudents = 'IMCS Students';

  // Role Selection

  static const String studentSectionTitle = 'Student';
  static const String studentDescriptionTitle = "I'm a Student";
  static const String studentDescriptionBody = 'Looking for a hostel to stay';
  static const String continueAsStudent = 'Continue As Student';

  static const String ownerSectionTitle = 'Owner';
  static const String ownerDescriptionTitle = "I'm a Hostel Owner";
  static const String ownerDescriptionBody = 'I want to list my hostel';
  static const String continueAsOwner = 'Continue As Owner';

  // Auth
  static const String login = 'Login';
  static const String signup = 'Sign Up';
  static const String welcomeBack = 'Welcome Back';
  static const String loginSubtitle = 'Hello there, sign in to continue';
  static const String forgotPassword = 'Forgot your password ?';
  static const String enterEmail = 'Enter email';
  static const String emailLabel = 'Type your email address';
  static const String passwordLabel = 'Password';
  static const String orContinueWith = 'or Continue with';
  static const String noAccountSignup = "Don't have an account? Sign up";

  static const String fullNameLabel = 'Full Name';
  static const String phoneLabel = 'Phone';
  static const String confirmPasswordLabel = 'Confirm Password';
  static const String createAccount = 'Create Account';
  static const String haveAccountLogin = 'Already have an account? Login';

  static const String sendResetLink = 'Send Reset Link';
  static const String resetLinkSentPrefix = 'We sent a password reset link to ';
  static const String resetLinkSentSuffix = '. The link expires in 1 hour.';
  static const String checkEmailTitle = 'Check Your Email';
  static const String backToLogin = 'Back to Login';

  static const String enterOtp = 'Enter OTP';
  static const String otpExpireText = 'This code will expire in 10 minutes';
  static const String resendCode = 'Resend';
  static const String verifyEmailTitle = 'Verify Your Email';
  static const String otpFieldHint = 'Enter 4-digit OTP';
  static const String otpSentToPrefix =
      'We texted you a code to verify your email address: ';
  static const String otpSentToSuffix = '';
  static const String verifyButton = 'Verify';

  static const String changePasswordTitle = 'Change password';
  static const String newPasswordLabel = 'Type your new password';
  static const String confirmPasswordFieldLabel = 'Confirm password';
  static const String changePasswordButton = 'Change password';
  static const String reauthTitle = 'Re-authenticate';
  static const String reauthMessage =
      'Please enter your current password to continue.';
  static const String reauthConfirmButton = 'Confirm';
  static const String cancelButton = 'Cancel';

  static const String passwordSuccessTitle = 'Change password successfully!';
  static const String passwordSuccessBody =
      'You have successfully changed your password.';
  static const String passwordSuccessFooter =
      'Please use the new password when signing in.';
  static const String okButton = 'Ok';

  // Owner Dashboard & Navigation
  static const String dashboard = 'Dashboard';
  static const String myHostels = 'My Hostels';
  static const String addHostel = 'Add Hostel';
  static const String profile = 'Profile';
  static const String controlProfile = 'Control your profile';
  static const String roomsExample = 'e.g. 50 rooms';
  static String dashboardGreeting(String name) => 'Hello, $name 👋';
  static const String dashboardSubtitle =
      'Manage your listings and student inquiries from one place.';
  static const String totalListingLabel = 'Total Listing';
  static const String totalViewsLabel = 'Total Views';
  static const String activeLabel = 'Active';
  static const String trafficLabel = 'Traffic';
  static const String viewListingButton = 'View listing';
  static const String pendingVerificationTitle = 'Pending Verification';
  static String pendingVerificationMessage(String hostelName) =>
      'Hostel "$hostelName" is currently under review by our team. This usually takes 24 hours.';
  // Distinct from pendingVerificationTitle/Message above (identity
  // verification): this alert is about a specific LISTING awaiting admin
  // approval, which can be true even once the owner is fully verified (any
  // later listing they add still goes through the same review gate).
  static const String pendingPropertyTitle = 'Pending Property';
  static String pendingPropertyMessage(String hostelName) =>
      'Hostel "$hostelName" is awaiting admin approval before it goes live. This usually takes 24 hours.';
  static String pendingPropertiesCountMessage(int count) =>
      '$count of your listings are awaiting admin approval before they go live.';
  static const String recentActivity = 'Recent Activity';
  static const String genericPropertyName = 'Your property';

  // Owner Listings
  static const String myHostelsSubtitle =
      'Manage your campus properties and availability.';
  static const String editButton = 'Edit';
  static const String deleteButton = 'Delete';
  static const String deleteListingTitle = 'Delete Listing';
  static const String deleteListingMessage =
      'Are you sure you want to delete this listing? This cannot be undone.';
  static const String expandReachTitle = 'Expand Your Reach';
  static const String expandReachSubtitle =
      'Have another property? Add it now to start receiving bookings.';
  static const String addAnotherHostel = 'Add another hostel';
  static const String noListingsTitle = 'No Listings Yet';
  static const String noListingsMessage = 'You have not added any hostels yet.';

  // Owner Add Listing
  static const String listPropertyTitle = 'List Your Property';
  static const String listPropertySubtitle =
      'List your hostel to connect with students looking for a place to stay.';
  static const String identityLocationSection = 'Identity & Location';
  static const String hostelNameLabel = 'HOSTEL NAME';
  static const String hostelNameHint = 'e.g: Chandia Hostel';
  static const String fullAddressLabel = 'FULL ADDRESS';
  static const String fullAddressHint = 'e.g: in Qasimabad';
  static const String descriptionLabel = 'DESCRIPTION';
  static const String descriptionHint =
      'Tell students about your hostel — rooms, nearby landmarks, house rules...';
  static const String addPhotosSection = 'Add Photos of your Hostel';
  static const String uploadPicturesLabel = 'Upload pictures';
  static const String uploadPicturesHint = 'click to browse';
  static const String minPhotosNote = '(Minimum 3 photos required, max 10)';
  static const String roomsPricingSection = 'Rooms & Pricing';
  static const String monthlyPriceLabel = 'Monthly Price';
  static const String totalRoomsLabel = 'Total Rooms';
  static const String includedFacilitiesLabel = 'Included Facilities..';
  static const String availabilityLabel = 'Availability';
  static const String fullStatus = 'Full';
  static const String ownerConnectivitySection = 'Owner Connectivity';
  static const String phoneNoLabel = 'Phone no:';
  static const String phoneHint = '+92-320605300';
  static const String whatsappNumberLabel = 'Whatsapp number:';
  static const String sameAsPhoneLabel = 'Same as phone number';
  // Property ownership document — required for every brand-new listing
  // (an already-verified owner's 2nd, 3rd, ... hostel), same document kind
  // the verification wizard's step 4 collects for an owner's first hostel,
  // but never a full re-verification. See
  // AddListingController._requiresOwnershipDocument.
  static const String ownershipDocumentSection = 'Property Ownership Document';
  static const String ownershipDocumentSectionNote =
      'Upload proof you own or manage this property.';
  static const String uploadOwnershipDocumentTitle = 'Upload Document';
  static const String uploadOwnershipDocumentSubtitle =
      'PDF, JPG, PNG (Max 5MB)';
  static const List<String> ownershipDocumentInstructions = [
    'Document must be issued within the last 6 months',
    'All pages must be included',
    'Name must match your registered business name',
  ];
  static const String saveAsDraft = 'Save as Draft';
  static const String publishListing = 'Publish Listing';
  // 2.A: every brand-new listing now goes through admin review before it's
  // publicly visible — "Submit for Review" doesn't imply the immediacy
  // "Publish Listing" would. Editing an already-existing listing (draft or
  // published) keeps the original "Publish Listing"/"Update Listing"
  // wording, since re-publishing an edit still applies to it directly.
  static const String submitForReviewButton = 'Submit for Review';
  static const String totalBedsLabel = 'Total Beds';
  static const String bedsExample = 'e.g. 80 beds';
  static const String editListingTitle = 'Edit Listing';
  static const String updateListingButton = 'Update Listing';
  static const String listingPublishedTitle = 'Listing Published!';
  static const String listingPublishedBody =
      'Your hostel has been successfully published.';
  static const String listingSubmittedTitle = 'Listing Submitted!';
  static const String listingSubmittedBody =
      'Your hostel has been submitted for review. We\'ll notify you once our team approves it — this usually takes 24 hours.';
  static const String listingSubmittedActivityTitle = 'Listing Submitted for Review';
  static String listingSubmittedActivityMessage(String hostelName) =>
      'You submitted $hostelName for admin approval.';

  // Owner Profile
  static const String ownerProfileMyHostelsSubtitle = 'Manage your hostel';
  static const String verificationCenterTitle = 'Verification Center';
  static const String verificationCenterSubtitle = 'Manage identity';
  static const String verificationStatusUnverified = 'Unverified';
  static const String verificationStatusPending = 'Pending';
  static const String verificationStatusVerified = 'Verified';
  static const String currentStatusLabel = 'Current Status:';
  static const String uploadDocumentLabel = 'Upload Document';
  static const String verificationDocumentHint =
      'Upload your CNIC or Business Registration to verify your identity.';

  // 2.B — Add tab gate. Shown instead of the real Add Listing form when the
  // signed-in owner's SessionService.currentUser.value.verificationStatus
  // is not VerificationStatus.verified.
  static const String addTabGateTitle = 'Verification Required';
  static const String addTabGateMessage =
      'Complete identity verification before listing a hostel. It only takes a few minutes, and our team typically reviews it within 24 hours.';
  static const String addTabGateButton = 'Start Verification';
  static const String addTabGatePendingMessage =
      'Your verification is under review by our team. You\'ll be able to list a hostel as soon as it\'s approved — this usually takes 24 hours.';
  static const String addTabGateViewStatusButton = 'View Verification Status';

  // Owner Add Listing — location picker & publish success
  static const String pickLocationTitle = 'Pick Location';
  static const String confirmLocationButton = 'Confirm Location';
  static const String backToDashboardButton = 'Back to Dashboard';
  static const String tapToPinLocation = 'Tap to pin location';
  static const String locationSourceSheetTitle = 'Set hostel location';
  static const String useCurrentLocationOption = 'Use current location';
  static const String useCurrentLocationSubtitle =
      "Use your device's live GPS position";
  static const String chooseOnMapOption = 'Choose location from map';
  static const String chooseOnMapSubtitle = 'Drag the map to drop a pin';
  static const String imageSourceSheetTitle = 'Add photo';
  static const String takePhotoOption = 'Take photo';
  static const String takePhotoSubtitle = 'Use your camera';
  static const String chooseFromGalleryOption = 'Choose from gallery';
  static const String chooseFromGallerySubtitle = 'Pick an existing photo';
  static const String errorLocationUnavailable =
      'Could not get your current location. Check that location services and permission are enabled.';
  // Owner Verification Wizard — camera permission-denied fallback (Block
  // A.7), mirroring MapController._showLocationRationale's rationale-dialog
  // pattern rather than a raw OS permission crash.
  static const String cameraPermissionTitle = 'Camera Access Needed';
  static const String cameraPermissionMessage =
      'HostelPin needs camera access to capture your identity and ownership documents. Please enable it in your device settings and try again.';
  static String photosSelectedCount(int count) =>
      '$count/10 photo${count == 1 ? '' : 's'} selected';
  static String locationCoordinatesLabel(double lat, double lng) =>
      'Lat ${lat.toStringAsFixed(4)}, Lng ${lng.toStringAsFixed(4)}';
  static const String unsavedChangesTitle = 'Discard changes?';
  static const String unsavedChangesMessage =
      'You have unsaved changes. Are you sure you want to leave without saving?';
  static const String discardButton = 'Discard';
  static const String priceMonthSuffix = '/mnth';
  static const String errorMinPhotos = 'Please add at least 3 photos.';
  static const String errorMaxPhotos = 'You can add up to 10 photos only.';
  static const String draftSavedMessage =
      'Your listing has been saved as a draft.';
  static const String listingDeletedMessage = 'Listing has been deleted.';

  // General & Amenities
  static const String meals = 'Meals';
  static const String carBike = 'Car+Bike';

  // Validation & Errors
  static const String errorRequired = 'This field is required';
  static const String errorEmailRequired = 'Email is required';
  static const String errorEmailInvalid = 'Invalid email address';
  static const String errorPasswordRequired = 'Password is required';
  static const String errorPasswordLength =
      'Password must be at least 8 characters';
  static const String errorPasswordUpper =
      'Password must contain at least one uppercase letter';
  static const String errorPasswordNumber =
      'Password must contain at least one number';
  static const String errorConfirmPasswordRequired =
      'Please confirm your password';
  static const String errorConfirmPasswordMatch = 'Passwords do not match';
  static const String errorPhoneRequired = 'Phone number is required';
  static const String errorPhoneInvalid =
      'Enter a valid number starting with +92';
  static const String errorPriceInvalid = 'Enter a valid price';
  static const String errorRoomsInvalid = 'Enter a valid number of rooms';
  static const String errorBedsInvalid = 'Enter a valid number of beds';
  static const String errorCnicInvalid = 'Enter a valid 13-digit CNIC number';
  static const String errorDobRequired = 'Date of birth is required';
  static const String errorGeneric =
      'An unexpected error occurred. Please try again.';

  // Firebase Errors
  static const String errorUserNotFound = 'No user found for that email.';
  static const String errorWrongPassword = 'Wrong password provided.';
  static const String errorInvalidCredential = 'Invalid email or password.';
  static const String errorEmailInUse =
      'The account already exists for that email.';
  static const String errorWeakPassword = 'The password provided is too weak.';
  static const String errorOperationNotAllowed =
      'This sign-in method is not enabled.';
  static const String errorTooManyRequests =
      'Too many requests. Please try again later.';
  static const String errorUserDisabled =
      'This user account has been disabled.';
  static const String errorNetwork =
      'Network error. Please check your connection.';
  static const String errorRequiresRecentLogin =
      'This operation requires you to re-authenticate.';
  static const String errorAccountExistsWithDifferentCredential =
      'An account already exists with the same email but a different sign-in method.';

  // Owner Dashboard
  static const String noRecentActivity = 'No recent activity';

  // Home & Shared
  static const String searchHint = 'Search...';
  static const String featuredHostels = 'Featured Hostels';
  static const String viewAll = 'View all';
  static const String ratingFallback = '0.0';
  static const String gymLabel = 'Gym';
  static const String security247 = '24/7 Sec';
  static const String allHostelsSection = 'All Hostels';
  static const String noHostelsAddedYetTitle = 'No Hostels Added Yet';
  static const String noHostelsAddedYetMessage =
      "Hostels haven't been added yet, we'll add soon!";

  // Hostel Detail
  static const String availableStatus = 'Available';
  static const String locationPrefix = 'Location : ';
  static const String callButton = 'Call';
  static const String whatsappButton = 'Whatsapp';
  static const String premiumFacilities = 'Premium Facilities...';
  static const String aboutHostel = 'About the Hostel..';
  static const String hostelLocationHeader = 'Location of our Hostel...';
  static const String dropYourLocation = 'Drop your location';

  // Map
  static const String viewDetailsLink = 'View details';
  static const String getDirectionsButton = 'Get Directions';
  static const String noMapsAppFound = 'No maps app found on this device.';
  static const String allowLocationAccess = 'Allow Location Access';
  static const String notNow = 'Not Now';
  static const String continueText = 'Continue';

  // Saved
  static const String savedEmptyTitle = 'No saved hostels yet';
  static const String savedEmptyMessage =
      'Save hostels while you explore to see them all here in your personal curated list.';
  static const String startBrowsing = 'Start Browsing';
  static const String youMightAlsoLike = 'You might also like';
  static const String detailsLink = 'Details';

  // Profile
  static const String profileScreenTitle = 'Profile';
  static const String editProfileButton = 'Edit Profile';
  static const String appPreferencesSection = 'App Preferences';
  static const String securityPrivacySection = 'Security & Privacy';
  static const String darkModeTitle = 'Dark Mode';
  static const String darkModeSubtitle = 'Switch to dark mode';
  static const String notificationsTitle = 'Notifications';
  static const String notificationsSubtitle = 'Stay updated';
  static const String languageSelectionTitle = 'Language Selection';
  static const String languageSelectionValue = 'English(US)';
  static const String accountSettingsTitle = 'Account Settings';
  static const String accountSettingsSubtitle = 'Preferences & Privacy';
  static const String savedHostelsTitle = 'Saved Hostels';
  static String savedHostelsSubtitle(int count) => '$count places you love';
  static const String changePasswordRowTitle = 'Change Password';
  static const String changePasswordRowSubtitle = 'Keep your account secure';
  static const String privacySettingsTitle = 'Privacy Settings';
  static const String logoutTitle = 'Logout';
  static const String logoutSubtitle = 'Securely sign out';
  static const String comingSoonSuffix = ' (Coming soon)';
  static const String editProfileNameLabel = 'Full Name';
  static const String editProfileSaved = 'Profile updated';
  static const String logoutConfirmTitle = 'Log Out';
  static const String logoutConfirmMessage =
      'Are you sure you want to log out?';
  static const String settingsPlaceholder =
      'More account settings are coming soon.';
  static const String privacyPlaceholder = 'Privacy controls are coming soon.';
  static const String languageSheetTitle = 'Select Language';

  // Search / Filter
  static const String searchResultsTitle = 'Search Results';
  static const String noResultsTitle = 'No Results Found';
  static const String noResultsMessage =
      'We could not find any hostels matching your criteria.';
  static const String recentSearches = 'Recent Searches';
  static const String filterTitle = 'Filters';
  static const String priceRangeLabel = 'Price Range';
  static const String amenitiesLabel = 'Amenities';
  static const String genderPreferenceLabel = 'Gender Preference';
  static const String distanceLabel = 'Distance';
  static const String ratingLabel = 'Minimum Rating';
  static const String applyFilters = 'Apply';
  static const String resetFilters = 'Reset';
  static const String sortTitle = 'Sort By';
  static const String sortPriceLowHigh = 'Price: Low to High';
  static const String sortPriceHighLow = 'Price: High to Low';
  static const String sortRating = 'Rating: High to Low';
  static const String sortDistance = 'Distance: Nearest First';

  // Owner Verification Wizard — stepper action row
  static const String verificationBackButton = 'Back';
  static const String verificationNextButton = 'Next';
  static const String submitVerificationButton = 'Submit Verification';

  // Owner Verification Wizard — Step 1 (Personal Information)
  static const String personalInfoStepTitle = 'Personal Information';
  static const String personalInfoStepSubtitle =
      'Please provide your details as they appear on your CNIC.';
  static const String guardianNameLabel = 'Father/Guardian Name';
  static const String guardianNameHint = 'Jane Doe';
  static const String fullNameHint = 'John Doe';
  static const String cnicNumberLabel = 'CNIC Number';
  static const String cnicNumberHint = 'xxxxx-xxxxxxx-x';
  static const String dobLabel = 'Date of Birth';
  static const String dobHint = 'DD-MM-YYYY';
  static const String emailAddressLabel = 'Email Address';
  static const String emailAddressHint = 'john@example.com';
  static const String cityFieldLabel = 'City';
  static const String cityFieldHint = 'Hyderabad';

  // Owner Verification Wizard — Step 2 (Identity Documents)
  static const String identityDocumentsStepTitle = 'Identity Documents';
  static const String identityDocumentsStepSubtitle =
      'Please capture clear photos of your CNIC and a selfie for verification.';
  static const String cnicFrontLabel = 'CNIC Front';
  static const String cnicBackLabel = 'CNIC Back';
  static const String selfieLabel = 'Selfie';
  static const String tapToCaptureLabel = 'Tap to capture';
  static const String alreadyCapturedRetakeLabel = 'Already captured — tap to retake';
  static const String cameraErrorGenericMessage = 'Could not open camera. Please try again.';

  // Owner Verification Wizard — Step 3 (Hostel Information)
  static const String hostelInfoStepTitle = 'Hostel Information';
  static const String hostelInfoStepSubtitle =
      'Provide details about the primary hostel you intend to manage.';
  static const String errorNoIdentityDocuments =
      'Please capture all required identity documents.';
  static const String errorNoOwnershipDocument =
      'Please upload a property ownership document.';
  static const String verificationSubmittedMessage =
      'Verification request submitted successfully.';
  static const String defaultCityFallback = 'Unknown city';

  // Owner Verification Wizard — Step 4 (Hostel Documents)
  static const String hostelDocumentsStepTitle = 'Hostel Documents';
  static const String hostelDocumentsStepSubtitle =
      'Please capture clear photos of your property ownership or lease documents for verification.';
  static const String ownershipDocumentLabel = 'Ownership/Lease Document';
  static const String tapToCaptureDocumentLabel = 'Tap to capture document';

  // Owner Verification Wizard — Step 5 (Review & Submit)
  static const String reviewStepTitle = 'Review & Submit';
  static const String reviewStepSubtitle =
      'Please review your information before submitting for verification.';
  static const String personalInfoSectionTitle = 'Personal Info';
  static const String reviewLabelName = 'Name';
  static const String reviewLabelCnic = 'CNIC';
  static const String reviewLabelEmail = 'Email';
  static const String capturedLabel = 'Captured';
  static const String missingLabel = 'Missing';
  static const String hostelInfoSectionTitle = 'Hostel Info';
  static const String reviewLabelAddress = 'Address';
  static const String reviewLabelPrice = 'Price';
  static const String reviewLabelRoomsBeds = 'Rooms / Beds';
  static const String reviewLabelPhotos = 'Photos';
  static const String reviewLabelAmenities = 'Amenities';
  static const String ownershipDocumentSectionTitle = 'Ownership Document';
  // Review Step (Hostel Documents)
  static const String reviewLabelOwnershipDoc = 'Ownership Doc';

  static const String reviewPolicyText = 'I confirm that the information and documents provided are accurate and complete to the best of my knowledge. I understand that providing false information may result in verification failure or account suspension.';
  static const String errorAcceptPolicy = 'Please confirm the policy to proceed.';
  static const String submitForVerificationButton = 'Submit for verification';
  static String reviewPhotosCount(int count) => '$count photo${count == 1 ? '' : 's'}';
  static String amenitiesSelectedCount(int count) => '$count selected';
  static String roomsAndBeds(String rooms, String beds) => '$rooms rooms, $beds beds';
  static const String notAvailableDash = '—';

  // ── Phase 9 — Admin Web Panel ─────────────────────────────────────────
  // Admin login
  static const String adminAppTitle = 'HostelPin Admin';
  static const String adminDefaultDisplayName = 'Admin';
  static const String adminPortalBadge = 'HOSTELPIN MANAGEMENT';
  static const String adminLoginWelcome = 'Welcome back to Admin Portal';
  static const String adminLoginHelp = 'Protected portal for authorized administrators only.';
  static const String adminLoginSubtitle = 'Sign in to the admin dashboard';
  static const String adminSignInButton = 'Sign In';
  static const String adminAccessDenied =
      'Access denied. This account does not have admin privileges.';

  // Shell / sidebar / top bar
  static const String adminNavDashboard = 'Dashboard';
  static const String adminNavUsers = 'Users';
  static const String adminNavOwners = 'Owners';
  static const String adminNavHostels = 'Hostels';
  static const String adminNavNotifications = 'Notification';
  static const String adminNavVerificationQueue = 'Verification Queue';
  static const String adminNavSettings = 'Settings';
  static const String adminSignOut = 'Logout';
  static const String adminLogoutConfirmTitle = 'Log Out';
  static const String adminLogoutConfirmMessage =
      'Are you sure you want to sign out of the admin panel?';
  static const String adminTopBarSearchHint = 'Search...';

  // Dashboard
  static const String adminDashboardOverview = 'Overview';
  static String adminDashboardWelcome(String name) =>
      "Welcome back, $name. Here's what's happening today.";
  static const String adminStatTotalStudents = 'Total Students';
  static const String adminStatTotalOwners = 'Total Owners';
  static const String adminStatTotalHostels = 'Total hostels';
  static const String adminStatActiveListings = 'Active listing';
  static const String adminUserGrowthTitle = 'User Growth';
  static const String adminUserGrowthSubtitle = 'Monthly student registrations';
  static const String adminUserDistributionTitle = 'User Distribution';
  static const String adminNoData = 'No Data';
  static const String adminLegendStudents = 'Students';
  static const String adminLegendOwners = 'Owners';
  static const String adminLegendBoth = 'Both';
  static const String adminDashboardLoadError = 'Failed to load dashboard data.';

  // Users / Owners / Hostels tables
  static const String adminManageUsersTitle = 'Manage Users';
  static const String adminManageOwnersTitle = 'Manage Owners';
  static const String adminManageHostelsTitle = 'Manage Hostels';
  static const String adminNoUsersFound = 'No users found.';
  static const String adminNoOwnersFound = 'No owners found.';
  static const String adminNoHostelsFound = 'No hostels found.';
  static const String adminStudentsDirectory = 'Students Directory';
  static const String adminOwnersDirectory = 'Owners Directory';
  static const String adminHostelsDirectory = 'Hostels Directory';
  static const String adminColName = 'Name';
  static const String adminColEmail = 'Email';
  static const String adminColJoined = 'Joined';
  static const String adminColStatus = 'Status';
  static const String adminColActions = 'Actions';
  static const String adminColListings = 'Listings';
  static const String adminColVerification = 'Verification';
  static const String adminColCity = 'City';
  static const String adminColPrice = 'Price';
  static const String adminLoadingLabel = 'Loading…';
  static const String adminBlockUserTooltip = 'Block User';
  static const String adminUnblockUserTooltip = 'Unblock User';
  static const String adminBlockOwnerTooltip = 'Block Owner';
  static const String adminUnblockOwnerTooltip = 'Unblock Owner';
  static const String adminDeleteUserTooltip = 'Delete User';
  static const String adminDeleteOwnerTooltip = 'Delete Owner';
  static const String adminDeleteHostelTooltip = 'Delete Hostel';
  static const String adminConfirmDeleteTitle = 'Confirm Delete';
  static String adminConfirmDeleteMessage(String name) =>
      'Are you sure you want to delete $name? This action cannot be undone.';
  static const String adminDeleteButton = 'Delete';
  static const String adminCancelButton = 'Cancel';
  static String adminUserStatusUpdated(String name, String status) =>
      '$name is now $status.';
  static String adminUserDeleted(String name) => '$name deleted.';
  static const String adminGenericLoadError = 'Failed to load data.';
  static const String adminGenericUpdateError = 'Failed to update. Please try again.';
  static const String adminGenericDeleteError = 'Failed to delete. Please try again.';

  // Notification Center
  static const String adminNotificationsTitle = 'Notifications';
  static const String adminMarkAllAsRead = 'Mark all as read';
  static const String adminClearAll = 'Clear All';
  static const String adminTabAll = 'All';
  static const String adminTabVerifications = 'Verifications';
  static const String adminTabReports = 'Reports';
  static const String adminTabSystem = 'System';
  static const String adminNoNotifications = 'No notifications here.';
  static const String adminMarkAsReadTooltip = 'Mark as read';
  static const String adminAllNotificationsCleared = 'All notifications cleared.';
  static const String adminNotificationLoadError = 'Failed to load notifications.';
  static String adminPendingVerificationNotifTitle(String name) =>
      '$name submitted KYC documents.';
  static const String adminPendingVerificationNotifHeading = 'Pending Verification';
  static const String adminHostelReportedNotifHeading = 'Hostel Reported';
  static String adminReportReasonMessage(String reason) => 'Reason: $reason';
  // Notification Center's System tab is a stub/manually-seeded category
  // (Block F.3) — this project has no deployed scheduled Cloud Functions
  // (Blaze-blocked), so "System" copy is decorative, not live automation.
  static const String adminSystemNotifStubTitle = 'System Update';
  static const String adminSystemNotifStubMessage =
      'Weekly system backup completed successfully.';

  // Verification Queue + Review
  static const String adminVerificationQueueTitle = 'Verification Queue';
  static const String adminVerificationQueueSubtitle =
      'Review and process new hostel and owner registrations.';
  static String adminPendingCountBadge(int count) => '$count PENDING';
  static const String adminTabIdentityPending = 'Identity Pending';
  static const String adminTabHostelPending = 'Hostel Pending';
  static const String adminTabChangesRequired = 'Changes Required';
  static const String adminColSubmissionDate = 'Submission Date';
  static const String adminColOwnerName = 'Owner Name';
  static const String adminColHostelName = 'Hostel Name';
  static const String adminColType = 'Type';
  static const String adminTypeHostel = 'Hostel';
  static const String adminTypeIdentity = 'Identity';
  static const String adminReviewButton = 'Review';
  static const String adminNoSubmissionsFound = 'No submissions in this category.';
  static const String adminBackToQueue = 'Back to queue';
  static String adminReviewHeading(String ownerName) => 'Review: $ownerName';
  static const String adminOwnerDetailsSection = 'Owner Details';
  static const String adminIdentityDocumentsSection = 'Identity Documents';
  static const String adminPropertyDetailsSection = 'Property Details';
  static const String adminOwnershipProofSection = 'Ownership Proof';
  static const String adminPropertyPhotosSection = 'Property Photos';
  static const String adminFullNameLabel = 'Full Name';
  static const String adminCnicNumberLabel = 'CNIC Number';
  static const String adminPhoneNumberLabel = 'Phone Number';
  static const String adminDobLabel = 'Date of Birth';
  static const String adminHostelNameFieldLabel = 'Hostel Name';
  static const String adminAddressLabel = 'Address';
  static const String adminCityLabel = 'City';
  static const String adminCapacityLabel = 'Capacity';
  static String adminCapacityValue(int rooms, int beds) => '$rooms Rooms / $beds Beds';
  static const String adminCnicFrontLabel = 'CNIC Front';
  static const String adminCnicBackLabel = 'CNIC Back';
  static const String adminLiveSelfieCheckLabel = 'Live Selfie Check';
  static const String adminAiMatchedBadge = 'AI Matched';
  // Per IMPLEMENTATION_PLAN.md §9.A/D1 and TASK-Phase-9 Block G.2: identity
  // verification stays manual. This match figure is NOT wired to any real
  // computation — it is static, decorative copy that echoes the mockup's
  // layout only. Never compute or persist a real percentage here.
  static const String adminAiMatchDecorativeValue = '92% Match';
  static const String adminAiMatchDecorativeCaption =
      'Facial recognition indicates a high probability match between the live selfie and the provided CNIC photo.';
  static const String adminViewFullDocumentButton = 'View Full Document';
  static const String adminDocumentNotProvided = 'Not provided';
  static const String adminDocumentLoadError = 'Could not load this document.';
  static const String adminRequestChangesButton = 'Request Changes';
  static const String adminRejectButton = 'Reject';
  static const String adminApproveButton = 'Approve Verification';
  static const String adminReviewFooterNote = 'Please verify all documents before making a decision.';
  static const String adminRejectDialogTitle = 'Reject Submission';
  static const String adminRequestChangesDialogTitle = 'Request Changes';
  static const String adminReasonFieldLabel = 'Reason';
  static const String adminReasonRequiredError = 'Please provide a reason.';
  static const String adminSubmissionApproved = 'Submission approved.';
  static const String adminSubmissionRejected = 'Submission rejected.';
  static const String adminChangesRequested = 'Changes requested.';
  static const String adminReviewActionError = 'Failed to update submission. Please try again.';
  // Identity Pending / Hostel Pending currently resolve to the same
  // `pending` filter — this app's verification wizard produces ONE combined
  // submission (identity + hostel info together), so there is no real data
  // distinguishing an "identity-only" pending state from a "hostel-only"
  // one. Documented here rather than fabricating a split the data can't
  // support (same discipline as the Dashboard's "Both" donut slice).

  // Settings
  static const String adminSettingsTitle = 'Settings';
  static const String adminSettingsSubtitle =
      'Update your personal information and security credentials to maintain account safety.';
  static const String adminEditProfileButton = 'Edit Profile';
  static const String adminEditProfileDialogTitle = 'Edit Profile';
  static const String adminSaveButton = 'Save';
  static const String adminFeatureControlsTitle = 'Feature Controls';
  static const String adminAllowNewSignupsTitle = 'Allow New Signups';
  static const String adminAllowNewSignupsSubtitle = 'Enable public registration for students';
  static const String adminWhatsappIntegrationTitle = 'WhatsApp Integration';
  static const String adminWhatsappIntegrationSubtitle = 'Direct chat between owners and students';
  static const String adminAutoApproveOwnersTitle = 'Auto-approve Owners';
  static const String adminAutoApproveOwnersSubtitle = 'Skip verification for premium partners';
  static const String adminMaintenanceModeTitle = 'Maintenance Mode';
  static const String adminMaintenanceModeSubtitle = 'Take all hostel listings offline';
  static const String adminSettingsSaved = 'Settings updated.';
  static const String adminSettingsSaveError = 'Failed to save settings. Please try again.';
  static const String adminProfileUpdated = 'Profile updated.';

  // ── Account / legal (release hardening) ─────────────────────────────
  static const String errorAccountBlocked =
      'Your account has been suspended. Please contact support.';
  static const String errorAccountRemoved =
      'This account is no longer available. Contact support if you think this is a mistake.';
  static const String errorProfileSetupFailed =
      'We could not finish setting up your account. Please try again.';
  static const String privacyPolicyTitle = 'Privacy Policy';
  static const String termsTitle = 'Terms of Service';
  static const String termsAgreePrefix = 'I agree to the ';
  static const String termsAgreeAnd = ' and ';
  static const String deleteAccountTitle = 'Delete Account';
  static const String deleteAccountSubtitle =
      'Permanently delete your account and data';
  static const String deleteAccountConfirmTitle = 'Delete your account?';
  static const String deleteAccountConfirmMessage =
      'This permanently deletes your profile, saved hostels and, for owners, your listings and verification data. This cannot be undone.';
  static const String deleteAccountConfirmButton = 'Delete';
  static const String deleteAccountPasswordTitle = 'Confirm your password';
  static const String deleteAccountPasswordHint = 'Current password';
  static const String deleteAccountSuccess = 'Your account has been deleted.';
  static const String deleteAccountFailed =
      'Could not delete your account. Please try again.';
  static const String deleteAccountRecentLogin =
      'For your security, please log in again and then retry deleting your account.';
  static const String rejectionReasonTitle = 'Message from our review team';
  static const String verificationRejectedNotice =
      'Your verification was not approved.';
  static const String verificationChangesNotice =
      'Changes are needed before we can approve your verification.';
  static const String recentSearchesNone = 'No recent searches yet.';
  static const String locationSettingsTitle = 'Location is off';
  static const String locationSettingsMessage =
      'HostelPin needs location access to show hostels near you. You can turn it on in your device settings.';
  static const String openSettings = 'Open settings';

  // ── Report a listing (Google Play user-generated-content policy) ─────
  static const String reportListing = 'Report this listing';
  static const String reportSheetTitle = 'Why are you reporting this listing?';
  static const List<String> reportReasons = [
    'Fake or misleading listing',
    'Wrong price or details',
    'Inappropriate photos or content',
    'Scam or fraud',
    'Other',
  ];
  static const String reportSubmitted =
      'Thanks. Our team will review this listing.';
  static const String reportAlreadySent =
      'You have already reported this listing.';
  static const String reportFailed =
      'Could not send your report. Please try again.';

  // ── Login redesign ───────────────────────────────────────────────────
  static const String continueWithGoogle = 'Continue with Google';
  static const String loginOrDivider = 'or';
  static const String loginAgreePrefix = 'By logging in, you agree to our ';
  static const String loginAs = 'Log in as';
  static String loginRoleMismatch(String existingRole) =>
      'This email already has an $existingRole account. Log in as $existingRole, or delete that account first if you want to use this email as the other account type.';
  static const String deleteAccountPermissionDenied =
      'Could not delete your account because this app version is not allowed to. Please contact support.';

  // ── Hostel type / Home categories ────────────────────────────────────
  static const String hostelTypeLabel = 'Hostel type';
  static const String hostelGenderBoys = 'Boys';
  static const String hostelGenderGirls = 'Girls';
  static const String categoryAll = 'All';
  static const String errorHostelTypeRequired =
      'Please choose whether this is a Boys or a Girls hostel.';
  static String noHostelsInCategoryTitle(String label) => 'No $label hostels yet';
  static const String noHostelsInCategoryMessage =
      'Check back soon or try another category.';
}

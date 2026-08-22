class AppStrings {
  // App
  static const String appName = 'Hostel Finder';

  // Onboarding
  static const String welcome = 'Welcome!';
  static const String welcomeTo = 'To Hostel Finder App';
  static const String continueButton = 'Continue';

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
  static const String otpSentToPrefix = 'We texted you a code to verify your email address: ';
  static const String otpSentToSuffix = '';
  static const String verifyButton = 'Verify';

  static const String changePasswordTitle = 'Change password';
  static const String newPasswordLabel = 'Type your new password';
  static const String confirmPasswordFieldLabel = 'Confirm password';
  static const String changePasswordButton = 'Change password';

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
  static const String dashboardSubtitle = 'Manage your listings and student inquiries from one place.';
  static const String totalListingLabel = 'Total Listing';
  static const String totalViewsLabel = 'Total Views';
  static const String activeLabel = 'Active';
  static const String trafficLabel = 'Traffic';
  static const String viewListingButton = 'View listing';
  static const String pendingVerificationTitle = 'Pending Verification';
  static String pendingVerificationMessage(String hostelName) => 'Hostel "$hostelName" is currently under review by our team. This usually takes 24 hours.';
  static const String recentActivity = 'Recent Activity';
  static const String genericPropertyName = 'Your property';

  // Owner Listings
  static const String myHostelsSubtitle = 'Manage your campus properties and availability.';
  static const String editButton = 'Edit';
  static const String deleteButton = 'Delete';
  static const String deleteListingTitle = 'Delete Listing';
  static const String deleteListingMessage = 'Are you sure you want to delete this listing? This cannot be undone.';
  static const String expandReachTitle = 'Expand Your Reach';
  static const String expandReachSubtitle = 'Have another property? Add it now to start receiving bookings.';
  static const String addAnotherHostel = 'Add another hostel';
  static const String noListingsTitle = 'No Listings Yet';
  static const String noListingsMessage = 'You have not added any hostels yet.';

  // Owner Add Listing
  static const String listPropertyTitle = 'List Your Property';
  static const String listPropertySubtitle = 'List your hostel to connect with students looking for a place to stay.';
  static const String identityLocationSection = 'Identity & Location';
  static const String hostelNameLabel = 'HOSTEL NAME';
  static const String hostelNameHint = 'e.g: Chandia Hostel';
  static const String fullAddressLabel = 'FULL ADDRESS';
  static const String fullAddressHint = 'e.g: in Qasimabad';
  static const String addPhotosSection = 'Add Photos of your Hostel';
  static const String uploadPicturesLabel = 'Upload pictures';
  static const String uploadPicturesHint = 'click to browse';
  static const String minPhotosNote = '(Minimum 5 photos recommended)';
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
  static const String saveAsDraft = 'Save as Draft';
  static const String publishListing = 'Publish Listing';
  static const String editListingTitle = 'Edit Listing';
  static const String updateListingButton = 'Update Listing';
  static const String listingPublishedTitle = 'Listing Published!';
  static const String listingPublishedBody = 'Your hostel has been successfully published.';

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

  // Owner Add Listing — location picker & publish success
  static const String pickLocationTitle = 'Pick Location';
  static const String confirmLocationButton = 'Confirm Location';
  static const String backToDashboardButton = 'Back to Dashboard';
  static const String tapToPinLocation = 'Tap to pin location';
  static String photosSelectedCount(int count) =>
      '$count/10 photo${count == 1 ? '' : 's'} selected';
  static String locationCoordinatesLabel(double lat, double lng) =>
      'Lat ${lat.toStringAsFixed(4)}, Lng ${lng.toStringAsFixed(4)}';
  static const String unsavedChangesTitle = 'Discard changes?';
  static const String unsavedChangesMessage =
      'You have unsaved changes. Are you sure you want to leave without saving?';
  static const String discardButton = 'Discard';
  static const String priceMonthSuffix = '/mnth';
  static const String errorMinPhotos = 'Please add at least 5 photos.';
  static const String errorMaxPhotos = 'You can add up to 10 photos only.';
  static const String draftSavedMessage = 'Your listing has been saved as a draft.';
  static const String listingDeletedMessage = 'Listing has been deleted.';

  // General & Amenities
  static const String meals = 'Meals';
  static const String carBike = 'Car+Bike';

  // Validation
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

  // Saved
  static const String savedEmptyTitle = 'No saved hostels yet';
  static const String savedEmptyMessage = 'Save hostels while you explore to see them all here in your personal curated list.';
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
  static const String logoutConfirmMessage = 'Are you sure you want to log out?';
  static const String settingsPlaceholder = 'More account settings are coming soon.';
  static const String privacyPlaceholder = 'Privacy controls are coming soon.';
  static const String languageSheetTitle = 'Select Language';

  // Search / Filter
  static const String searchResultsTitle = 'Search Results';
  static const String noResultsTitle = 'No Results Found';
  static const String noResultsMessage = 'We could not find any hostels matching your criteria.';
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
}

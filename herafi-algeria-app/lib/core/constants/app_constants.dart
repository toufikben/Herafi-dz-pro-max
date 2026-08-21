class AppConstants {
  AppConstants._();

  static const String appName = 'حرفي الجزائر';
  static const String appNameEn = 'Herafi Algeria';
  static const String appVersion = '1.0.0';

  // Collections
  static const String usersCollection = 'users';
  static const String craftsmenCollection = 'craftsmen';
  static const String ordersCollection = 'orders';
  static const String categoriesCollection = 'categories';
  static const String reviewsCollection = 'reviews';

  // Shared Preferences Keys
  static const String keyLocale = 'locale';
  static const String keyThemeMode = 'theme_mode';
  static const String keyOnboardingDone = 'onboarding_done';
  static const String keyUserRole = 'user_role';

  // Distance radii in km
  static const List<int> searchRadii = [5, 10, 25, 50];

  // Rating
  static const int maxRating = 5;

  // Phone
  static const String countryCode = '+213';
}

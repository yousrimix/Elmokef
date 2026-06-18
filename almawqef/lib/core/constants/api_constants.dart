class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://localhost:3000/api/v1';
  static const Duration timeout = Duration(seconds: 30);
  static const Duration cacheDuration = Duration(minutes: 5);

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String registerArtisan = '/auth/register/artisan';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String profile = '/auth/profile';

  // Services (Category tree)
  static const String services = '/services';

  // Artisans
  static const String artisans = '/artisans';
  static String artisanProfile(String id) => '/artisans/$id';
  static String artisanReviews(String id) => '/artisans/$id/reviews';
  static String artisanStats(String id) => '/artisans/$id/stats';
  static String artisanRequests(String id) => '/artisans/$id/requests';
  static String artisanProfileUpdate(String id) => '/artisans/$id/profile';
  static String artisanServices(String id) => '/artisans/$id/services';
  static String artisanService(String artisanId, String serviceId) =>
      '/artisans/$artisanId/services/$serviceId';
  static String artisanPortfolio(String id) => '/artisans/$id/portfolio';
  static String artisanPortfolioItem(String artisanId, String mediaId) =>
      '/artisans/$artisanId/portfolio/$mediaId';
  static String artisanCover(String id) => '/artisans/$id/cover';

  // Reviews
  static const String reviews = '/reviews';

  // Favorites
  static const String favorites = '/favorites';

  // Subscriptions
  static const String subscriptions = '/subscriptions';
  static String subscriptionPlans = '$subscriptions/plans';
  static String subscribe = '$subscriptions/subscribe';
  static String cancelSub = '$subscriptions/cancel';
  static String upgradeSub = '$subscriptions/upgrade';
  static String mySubscription = '$subscriptions/my';
  static String adminSubscriptions = '$subscriptions/admin';

  // Notifications
  static const String notifications = '/notifications';
  static const String registerDevice = '/notifications/register-device';
  static const String unregisterDevice = '/notifications/unregister-device';

  // Complaints
  static const String complaints = '/complaints';

  // Upload
  static const String upload = '/upload';

  // Admin
  static const String adminArtisans = '/admin/artisans';
  static String adminVerifyArtisan(String id) => '/admin/artisans/$id/verify';
}

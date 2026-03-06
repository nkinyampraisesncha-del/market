class AppConstants {
  AppConstants._();

  // Supabase
  static const String supabaseUrl = 'https://your-project.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key';

  // App
  static const String appName = 'UniMarket';
  static const String appVersion = '1.0.0';

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'current_user';
  static const String themeKey = 'theme_mode';

  // Hive boxes
  static const String favoritesBox = 'favorites';
  static const String recentlyViewedBox = 'recently_viewed';
  static const String cartBox = 'cart';

  // Pagination
  static const int pageSize = 20;

  // Image limits
  static const int maxImages = 5;
  static const int maxImageSizeMb = 5;

  // Categories
  static const List<String> categories = [
    'Textbooks',
    'Electronics',
    'Clothing',
    'Furniture',
    'Sports',
    'Stationery',
    'Housing',
    'Services',
    'Other',
  ];

  // Conditions
  static const List<String> conditions = [
    'New',
    'Like New',
    'Good',
    'Fair',
    'Poor',
  ];

  // Order statuses
  static const String orderPending = 'pending';
  static const String orderConfirmed = 'confirmed';
  static const String orderShipped = 'shipped';
  static const String orderDelivered = 'delivered';
  static const String orderCancelled = 'cancelled';
  static const String orderDisputed = 'disputed';

  // Payment statuses
  static const String paymentPending = 'pending';
  static const String paymentCompleted = 'completed';
  static const String paymentFailed = 'failed';
  static const String paymentRefunded = 'refunded';

  // User roles
  static const String roleBuyer = 'buyer';
  static const String roleSeller = 'seller';
  static const String roleAdmin = 'admin';

  // Listing statuses
  static const String listingActive = 'active';
  static const String listingInactive = 'inactive';
  static const String listingPendingApproval = 'pending_approval';
  static const String listingSold = 'sold';
}

/// PWA Configuration for ReClaim E-Commerce
/// 
/// Handles offline caching, background sync, and PWA-specific settings
class PWAConfig {
  /// Whether the app is running in production mode
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
  
  /// App version for cache busting
  static const String version = '1.0.0';
  
  /// Cache configuration
  static const Duration cacheValidDuration = Duration(hours: 24);
  static const int maxCacheSize = 50 * 1024 * 1024; // 50MB
  
  /// Background sync settings
  static const Duration syncInterval = Duration(minutes: 15);
  static const String syncTaskName = 'reclaim-background-sync';
  
  /// Offline mode settings
  static const int maxOfflineCartItems = 100;
  static const Duration offlineDataRetention = Duration(days: 7);
  
  /// API cache keys
  static const String productCacheKey = 'products_cache';
  static const String cartCacheKey = 'cart_cache';
  static const String ordersCacheKey = 'orders_cache';
  static const String userProfileCacheKey = 'profile_cache';
  
  /// Network timeout settings
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration downloadTimeout = Duration(minutes: 2);
  
  /// Image optimization
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1920;
  static const int thumbnailSize = 400;
  static const int imageQuality = 85; // 0-100
  
  /// PWA features
  static const bool enablePushNotifications = true;
  static const bool enableBackgroundSync = true;
  static const bool enableOfflineMode = true;
  
  /// Storage limits
  static const int maxCartItemQuantity = 50;
  static const int maxImagesPerProduct = 10;
  
  /// Analytics
  static const bool enableAnalytics = isProduction;
  static const String analyticsId = 'G-XXXXXXXXXX'; // Replace with actual GA4 ID
}

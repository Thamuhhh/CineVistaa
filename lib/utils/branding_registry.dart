class BrandingRegistry {
  /// 🎬 THE UNIVERSAL BRANDING REGISTRY: 
  /// A curated map of TMDB IDs to high-quality external PNG logos Found via AI Search.
  /// This ensures that even for classics where TMDB lacks assets, 
  /// CineVistaa provides a Premium, Logo-First experience. 🍿✨🇮🇳📽️🚀🌍
  static final Map<int, String> _overrides = {
    // 🎭 Youth (2002) - Vijay Classic
    86603: 'https://www.freeiconspng.com/uploads/youth-tamil-movie-logo-png-1.png',
    
    // 🎭 Vikram (2022) - Kamal Haasan (Official exists but this is a backup)
    // 82700: 'https://fanart.tv/fanart/movies/82700/hdmovielogo/vikram-62a2bb7f5a2e5.png',
  };

  /// Returns the curated logo URL if it exists, otherwise null
  static String? getReservedLogo(int movieId) {
    return _overrides[movieId];
  }
}

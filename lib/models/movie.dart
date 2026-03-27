class Movie {
  final String id;
  final String title;
  final String originalTitle;
  final String posterUrl;
  final String backdropUrl;
  final String? logoUrl; // PNG Official Logo Branding
  final String overview;
  final double rating;
  final String releaseDate;
  final String trailerId; // YouTube Video ID
  final List<String> categories;
  final List<String> watchProviders; // "Netflix", "Hulu", etc.

  Movie({
    required this.id,
    required this.title,
    required this.originalTitle,
    required this.posterUrl,
    required this.backdropUrl,
    this.logoUrl,
    required this.overview,
    required this.rating,
    required this.releaseDate,
    required this.trailerId,
    this.categories = const [],
    this.watchProviders = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'originalTitle': originalTitle,
      'overview': overview,
      'rating': rating,
      'releaseDate': releaseDate,
      'posterUrl': posterUrl,
      'backdropUrl': backdropUrl,
      'logoUrl': logoUrl,
      'trailerId': trailerId,
      'categories': categories,
      'watchProviders': watchProviders,
    };
  }

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      originalTitle: json['originalTitle'] ?? json['title'] ?? '',
      overview: json['overview'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      releaseDate: json['releaseDate'] ?? '',
      posterUrl: json['posterUrl'] ?? '',
      backdropUrl: json['backdropUrl'] ?? '',
      logoUrl: json['logoUrl'],
      trailerId: json['trailerId'] ?? '',
      categories: List<String>.from(json['categories'] ?? []),
      watchProviders: List<String>.from(json['watchProviders'] ?? []),
    );
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../models/movie.dart';

class LogoGenerationService {
  LogoGenerationService._();

  static const String _apiKey = String.fromEnvironment('OPENAI_API_KEY');
  static const String _model = String.fromEnvironment(
    'OPENAI_IMAGE_MODEL',
    defaultValue: 'gpt-image-1.5',
  );
  static const String _endpoint = 'https://api.openai.com/v1/images/edits';
  static const String _cacheVersion = 'v1';

  static final Map<String, Future<File?>> _inflightRequests = {};
  static final Set<String> _failedMovieIds = <String>{};

  static bool get isConfigured => _apiKey.trim().isNotEmpty;

  static Future<File?> getOrGenerateLogo(Movie movie) {
    final movieId = movie.id.trim();
    if (movieId.isEmpty || !isConfigured || _failedMovieIds.contains(movieId)) {
      return Future.value(null);
    }

    return _inflightRequests.putIfAbsent(
      movieId,
      () async {
        try {
          final cachedFile = await _getCachedLogoFile(movieId);
          if (await cachedFile.exists()) {
            return cachedFile;
          }

          final generatedBytes = await _generateLogoBytes(movie);
          if (generatedBytes == null || generatedBytes.isEmpty) {
            _failedMovieIds.add(movieId);
            return null;
          }

          await cachedFile.parent.create(recursive: true);
          await cachedFile.writeAsBytes(generatedBytes, flush: true);
          return cachedFile;
        } catch (_) {
          _failedMovieIds.add(movieId);
          return null;
        } finally {
          _inflightRequests.remove(movieId);
        }
      },
    );
  }

  static Future<File> _getCachedLogoFile(String movieId) async {
    final directory = await getApplicationDocumentsDirectory();
    return File(
      '${directory.path}${Platform.pathSeparator}generated_logos${Platform.pathSeparator}logo_${_cacheVersion}_$movieId.png',
    );
  }

  static Future<List<int>?> _generateLogoBytes(Movie movie) async {
    final posterUrl = _upgradeTmdbImage(movie.posterUrl);
    final backdropUrl = _upgradeTmdbImage(movie.backdropUrl);

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $_apiKey',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode({
        'model': _model,
        'images': [
          {'image_url': posterUrl},
          {'image_url': backdropUrl},
        ],
        'prompt': _buildPrompt(movie),
        'background': 'transparent',
        'quality': 'medium',
        'size': '1536x1024',
        'output_format': 'png',
        'input_fidelity': 'high',
        'n': 1,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return null;
    }

    final Map<String, dynamic> payload = jsonDecode(response.body);
    final List<dynamic> data = payload['data'] ?? const [];
    if (data.isEmpty) return null;

    final String? base64Image = data.first['b64_json'];
    if (base64Image == null || base64Image.isEmpty) {
      return null;
    }

    return base64Decode(base64Image);
  }

  static String _upgradeTmdbImage(String imageUrl) {
    return imageUrl.replaceFirst('/w500', '/original');
  }

  static String _buildPrompt(Movie movie) {
    final title = movie.title.trim();
    final originalTitle = movie.originalTitle.trim();
    final displayTitle = originalTitle.isNotEmpty &&
            originalTitle.toLowerCase() != title.toLowerCase()
        ? '$title / $originalTitle'
        : title;

    return [
      'Using the reference movie artwork, create a transparent PNG containing only the official movie title logo or wordmark for "$displayTitle".',
      'Preserve the authentic lettering style from the references when visible.',
      'Output only the logo on a transparent background.',
      'Do not include actors, faces, posters, borders, backgrounds, release labels, watermarks, badges, streaming logos, or extra text.',
      'Keep the result wide, centered, crisp, and readable for a hero banner.',
    ].join(' ');
  }
}

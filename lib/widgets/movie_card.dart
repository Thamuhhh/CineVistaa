import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../models/movie.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;

  const MovieCard({Key? key, required this.movie}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Hero(
              tag: 'poster_${movie.id}',
              child: CachedNetworkImage(
                imageUrl: movie.posterUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey.shade900,
                  highlightColor: Colors.grey.shade800,
                  child: Container(color: Colors.black),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade900,
                  child: const Icon(Icons.error_outline),
                ),
              ),
            ),
          ),
        ),
        // Premium Rating Badge Overlay
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.5), width: 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Color(0xFFFFD700), size: 10),
                const SizedBox(width: 2),
                Text(
                  movie.rating.toStringAsFixed(1),
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../widgets/movie_card.dart';
import 'movie_details_screen.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Space', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<MovieProvider>(
        builder: (context, provider, child) {
          if (provider.watchlist.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, size: 80, color: Colors.grey.shade800),
                  const SizedBox(height: 16),
                  Text(
                    'Your watchlist is empty',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 18),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // Premium app 3-column density
              childAspectRatio: 0.65,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: provider.watchlist.length,
            itemBuilder: (context, index) {
              final movie = provider.watchlist[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MovieDetailsScreen(movie: movie),
                    ),
                  );
                },
                child: MovieCard(movie: movie),
              );
            },
          );
        },
      ),
    );
  }
}

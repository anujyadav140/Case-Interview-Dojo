import 'package:flutter/material.dart';

class Movie {
  final String title;
  final String overview;
  final String posterPath;
  final double rating;

  Movie({
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.rating,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['title'] ?? 'Untitled',
      overview: json['overview'] ?? 'No overview available.',
      posterPath: json['poster_path'] ?? '',
      rating: (json['vote_average'] as num).toDouble(),
    );
  }
}

class SearchContent extends StatelessWidget {
  final int index;
  final Movie movie;
  final double? width;
  final double? height;
  final bool fill;

  const SearchContent({
    super.key,
    required this.index,
    required this.movie,
    this.width,
    this.height,
    this.fill = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: width,
      height: height ?? 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: fill
            ? Colors.primaries[
                (Colors.primaries.length - 1 - index) % Colors.primaries.length]
            : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              'https://image.tmdb.org/t/p/w500${movie.posterPath}',
              width: 100,
              height: 150,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Movie: ${movie.title}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Rating: ${movie.rating.toStringAsFixed(1)}/10',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Summary:\n${movie.overview}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

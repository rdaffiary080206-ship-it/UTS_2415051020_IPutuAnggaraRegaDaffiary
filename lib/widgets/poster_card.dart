import 'package:flutter/material.dart';

import '../utils/app_theme.dart';
import 'network_poster.dart';
import 'rating_badge.dart';

/// Kartu poster film/series: poster, badge rating & tahun, serta judul.
class PosterCard extends StatelessWidget {
  const PosterCard({
    super.key,
    required this.title,
    required this.imageUrl,
    this.rating,
    this.year,
    this.isSaved = false,
    this.onTap,
  });

  final String title;
  final String? imageUrl;
  final double? rating;
  final String? year;
  final bool isSaved;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(child: NetworkPoster(imageUrl: imageUrl)),
                Positioned(
                  top: 6,
                  left: 6,
                  child: RatingBadge(rating: rating, compact: true),
                ),
                if (year != null)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        year!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (isSaved)
                  const Positioned(
                    bottom: 6,
                    right: 6,
                    child: CircleAvatar(
                      radius: 13,
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.bookmark, size: 15, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

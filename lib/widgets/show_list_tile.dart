import 'package:flutter/material.dart';

import '../models/show.dart';
import '../utils/app_theme.dart';
import 'network_poster.dart';
import 'rating_badge.dart';

/// Baris show untuk mode tampilan daftar (list) di Eksplor.
class ShowListTile extends StatelessWidget {
  const ShowListTile({
    super.key,
    required this.show,
    this.isSaved = false,
    this.onTap,
  });

  final Show show;
  final bool isSaved;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final meta = [
      if (show.year != null) show.year!,
      if (show.network != null) show.network!,
      if (show.runtime != null) '${show.runtime} mnt',
    ].join(' • ');
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 70,
                height: 100,
                child: NetworkPoster(imageUrl: show.posterUrl, borderRadius: 8),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            show.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        if (isSaved)
                          const Icon(Icons.bookmark,
                              color: AppColors.primary, size: 18),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (meta.isNotEmpty)
                      Text(meta,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        RatingBadge(rating: show.rating, compact: true),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            show.genres.join(', '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      show.plainSummary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

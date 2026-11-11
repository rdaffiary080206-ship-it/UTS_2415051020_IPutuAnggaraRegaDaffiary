import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/show.dart';
import '../providers/watchlist_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/network_poster.dart';
import '../widgets/rating_badge.dart';

/// Detail film/series. Menerima objek [Show] dari screen sebelumnya.
class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.show});

  final Show show;

  @override
  Widget build(BuildContext context) {
    final watchlist = context.watch<WatchlistProvider>();
    final saved = watchlist.isSaved(show.id);
    return Scaffold(
      appBar: AppBar(title: Text(show.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SizedBox(height: 300, child: NetworkPoster(imageUrl: show.backdropUrl)),
          const SizedBox(height: 16),
          Text(
            show.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              RatingBadge(rating: show.rating),
              const SizedBox(width: 8),
              Text(
                show.year ?? '-',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (saved)
            const Chip(
              avatar: Icon(Icons.bookmark, color: AppColors.primary),
              label: Text('Tersimpan di Watchlist'),
            ),
          const SizedBox(height: 16),
          Text(show.plainSummary),
        ],
      ),
    );
  }
}

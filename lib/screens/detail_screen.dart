import 'package:flutter/material.dart';

import '../utils/app_theme.dart';
import '../widgets/network_poster.dart';
import '../widgets/rating_badge.dart';

/// Detail film/series. Menerima data dari screen sebelumnya.
class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.show});

  final Map<String, dynamic> show;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(show['title'] as String)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(
            height: 300,
            child: NetworkPoster(imageUrl: null),
          ),
          const SizedBox(height: 16),
          Text(
            show['title'] as String,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              RatingBadge(rating: show['rating'] as double),
              const SizedBox(width: 8),
              Text(
                show['year'] as String,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

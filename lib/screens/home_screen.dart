import 'package:flutter/material.dart';

import '../utils/app_theme.dart';
import '../utils/dummy_data.dart';
import '../widgets/poster_card.dart';
import '../widgets/section_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CINEMAY',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ),
      body: ListView(
        children: [
          Container(
            height: 220,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: const Text('Featured Banner'),
          ),
          const SectionHeader(title: 'Sedang Trending'),
          SizedBox(
            height: 210,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: dummyShows.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final show = dummyShows[index];
                return SizedBox(
                  width: 130,
                  child: PosterCard(
                    title: show['title'] as String,
                    imageUrl: null,
                    rating: show['rating'] as double,
                    year: show['year'] as String,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../utils/app_theme.dart';
import '../utils/dummy_data.dart';
import '../utils/responsive.dart';
import '../widgets/poster_card.dart';
import '../widgets/section_header.dart';
import 'detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onSeeAll});

  /// Dipanggil saat "Lihat Semua" ditekan (pindah ke tab Eksplor).
  final VoidCallback? onSeeAll;

  void _openDetail(BuildContext context, Map<String, dynamic> show) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DetailScreen(show: show)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemWidth = Responsive.carouselItemWidth(context);
    final isCompact = Responsive.isCompact(context);
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
            height: isCompact ? 220 : 320,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: const Text('Featured Banner'),
          ),
          SectionHeader(
            title: 'Sedang Trending',
            actionLabel: 'Lihat Semua',
            onAction: onSeeAll,
          ),
          SizedBox(
            height: itemWidth * 1.6,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: dummyShows.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final show = dummyShows[index];
                return SizedBox(
                  width: itemWidth,
                  child: PosterCard(
                    title: show['title'] as String,
                    imageUrl: null,
                    rating: show['rating'] as double,
                    year: show['year'] as String,
                    onTap: () => _openDetail(context, show),
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

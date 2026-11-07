import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/show.dart';
import '../providers/watchlist_provider.dart';
import '../utils/responsive.dart';
import 'poster_card.dart';

/// Baris poster horizontal (carousel) gaya layanan streaming.
class ShowCarousel extends StatelessWidget {
  const ShowCarousel({super.key, required this.shows, required this.onTap});

  final List<Show> shows;
  final ValueChanged<Show> onTap;

  @override
  Widget build(BuildContext context) {
    final itemWidth = Responsive.carouselItemWidth(context);
    final watchlist = context.watch<WatchlistProvider>();
    return SizedBox(
      height: itemWidth * 1.6,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: shows.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final show = shows[index];
          return SizedBox(
            width: itemWidth,
            child: PosterCard(
              title: show.name,
              imageUrl: show.posterUrl,
              rating: show.rating,
              year: show.year,
              isSaved: watchlist.isSaved(show.id),
              onTap: () => onTap(show),
            ),
          );
        },
      ),
    );
  }
}

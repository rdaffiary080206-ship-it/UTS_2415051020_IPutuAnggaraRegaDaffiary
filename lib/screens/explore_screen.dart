import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/show_provider.dart';
import '../providers/watchlist_provider.dart';
import '../utils/responsive.dart';
import '../widgets/poster_card.dart';
import 'detail_screen.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShowProvider>();
    final watchlist = context.watch<WatchlistProvider>();
    final shows = provider.shows;
    return Scaffold(
      appBar: AppBar(title: const Text('Eksplor')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.errorMessage != null
          ? Center(child: Text(provider.errorMessage!))
          : LayoutBuilder(
              builder: (context, constraints) {
                final columns = Responsive.gridColumns(constraints.maxWidth);
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.6,
                  ),
                  itemCount: shows.length,
                  itemBuilder: (context, index) {
                    final show = shows[index];
                    return PosterCard(
                      title: show.name,
                      imageUrl: show.posterUrl,
                      rating: show.rating,
                      year: show.year,
                      isSaved: watchlist.isSaved(show.id),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DetailScreen(show: show),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

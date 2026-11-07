import 'package:flutter/material.dart';

import '../utils/dummy_data.dart';
import '../utils/responsive.dart';
import '../widgets/poster_card.dart';
import 'detail_screen.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Eksplor')),
      body: LayoutBuilder(
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
            itemCount: dummyShows.length,
            itemBuilder: (context, index) {
              final show = dummyShows[index];
              return PosterCard(
                title: show['title'] as String,
                imageUrl: null,
                rating: show['rating'] as double,
                year: show['year'] as String,
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

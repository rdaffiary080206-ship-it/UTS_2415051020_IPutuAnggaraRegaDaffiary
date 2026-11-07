import 'package:flutter/material.dart';

import '../utils/dummy_data.dart';
import '../widgets/poster_card.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Eksplor')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
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
          );
        },
      ),
    );
  }
}

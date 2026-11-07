import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/watchlist_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/network_poster.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = context.watch<WatchlistProvider>().items;
    return Scaffold(
      appBar: AppBar(title: const Text('Watchlist Saya')),
      body: items.isEmpty
          ? const Center(
              child: Text(
                'Watchlist masih kosong',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  child: ListTile(
                    leading: SizedBox(
                      width: 44,
                      child: NetworkPoster(
                          imageUrl: item.posterUrl, borderRadius: 6),
                    ),
                    title: Text(item.title),
                    subtitle: Text(item.status.label),
                  ),
                );
              },
            ),
    );
  }
}

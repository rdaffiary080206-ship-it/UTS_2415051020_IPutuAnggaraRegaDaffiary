import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/watchlist_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/network_poster.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WatchlistProvider>();
    final items = provider.items;

    Widget body;
    if (provider.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (provider.errorMessage != null) {
      body = Center(child: Text(provider.errorMessage!));
    } else if (items.isEmpty) {
      body = const Center(
        child: Text(
          'Watchlist masih kosong',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    } else {
      body = RefreshIndicator(
        onRefresh: provider.loadItems,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              child: ListTile(
                leading: SizedBox(
                  width: 44,
                  child:
                      NetworkPoster(imageUrl: item.posterUrl, borderRadius: 6),
                ),
                title: Text(item.title),
                subtitle: Text(item.status.label),
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Watchlist Saya'),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: provider.isLoading ? null : provider.loadItems,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: body,
    );
  }
}

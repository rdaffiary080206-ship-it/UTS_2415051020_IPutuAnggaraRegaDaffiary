import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/watchlist_item.dart';
import '../providers/watchlist_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/delete_watchlist_action.dart';
import '../widgets/watchlist_tile.dart';
import 'add_watchlist_screen.dart';
import 'edit_watchlist_screen.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  void _openEdit(BuildContext context, WatchlistItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EditWatchlistScreen(item: item)),
    );
  }

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
            return WatchlistTile(
              item: item,
              onTap: () => _openEdit(context, item),
              onEdit: () => _openEdit(context, item),
              onDelete: () => confirmAndDeleteWatchlistItem(context, item),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddWatchlistScreen()),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }
}

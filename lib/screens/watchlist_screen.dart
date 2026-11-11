import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/watch_status.dart';
import '../models/watchlist_item.dart';
import '../providers/watchlist_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/state_views.dart';
import '../widgets/watchlist_actions.dart';
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
    final items = provider.filteredItems;

    Widget body;
    if (provider.isLoading) {
      body = const LoadingStateView(message: 'Memuat watchlist dari database...');
    } else if (provider.errorMessage != null) {
      body = ErrorStateView(
        title: 'Gagal Memuat Watchlist',
        message: provider.errorMessage!,
        onRetry: provider.loadItems,
      );
    } else if (items.isEmpty) {
      body = EmptyStateView(
        icon: Icons.bookmark_border_rounded,
        title: provider.count == 0
            ? 'Watchlist Masih Kosong'
            : 'Tidak Ada Judul pada Status Ini',
        subtitle: provider.count == 0
            ? 'Tambahkan film atau series favoritmu dari Beranda/Eksplor atau lewat tombol Tambah.'
            : 'Coba pilih filter status tontonan lainnya.',
        actionLabel: provider.count == 0 ? 'Tambah Manual' : 'Tampilkan Semua',
        onAction: provider.count == 0
            ? () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddWatchlistScreen()),
                )
            : () => provider.setStatusFilter(null),
      );
    } else {
      body = RefreshIndicator(
        onRefresh: provider.loadItems,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Dismissible(
              key: ValueKey('watchlist-${item.id}'),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24),
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (_) =>
                  confirmAndDeleteWatchlistItem(context, item),
              child: WatchlistTile(
                item: item,
                onTap: () => _openEdit(context, item),
                onEdit: () => _openEdit(context, item),
                onDelete: () => confirmAndDeleteWatchlistItem(context, item),
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Watchlist Saya (${provider.count})'),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: provider.isLoading ? null : provider.loadItems,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              children: [
                _StatusChip(
                  label: 'Semua (${provider.count})',
                  selected: provider.statusFilter == null,
                  onTap: () => provider.setStatusFilter(null),
                ),
                for (final status in WatchStatus.values)
                  _StatusChip(
                    label:
                        '${status.label} (${provider.countByStatus(status)})',
                    selected: provider.statusFilter == status,
                    onTap: () => provider.setStatusFilter(status),
                  ),
              ],
            ),
          ),
          Expanded(child: body),
        ],
      ),
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        selectedColor: AppColors.primary,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

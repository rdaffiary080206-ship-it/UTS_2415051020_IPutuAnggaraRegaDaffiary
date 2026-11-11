import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/show.dart';
import '../models/watchlist_item.dart';
import '../providers/watchlist_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/network_poster.dart';
import '../widgets/rating_badge.dart';
import '../widgets/watchlist_actions.dart';
import '../widgets/watchlist_tile.dart';
import 'add_watchlist_screen.dart';
import 'edit_watchlist_screen.dart';

/// Detail film/series dengan tampilan sederhana & bersih.
class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.show});

  final Show show;

  @override
  Widget build(BuildContext context) {
    final watchlist = context.watch<WatchlistProvider>();
    final savedItem = watchlist.findByShowId(show.id);
    final saved = savedItem != null;

    return Scaffold(
      appBar: AppBar(title: Text(show.name)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SizedBox(
                height: 300,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    NetworkPoster(imageUrl: show.backdropUrl, borderRadius: 14),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.85),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            show.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              RatingBadge(rating: show.rating),
                              if (show.year != null) _MetaText(show.year!),
                              if (show.runtime != null)
                                _MetaText('${show.runtime} mnt'),
                              if (show.network != null)
                                _MetaText(show.network!),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (show.genres.isNotEmpty) ...[
                Text(
                  show.genres.join(' • '),
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),
              ],

              // Tombol aksi sederhana (1 tombol utama jika belum disimpan)
              if (saved)
                _SavedWatchlistCard(item: savedItem)
              else
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AddWatchlistScreen(show: show),
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah ke Watchlist'),
                  ),
                ),

              const SizedBox(height: 20),
              const Text(
                'Sinopsis',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                show.plainSummary,
                style: const TextStyle(height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaText extends StatelessWidget {
  const _MetaText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      '• $text',
      style: const TextStyle(fontSize: 13, color: Colors.white70),
    );
  }
}

class _SavedWatchlistCard extends StatelessWidget {
  const _SavedWatchlistCard({required this.item});
  final WatchlistItem item;

  @override
  Widget build(BuildContext context) {
    final color = WatchlistTile.statusColor(item.status);
    final stars = item.personalRating == null
        ? 0
        : (item.personalRating! / 2).round().clamp(1, 5);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.status.label,
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
              ),
              if (stars > 0)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 1; i <= 5; i++)
                      Icon(
                        i <= stars
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: AppColors.gold,
                        size: 16,
                      ),
                  ],
                ),
            ],
          ),
          if (item.progress.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Progress menonton: ${item.progress}',
              style: const TextStyle(fontSize: 13),
            ),
          ],
          if (item.note.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              item.note,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EditWatchlistScreen(item: item),
                  ),
                ),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => confirmAndDeleteWatchlistItem(context, item),
                icon: const Icon(Icons.delete_outline,
                    size: 16, color: AppColors.primary),
                label: const Text(
                  'Hapus',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

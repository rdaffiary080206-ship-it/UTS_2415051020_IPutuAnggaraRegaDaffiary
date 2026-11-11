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

/// Detail film/series. Menerima objek [Show] dari screen sebelumnya.
class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.show});

  final Show show;

  @override
  Widget build(BuildContext context) {
    final watchlist = context.watch<WatchlistProvider>();
    final savedItem = watchlist.findByShowId(show.id);
    final saved = savedItem != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(show.name),
        actions: [
          IconButton(
            tooltip: saved ? 'Hapus dari Watchlist' : 'Simpan Cepat',
            onPressed: () => quickToggleWatchlist(context, show),
            icon: Icon(
              saved ? Icons.bookmark : Icons.bookmark_border,
              color: saved ? AppColors.primary : null,
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SizedBox(
                height: 320,
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
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              RatingBadge(rating: show.rating),
                              if (show.year != null) _MetaBadge(show.year!),
                              if (show.runtime != null)
                                _MetaBadge('${show.runtime} mnt'),
                              if (show.network != null)
                                _MetaBadge(show.network!),
                              if (show.status != null) _MetaBadge(show.status!),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (show.genres.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final g in show.genres)
                      Chip(
                        label: Text(g),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              if (saved)
                _SavedReviewCard(item: savedItem)
              else
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddWatchlistScreen(show: show),
                        ),
                      ),
                      icon: const Icon(Icons.rate_review_outlined),
                      label: const Text('Simpan + Catatan & Rating'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => quickToggleWatchlist(context, show),
                      icon: const Icon(Icons.add),
                      label: const Text('Daftar Saya (Cepat)'),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              const Text(
                'Sinopsis',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                show.plainSummary,
                style: const TextStyle(height: 1.5),
              ),
              const SizedBox(height: 20),
              _InfoSection(show: show),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaBadge extends StatelessWidget {
  const _MetaBadge(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
    );
  }
}

class _SavedReviewCard extends StatelessWidget {
  const _SavedReviewCard({required this.item});
  final WatchlistItem item;

  @override
  Widget build(BuildContext context) {
    final color = WatchlistTile.statusColor(item.status);
    return Card(
      color: AppColors.surfaceLight,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(item.status.icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Status di Watchlist: ${item.status.label}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                if (item.personalRating != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppColors.gold, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${item.personalRating!.toStringAsFixed(1)}/10',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
              ],
            ),
            if (item.progress.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('Progres terakhir: ${item.progress}'),
            ],
            if (item.note.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                '"${item.note}"',
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EditWatchlistScreen(item: item),
                    ),
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit Catatan / Progres'),
                ),
                TextButton.icon(
                  onPressed: () => confirmAndDeleteWatchlistItem(context, item),
                  icon: const Icon(Icons.delete_outline,
                      size: 18, color: AppColors.primary),
                  label: const Text(
                    'Hapus',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.show});
  final Show show;

  @override
  Widget build(BuildContext context) {
    final schedule = [
      if (show.scheduleDays.isNotEmpty) show.scheduleDays.join(', '),
      if (show.scheduleTime != null && show.scheduleTime!.isNotEmpty)
        show.scheduleTime!,
    ].join(' • ');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Tayangan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            _row('Bahasa', show.language ?? '-'),
            _row('Platform / Network', show.network ?? '-'),
            _row('Status', show.status ?? '-'),
            _row('Jadwal Tayang', schedule.isEmpty ? '-' : schedule),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(color: AppColors.textSecondary)),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

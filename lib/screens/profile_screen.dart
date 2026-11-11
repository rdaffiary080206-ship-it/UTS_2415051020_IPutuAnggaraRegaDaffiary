import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/watch_status.dart';
import '../models/watchlist_item.dart';
import '../providers/watchlist_provider.dart';
import '../utils/app_constants.dart';
import '../utils/app_theme.dart';
import '../widgets/network_poster.dart';
import 'edit_watchlist_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _topGenres(List<WatchlistItem> items) {
    final counts = <String, int>{};
    for (final item in items) {
      for (final raw in item.genres.split(',')) {
        final g = raw.trim();
        if (g.isNotEmpty) counts[g] = (counts[g] ?? 0) + 1;
      }
    }
    if (counts.isEmpty) return 'Belum ada';
    final sorted = counts.keys.toList()
      ..sort((a, b) => counts[b]!.compareTo(counts[a]!));
    return sorted.take(3).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final watchlist = context.watch<WatchlistProvider>();
    final favorites = watchlist.items
        .where((i) => i.status == WatchStatus.favorite)
        .toList();
    final showcase = favorites.isNotEmpty ? favorites : watchlist.items;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 8),
              const Center(
                child: CircleAvatar(
                  radius: 46,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                AppConstants.studentName,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                '${AppConstants.studentNim} • ${AppConstants.studentClass}',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 22),

              // Baris ringkas aktivitas tontonan
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _InlineCounter(
                      count: watchlist.countByStatus(WatchStatus.favorite),
                      label: 'Favorite',
                    ),
                    _divider(),
                    _InlineCounter(
                      count: watchlist.count,
                      label: 'Watchlist',
                    ),
                    _divider(),
                    _InlineCounter(
                      count: watchlist.countByStatus(WatchStatus.watching),
                      label: 'Ditonton',
                    ),
                    _divider(),
                    _InlineCounter(
                      count: watchlist.countByStatus(WatchStatus.completed),
                      label: 'Selesai',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Koleksi Favorite / Watchlist Terbaru
              Text(
                favorites.isNotEmpty ? 'Favorite Saya' : 'Baru Disimpan',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (showcase.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Belum ada tayangan yang disimpan. Pilih film di Beranda atau Eksplor untuk mulai menyusun daftar tontonanmu.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 165,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: showcase.take(8).length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final item = showcase[index];
                      return InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => EditWatchlistScreen(item: item),
                          ),
                        ),
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 105,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: NetworkPoster(
                                  imageUrl: item.posterUrl,
                                  borderRadius: 8,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 24),
              const Text(
                'Preferensi & Tentang',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.local_movies_outlined,
                          color: AppColors.textSecondary),
                      title: const Text('Genre Favorit',
                          style: TextStyle(fontSize: 14)),
                      trailing: Text(
                        _topGenres(watchlist.items),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.surfaceLight),
                    ListTile(
                      leading: const Icon(Icons.star_outline_rounded,
                          color: AppColors.textSecondary),
                      title: const Text('Rata-rata Rating Kamu',
                          style: TextStyle(fontSize: 14)),
                      trailing: Text(
                        watchlist.averageRating == null
                            ? 'Belum ada'
                            : '${(watchlist.averageRating! / 2).toStringAsFixed(1)} / 5 ★',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.surfaceLight),
                    const ListTile(
                      leading: Icon(Icons.info_outline,
                          color: AppColors.textSecondary),
                      title:
                          Text('Versi Aplikasi', style: TextStyle(fontSize: 14)),
                      trailing: Text(
                        'Cinemay v1.0.0',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 30, color: AppColors.surfaceLight);
  }
}

class _InlineCounter extends StatelessWidget {
  const _InlineCounter({required this.count, required this.label});

  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$count',
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

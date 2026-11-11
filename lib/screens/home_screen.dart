import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/show.dart';
import '../providers/show_provider.dart';
import '../providers/watchlist_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/featured_banner.dart';
import '../widgets/section_header.dart';
import '../widgets/show_carousel.dart';
import '../widgets/state_views.dart';
import '../widgets/watchlist_actions.dart';
import 'detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onSeeAll});

  /// Dipanggil saat "Lihat Semua" ditekan (pindah ke tab Eksplor).
  final VoidCallback? onSeeAll;

  void _openDetail(BuildContext context, Show show) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DetailScreen(show: show)),
    );
  }

  /// Fitur kreatif "Kejutkan Saya": memilih satu tayangan secara acak
  /// dari katalog dan menampilkannya dalam dialog rekomendasi cepat.
  void _surpriseMe(BuildContext context, List<Show> shows) {
    if (shows.isEmpty) return;
    final pick = shows[Random().nextInt(shows.length)];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.casino_rounded, color: AppColors.gold),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Rekomendasi Acak Hari Ini',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              pick.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              [
                if (pick.year != null) pick.year!,
                if (pick.rating != null) '★ ${pick.rating!.toStringAsFixed(1)}',
                if (pick.genres.isNotEmpty) pick.genres.join(', '),
              ].join(' • '),
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 10),
            Text(
              pick.plainSummary,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      _surpriseMe(context, shows);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Acak Lagi'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      _openDetail(context, pick);
                    },
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Lihat Detail'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShowProvider>();
    final watchlist = context.watch<WatchlistProvider>();
    final featured = provider.featured;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CINEMAY',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        actions: [
          if (provider.shows.isNotEmpty)
            IconButton(
              tooltip: 'Kejutkan Saya (Pilih Acak)',
              onPressed: () => _surpriseMe(context, provider.shows),
              icon: const Icon(Icons.casino_outlined, color: AppColors.gold),
            ),
          if (onSeeAll != null)
            IconButton(
              tooltip: 'Cari di Katalog',
              onPressed: onSeeAll,
              icon: const Icon(Icons.search),
            ),
        ],
      ),
      body: provider.isLoading
          ? const LoadingStateView(message: 'Memuat katalog film & series...')
          : provider.errorMessage != null
          ? ErrorStateView(
              title: 'Gagal Memuat Katalog',
              message: provider.errorMessage!,
              onRetry: provider.loadShows,
            )
          : provider.shows.isEmpty
          ? EmptyStateView(
              title: 'Katalog Kosong',
              subtitle: 'Belum ada tayangan yang tersedia saat ini.',
              actionLabel: 'Muat Ulang',
              onAction: provider.loadShows,
            )
          : RefreshIndicator(
              onRefresh: provider.loadShows,
              child: ListView(
                children: [
                  if (featured != null)
                    FeaturedBanner(
                      show: featured,
                      isSaved: watchlist.isSaved(featured.id),
                      onDetail: () => _openDetail(context, featured),
                      onQuickToggle: () =>
                          quickToggleWatchlist(context, featured),
                      onSurpriseMe: () => _surpriseMe(context, provider.shows),
                    ),
                  SectionHeader(
                    title: 'Sedang Trending',
                    actionLabel: 'Lihat Semua',
                    onAction: onSeeAll,
                  ),
                  ShowCarousel(
                    shows: provider.trending,
                    onTap: (s) => _openDetail(context, s),
                  ),
                  const SectionHeader(title: 'Rating Tertinggi'),
                  ShowCarousel(
                    shows: provider.topRated,
                    onTap: (s) => _openDetail(context, s),
                  ),
                  if (provider.byGenre('Science-Fiction').isNotEmpty) ...[
                    const SectionHeader(title: 'Sci-Fi Pilihan'),
                    ShowCarousel(
                      shows: provider.byGenre('Science-Fiction'),
                      onTap: (s) => _openDetail(context, s),
                    ),
                  ],
                  if (provider.byGenre('Action').isNotEmpty) ...[
                    const SectionHeader(title: 'Aksi & Petualangan'),
                    ShowCarousel(
                      shows: provider.byGenre('Action'),
                      onTap: (s) => _openDetail(context, s),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}

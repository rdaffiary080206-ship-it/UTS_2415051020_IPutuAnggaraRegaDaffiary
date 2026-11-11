import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/show.dart';
import '../providers/show_provider.dart';
import '../utils/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/section_header.dart';
import '../widgets/show_carousel.dart';
import '../widgets/state_views.dart';
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShowProvider>();
    final isCompact = Responsive.isCompact(context);
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
                  Container(
                    height: isCompact ? 220 : 320,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(provider.featured?.name ?? 'Featured'),
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
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}

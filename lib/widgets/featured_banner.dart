import 'package:flutter/material.dart';

import '../models/show.dart';
import '../utils/app_theme.dart';
import '../utils/responsive.dart';
import 'network_poster.dart';
import 'rating_badge.dart';

/// Banner utama bergaya Netflix/IDLIX di bagian atas Beranda.
class FeaturedBanner extends StatelessWidget {
  const FeaturedBanner({
    super.key,
    required this.show,
    required this.isSaved,
    required this.onDetail,
    required this.onQuickToggle,
    this.onSurpriseMe,
  });

  final Show show;
  final bool isSaved;
  final VoidCallback onDetail;
  final VoidCallback onQuickToggle;
  final VoidCallback? onSurpriseMe;

  @override
  Widget build(BuildContext context) {
    final isCompact = Responsive.isCompact(context);
    final height = isCompact ? 340.0 : 400.0;

    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: AppColors.surface,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          NetworkPoster(imageUrl: show.backdropUrl, borderRadius: 0),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.35, 1.0],
                colors: [
                  Colors.black.withValues(alpha: 0.35),
                  Colors.black.withValues(alpha: 0.45),
                  AppColors.background.withValues(alpha: 0.96),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isCompact ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'UNGGULAN',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white70),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'HD',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    RatingBadge(rating: show.rating, compact: true),
                    if (show.year != null)
                      Text(
                        show.year!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  show.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isCompact ? 24 : 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                if (show.genres.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    show.genres.join(' • '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  show.plainSummary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: onDetail,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Lihat Detail'),
                    ),
                    OutlinedButton.icon(
                      onPressed: onQuickToggle,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                      ),
                      icon: Icon(isSaved ? Icons.check : Icons.add),
                      label: Text(isSaved ? 'Di Watchlist' : 'Daftar Saya'),
                    ),
                    if (onSurpriseMe != null)
                      TextButton.icon(
                        onPressed: onSurpriseMe,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.gold,
                        ),
                        icon: const Icon(Icons.casino_outlined),
                        label: const Text('Kejutkan Saya'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

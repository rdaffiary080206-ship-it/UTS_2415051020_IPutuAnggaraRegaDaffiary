import 'package:flutter/material.dart';

import '../models/watch_status.dart';
import '../models/watchlist_item.dart';
import '../utils/app_theme.dart';
import 'network_poster.dart';

/// Kartu satu item watchlist: poster, status, rating, progres, catatan,
/// beserta tombol aksi Edit dan Hapus.
class WatchlistTile extends StatelessWidget {
  const WatchlistTile({
    super.key,
    required this.item,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final WatchlistItem item;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  static Color statusColor(WatchStatus status) {
    switch (status) {
      case WatchStatus.planToWatch:
        return AppColors.info;
      case WatchStatus.watching:
        return AppColors.gold;
      case WatchStatus.completed:
        return AppColors.success;
      case WatchStatus.dropped:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = statusColor(item.status);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 70,
                height: 100,
                child: NetworkPoster(imageUrl: item.posterUrl, borderRadius: 8),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: color),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(item.status.icon, size: 13, color: color),
                              const SizedBox(width: 4),
                              Text(item.status.label,
                                  style:
                                      TextStyle(color: color, fontSize: 12)),
                            ],
                          ),
                        ),
                        if (item.personalRating != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded,
                                  size: 16, color: AppColors.gold),
                              Text(
                                '${item.personalRating!.toStringAsFixed(1)}/10',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                      ],
                    ),
                    if (item.progress.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Progres: ${item.progress}',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                    if (item.note.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        '"${item.note}"',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                children: [
                  if (onEdit != null)
                    IconButton(
                      tooltip: 'Edit',
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined),
                    ),
                  if (onDelete != null)
                    IconButton(
                      tooltip: 'Hapus',
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline,
                          color: AppColors.primary),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

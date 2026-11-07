import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

/// Badge rating bintang emas (gaya label rating di atas poster).
class RatingBadge extends StatelessWidget {
  const RatingBadge({super.key, required this.rating, this.compact = false});

  final double? rating;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final text = rating == null ? 'N/A' : rating!.toStringAsFixed(1);
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: compact ? 6 : 8, vertical: compact ? 2 : 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded,
              color: AppColors.gold, size: compact ? 12 : 16),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: compact ? 11 : 13,
            ),
          ),
        ],
      ),
    );
  }
}

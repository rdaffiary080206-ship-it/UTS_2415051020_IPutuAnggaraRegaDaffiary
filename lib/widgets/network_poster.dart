import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

/// Gambar poster dari jaringan dengan placeholder saat loading
/// dan fallback ikon saat gambar gagal dimuat / tidak tersedia.
class NetworkPoster extends StatelessWidget {
  const NetworkPoster({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.borderRadius = 10,
  });

  final String? imageUrl;
  final BoxFit fit;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: url == null || url.isEmpty
          ? const _PosterFallback()
          : Image.network(
              url,
              fit: fit,
              width: double.infinity,
              height: double.infinity,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(color: AppColors.surfaceLight);
              },
              errorBuilder: (context, error, stack) => const _PosterFallback(),
            ),
    );
  }
}

class _PosterFallback extends StatelessWidget {
  const _PosterFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceLight,
      alignment: Alignment.center,
      child: const Icon(Icons.movie_outlined,
          color: AppColors.textSecondary, size: 36),
    );
  }
}

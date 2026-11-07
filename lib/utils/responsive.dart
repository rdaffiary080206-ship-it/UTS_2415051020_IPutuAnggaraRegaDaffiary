import 'package:flutter/widgets.dart';

/// Ukuran layar yang didukung aplikasi.
enum ScreenSize { compact, medium, expanded }

/// Helper responsif berbasis lebar layar (breakpoint Material 3).
class Responsive {
  Responsive._();

  static const double compactMax = 600;
  static const double mediumMax = 1024;

  static ScreenSize sizeOf(double width) {
    if (width < compactMax) return ScreenSize.compact;
    if (width < mediumMax) return ScreenSize.medium;
    return ScreenSize.expanded;
  }

  static ScreenSize of(BuildContext context) =>
      sizeOf(MediaQuery.sizeOf(context).width);

  static bool isCompact(BuildContext context) =>
      of(context) == ScreenSize.compact;

  /// Jumlah kolom grid poster berdasarkan lebar area yang tersedia.
  static int gridColumns(double width) {
    if (width < 400) return 2;
    if (width < compactMax) return 3;
    if (width < 900) return 4;
    if (width < 1200) return 5;
    return 6;
  }

  /// Lebar kartu poster pada carousel horizontal.
  static double carouselItemWidth(BuildContext context) {
    switch (of(context)) {
      case ScreenSize.compact:
        return 130;
      case ScreenSize.medium:
        return 150;
      case ScreenSize.expanded:
        return 170;
    }
  }
}

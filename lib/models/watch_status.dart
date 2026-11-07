import 'package:flutter/material.dart';

/// Status tontonan pada watchlist.
enum WatchStatus {
  planToWatch('plan_to_watch', 'Ingin Ditonton', Icons.schedule),
  watching('watching', 'Sedang Ditonton', Icons.play_circle_outline),
  completed('completed', 'Selesai', Icons.check_circle_outline),
  dropped('dropped', 'Berhenti', Icons.cancel_outlined);

  const WatchStatus(this.dbValue, this.label, this.icon);

  /// Nilai yang disimpan di kolom `status` database.
  final String dbValue;
  final String label;
  final IconData icon;

  static WatchStatus fromDb(String? value) => WatchStatus.values.firstWhere(
        (s) => s.dbValue == value,
        orElse: () => WatchStatus.planToWatch,
      );
}

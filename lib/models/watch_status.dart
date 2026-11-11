/// Status tontonan pada watchlist dengan urutan:
/// Favorite, Ingin Ditonton, Sedang Ditonton, Selesai.
enum WatchStatus {
  favorite('dropped', 'Favorite'),
  planToWatch('plan_to_watch', 'Ingin Ditonton'),
  watching('watching', 'Sedang Ditonton'),
  completed('completed', 'Selesai');

  const WatchStatus(this.dbValue, this.label);

  /// Nilai yang disimpan di kolom `status` database.
  final String dbValue;
  final String label;

  static WatchStatus fromDb(String? value) {
    if (value == 'favorite' || value == 'dropped') {
      return WatchStatus.favorite;
    }
    return WatchStatus.values.firstWhere(
      (s) => s.dbValue == value,
      orElse: () => WatchStatus.planToWatch,
    );
  }
}

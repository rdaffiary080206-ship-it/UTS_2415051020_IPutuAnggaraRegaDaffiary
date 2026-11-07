import 'show.dart';
import 'watch_status.dart';

/// Model baris tabel `watchlist` di database (Supabase/PostgreSQL).
class WatchlistItem {
  const WatchlistItem({
    this.id,
    required this.showId,
    required this.title,
    this.posterUrl,
    this.genres = '',
    this.status = WatchStatus.planToWatch,
    this.personalRating,
    this.progress = '',
    this.note = '',
    this.createdAt,
    this.updatedAt,
  });

  /// Primary key (null sebelum disimpan ke database).
  final int? id;

  /// ID show di TVMaze (null jika ditambahkan manual).
  final int? showId;
  final String title;
  final String? posterUrl;
  final String genres;
  final WatchStatus status;

  /// Rating pribadi 1–10.
  final double? personalRating;

  /// Progres tontonan, mis. "S1 E5" atau "Menit 45".
  final String progress;
  final String note;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Membuat item watchlist awal dari data show API.
  factory WatchlistItem.fromShow(Show show) => WatchlistItem(
        showId: show.id,
        title: show.name,
        posterUrl: show.posterUrl,
        genres: show.genres.join(', '),
      );

  factory WatchlistItem.fromMap(Map<String, dynamic> map) => WatchlistItem(
        id: map['id'] as int?,
        showId: map['show_id'] as int?,
        title: (map['title'] as String?) ?? '',
        posterUrl: map['poster_url'] as String?,
        genres: (map['genres'] as String?) ?? '',
        status: WatchStatus.fromDb(map['status'] as String?),
        personalRating: (map['personal_rating'] as num?)?.toDouble(),
        progress: (map['progress'] as String?) ?? '',
        note: (map['note'] as String?) ?? '',
        createdAt: DateTime.tryParse((map['created_at'] as String?) ?? ''),
        updatedAt: DateTime.tryParse((map['updated_at'] as String?) ?? ''),
      );

  /// Data untuk insert/update (tanpa id & timestamp yang diatur database).
  Map<String, dynamic> toMap() => {
        'show_id': showId,
        'title': title,
        'poster_url': posterUrl,
        'genres': genres,
        'status': status.dbValue,
        'personal_rating': personalRating,
        'progress': progress,
        'note': note,
      };

  WatchlistItem copyWith({
    int? id,
    String? title,
    String? posterUrl,
    String? genres,
    WatchStatus? status,
    double? personalRating,
    String? progress,
    String? note,
  }) =>
      WatchlistItem(
        id: id ?? this.id,
        showId: showId,
        title: title ?? this.title,
        posterUrl: posterUrl ?? this.posterUrl,
        genres: genres ?? this.genres,
        status: status ?? this.status,
        personalRating: personalRating ?? this.personalRating,
        progress: progress ?? this.progress,
        note: note ?? this.note,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

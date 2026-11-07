/// Model film/series dari REST API TVMaze (`/shows`, `/search/shows`).
class Show {
  const Show({
    required this.id,
    required this.name,
    required this.genres,
    this.status,
    this.premiered,
    this.runtime,
    this.rating,
    this.network,
    this.language,
    this.imageMedium,
    this.imageOriginal,
    this.summary,
    this.officialSite,
    this.scheduleDays = const [],
    this.scheduleTime,
    this.weight = 0,
  });

  final int id;
  final String name;
  final List<String> genres;
  final String? status;
  final DateTime? premiered;
  final int? runtime;
  final double? rating;
  final String? network;
  final String? language;
  final String? imageMedium;
  final String? imageOriginal;
  final String? summary;
  final String? officialSite;
  final List<String> scheduleDays;
  final String? scheduleTime;

  /// Skor popularitas dari TVMaze (0–100).
  final int weight;

  String? get year => premiered?.year.toString();

  /// Poster terbaik yang tersedia.
  String? get posterUrl => imageMedium ?? imageOriginal;

  /// Gambar resolusi tinggi untuk banner/detail.
  String? get backdropUrl => imageOriginal ?? imageMedium;

  /// Sinopsis tanpa tag HTML.
  String get plainSummary {
    final raw = summary;
    if (raw == null || raw.trim().isEmpty) return 'Sinopsis belum tersedia.';
    return raw
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .trim();
  }

  factory Show.fromJson(Map<String, dynamic> json) {
    final image = json['image'] as Map?;
    final rating = json['rating'] as Map?;
    final network = json['network'] as Map?;
    final webChannel = json['webChannel'] as Map?;
    final schedule = json['schedule'] as Map?;

    return Show(
      id: json['id'] as int,
      name: (json['name'] as String?) ?? 'Tanpa Judul',
      genres: (json['genres'] as List<dynamic>? ?? const [])
          .map((g) => g.toString())
          .toList(),
      status: json['status'] as String?,
      premiered: DateTime.tryParse((json['premiered'] as String?) ?? ''),
      runtime: (json['runtime'] ?? json['averageRuntime']) as int?,
      rating: (rating?['average'] as num?)?.toDouble(),
      network: (network?['name'] ?? webChannel?['name']) as String?,
      language: json['language'] as String?,
      imageMedium: image?['medium'] as String?,
      imageOriginal: image?['original'] as String?,
      summary: json['summary'] as String?,
      officialSite: json['officialSite'] as String?,
      scheduleDays: (schedule?['days'] as List<dynamic>? ?? const [])
          .map((d) => d.toString())
          .toList(),
      scheduleTime: schedule?['time'] as String?,
      weight: (json['weight'] as int?) ?? 0,
    );
  }
}

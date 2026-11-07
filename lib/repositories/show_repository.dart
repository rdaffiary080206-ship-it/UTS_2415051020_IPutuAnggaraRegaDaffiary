import '../models/show.dart';
import '../services/tvmaze_service.dart';

/// Repository katalog: mengubah JSON dari service menjadi model [Show].
class ShowRepository {
  ShowRepository(this._service);

  final TvMazeService _service;

  Future<List<Show>> getShows({int page = 0}) async {
    final data = await _service.fetchShows(page: page);
    return data
        .whereType<Map<String, dynamic>>()
        .map(Show.fromJson)
        .toList();
  }

  Future<List<Show>> searchShows(String query) async {
    final data = await _service.searchShows(query);
    return data
        .whereType<Map<String, dynamic>>()
        .map((e) => e['show'])
        .whereType<Map<String, dynamic>>()
        .map(Show.fromJson)
        .toList();
  }
}

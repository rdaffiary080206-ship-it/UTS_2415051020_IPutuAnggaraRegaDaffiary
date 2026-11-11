import 'package:cinemay/services/watchlist_data_source.dart';

/// Data source watchlist di memori untuk pengujian (pengganti Supabase).
class FakeWatchlistDataSource implements WatchlistDataSource {
  FakeWatchlistDataSource([List<Map<String, dynamic>>? initial])
      : rows = [...?initial];

  final List<Map<String, dynamic>> rows;
  int _nextId = 100;

  @override
  Future<List<Map<String, dynamic>>> fetchAll() async => [...rows];

  @override
  Future<Map<String, dynamic>> insert(Map<String, dynamic> data) async {
    final row = {...data, 'id': _nextId++};
    rows.insert(0, row);
    return row;
  }

  @override
  Future<Map<String, dynamic>> update(int id, Map<String, dynamic> data) async {
    final index = rows.indexWhere((r) => r['id'] == id);
    rows[index] = {...rows[index], ...data};
    return rows[index];
  }

  @override
  Future<void> delete(int id) async => rows.removeWhere((r) => r['id'] == id);
}

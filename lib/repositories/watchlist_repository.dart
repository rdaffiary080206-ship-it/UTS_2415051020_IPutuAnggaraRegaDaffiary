import '../models/watchlist_item.dart';
import '../services/watchlist_data_source.dart';

/// Repository watchlist: menjembatani provider dan data source database,
/// serta mengubah Map database menjadi model [WatchlistItem].
class WatchlistRepository {
  WatchlistRepository(this._dataSource);

  final WatchlistDataSource _dataSource;

  Future<List<WatchlistItem>> getAll() async {
    final rows = await _dataSource.fetchAll();
    return rows.map(WatchlistItem.fromMap).toList();
  }

  Future<WatchlistItem> add(WatchlistItem item) async {
    final row = await _dataSource.insert(item.toMap());
    return WatchlistItem.fromMap(row);
  }

  Future<WatchlistItem> update(WatchlistItem item) async {
    final id = item.id;
    if (id == null) throw ArgumentError('Item belum memiliki id.');
    final row = await _dataSource.update(id, item.toMap());
    return WatchlistItem.fromMap(row);
  }

  Future<void> delete(int id) => _dataSource.delete(id);
}

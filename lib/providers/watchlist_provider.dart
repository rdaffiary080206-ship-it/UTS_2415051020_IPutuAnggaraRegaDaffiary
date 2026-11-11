import 'package:flutter/foundation.dart';

import '../models/show.dart';
import '../models/watch_status.dart';
import '../models/watchlist_item.dart';
import '../repositories/watchlist_repository.dart';

/// Shared state watchlist dari database, dipakai beberapa screen
/// (Home, Detail, Watchlist, Profile).
class WatchlistProvider extends ChangeNotifier {
  WatchlistProvider(this._repository);

  final WatchlistRepository _repository;

  List<WatchlistItem> _items = [];
  bool _isLoading = false;
  String? _errorMessage;
  WatchStatus? _statusFilter;

  List<WatchlistItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get count => _items.length;
  WatchStatus? get statusFilter => _statusFilter;

  /// Item setelah difilter berdasarkan status tontonan.
  List<WatchlistItem> get filteredItems => _statusFilter == null
      ? items
      : _items.where((i) => i.status == _statusFilter).toList();

  int countByStatus(WatchStatus status) =>
      _items.where((i) => i.status == status).length;

  /// Rata-rata rating pribadi (null jika belum ada rating).
  double? get averageRating {
    final rated = _items.where((i) => i.personalRating != null).toList();
    if (rated.isEmpty) return null;
    final total = rated.fold<double>(0, (sum, i) => sum + i.personalRating!);
    return total / rated.length;
  }

  void setStatusFilter(WatchStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  bool isSaved(int showId) => _items.any((i) => i.showId == showId);

  WatchlistItem? findByShowId(int showId) {
    for (final item in _items) {
      if (item.showId == showId) return item;
    }
    return null;
  }

  /// READ: memuat seluruh watchlist dari database.
  Future<void> loadItems() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _items = await _repository.getAll();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// CREATE: menyimpan item baru ke database lalu menambahkannya ke state.
  /// Error dilempar ulang agar UI dapat menampilkan pesan.
  Future<WatchlistItem> add(WatchlistItem item) async {
    final saved = await _repository.add(item);
    _items.insert(0, saved);
    notifyListeners();
    return saved;
  }

  /// CREATE cepat (satu ketukan) dari data show, tanpa membuka form.
  Future<WatchlistItem> quickAdd(Show show) => add(WatchlistItem.fromShow(show));

  /// UPDATE: memperbarui item di database lalu mengganti item di state.
  Future<WatchlistItem> update(WatchlistItem item) async {
    final updated = await _repository.update(item);
    final index = _items.indexWhere((i) => i.id == updated.id);
    if (index != -1) _items[index] = updated;
    notifyListeners();
    return updated;
  }

  /// DELETE: menghapus item dari database lalu dari state.
  Future<void> remove(WatchlistItem item) async {
    final id = item.id;
    if (id == null) return;
    await _repository.delete(id);
    _items.removeWhere((i) => i.id == id);
    notifyListeners();
  }
}

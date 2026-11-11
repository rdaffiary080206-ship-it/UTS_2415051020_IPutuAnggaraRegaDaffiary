import 'package:flutter/foundation.dart';

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

  List<WatchlistItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get count => _items.length;

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
}

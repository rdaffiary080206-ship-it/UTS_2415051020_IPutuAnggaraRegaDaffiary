import 'package:flutter/foundation.dart';

import '../models/show.dart';
import '../models/watchlist_item.dart';

/// Shared state watchlist yang dipakai beberapa screen
/// (Home, Detail, Watchlist, Profile).
class WatchlistProvider extends ChangeNotifier {
  final List<WatchlistItem> _items = [];

  List<WatchlistItem> get items => List.unmodifiable(_items);
  int get count => _items.length;

  bool isSaved(int showId) => _items.any((i) => i.showId == showId);

  void toggle(Show show) {
    if (isSaved(show.id)) {
      _items.removeWhere((i) => i.showId == show.id);
    } else {
      _items.insert(0, WatchlistItem.fromShow(show));
    }
    notifyListeners();
  }
}

import 'package:flutter/foundation.dart';

import '../models/show.dart';
import '../utils/dummy_data.dart';

/// State katalog film/series: data, loading, dan error.
class ShowProvider extends ChangeNotifier {
  List<Show> _shows = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Show> get shows => List.unmodifiable(_shows);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Film paling populer (berdasarkan weight).
  List<Show> get trending {
    final sorted = [..._shows]..sort((a, b) => b.weight.compareTo(a.weight));
    return sorted.take(10).toList();
  }

  /// Film dengan rating tertinggi.
  List<Show> get topRated {
    final sorted = [..._shows]
      ..sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
    return sorted.take(10).toList();
  }

  Show? get featured => topRated.isEmpty ? null : topRated.first;

  Future<void> loadShows() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      _shows = dummyShowsJson.map(Show.fromJson).toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

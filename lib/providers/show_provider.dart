import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/show.dart';
import '../repositories/show_repository.dart';

/// Opsi pengurutan katalog.
enum SortOption {
  popular('Terpopuler'),
  rating('Rating Tertinggi'),
  newest('Terbaru'),
  title('Judul A–Z');

  const SortOption(this.label);
  final String label;
}

/// State katalog film/series: data, loading, error, serta
/// pencarian, filter genre, pengurutan, dan mode tampilan.
class ShowProvider extends ChangeNotifier {
  ShowProvider(this._repository);

  final ShowRepository _repository;

  List<Show> _shows = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Pencarian (memanggil endpoint search REST API).
  String _query = '';
  List<Show> _searchResults = [];
  bool _isSearching = false;
  String? _searchError;
  Timer? _debounce;

  // Filter & tampilan.
  String? _selectedGenre;
  SortOption _sort = SortOption.popular;
  bool _isGridView = true;

  List<Show> get shows => List.unmodifiable(_shows);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get query => _query;
  bool get isSearching => _isSearching;
  String? get searchError => _searchError;
  String? get selectedGenre => _selectedGenre;
  SortOption get sort => _sort;
  bool get isGridView => _isGridView;
  bool get hasActiveSearch => _query.trim().isNotEmpty;

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

  /// Genre yang tersedia pada data, diurutkan berdasarkan jumlah show.
  List<String> get genres {
    final counts = <String, int>{};
    for (final show in _shows) {
      for (final g in show.genres) {
        counts[g] = (counts[g] ?? 0) + 1;
      }
    }
    final list = counts.keys.toList()
      ..sort((a, b) => counts[b]!.compareTo(counts[a]!));
    return list;
  }

  /// Show per genre untuk baris kategori di beranda.
  List<Show> byGenre(String genre, {int limit = 10}) {
    final list = _shows.where((s) => s.genres.contains(genre)).toList()
      ..sort((a, b) => b.weight.compareTo(a.weight));
    return list.take(limit).toList();
  }

  /// Daftar yang ditampilkan di Eksplor setelah search, filter, dan sort.
  List<Show> get visibleShows {
    final source = hasActiveSearch ? _searchResults : _shows;
    final filtered = _selectedGenre == null
        ? [...source]
        : source.where((s) => s.genres.contains(_selectedGenre)).toList();

    switch (_sort) {
      case SortOption.popular:
        if (!hasActiveSearch) {
          filtered.sort((a, b) => b.weight.compareTo(a.weight));
        }
      case SortOption.rating:
        filtered.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
      case SortOption.newest:
        filtered.sort((a, b) => (b.premiered ?? DateTime(1900))
            .compareTo(a.premiered ?? DateTime(1900)));
      case SortOption.title:
        filtered.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }
    return filtered;
  }

  Future<void> loadShows() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _shows = await _repository.getShows();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Dipanggil setiap teks pencarian berubah; request dikirim
  /// setelah pengguna berhenti mengetik 500 ms (debounce).
  void onQueryChanged(String value) {
    _query = value;
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      _searchResults = [];
      _searchError = null;
      _isSearching = false;
      notifyListeners();
      return;
    }
    _isSearching = true;
    notifyListeners();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _runSearch(value.trim());
    });
  }

  Future<void> retrySearch() => _runSearch(_query.trim());

  Future<void> _runSearch(String query) async {
    if (query.isEmpty) return;
    _isSearching = true;
    _searchError = null;
    notifyListeners();
    try {
      final results = await _repository.searchShows(query);
      // Abaikan hasil lama jika query sudah berubah.
      if (query != _query.trim()) return;
      _searchResults = results;
    } catch (e) {
      if (query != _query.trim()) return;
      _searchError = e.toString();
    } finally {
      if (query == _query.trim()) {
        _isSearching = false;
        notifyListeners();
      }
    }
  }

  void clearSearch() => onQueryChanged('');

  void selectGenre(String? genre) {
    _selectedGenre = genre;
    notifyListeners();
  }

  void setSort(SortOption option) {
    _sort = option;
    notifyListeners();
  }

  void toggleViewMode() {
    _isGridView = !_isGridView;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

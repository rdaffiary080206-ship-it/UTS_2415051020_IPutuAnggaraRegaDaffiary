import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/show.dart';
import '../providers/show_provider.dart';
import '../providers/watchlist_provider.dart';
import '../utils/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/poster_card.dart';
import '../widgets/show_list_tile.dart';
import '../widgets/state_views.dart';
import 'detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDetail(Show show) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DetailScreen(show: show)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShowProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eksplor'),
        actions: [
          PopupMenuButton<SortOption>(
            tooltip: 'Urutkan',
            icon: const Icon(Icons.sort),
            initialValue: provider.sort,
            onSelected: provider.setSort,
            itemBuilder: (_) => [
              for (final option in SortOption.values)
                PopupMenuItem(value: option, child: Text(option.label)),
            ],
          ),
          IconButton(
            tooltip: provider.isGridView ? 'Tampilan daftar' : 'Tampilan grid',
            onPressed: provider.toggleViewMode,
            icon: Icon(provider.isGridView
                ? Icons.view_list_outlined
                : Icons.grid_view_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: provider.onQueryChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Cari judul film atau series...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: provider.query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Hapus pencarian',
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          provider.clearSearch();
                        },
                      ),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _GenreChip(
                  label: 'Semua',
                  selected: provider.selectedGenre == null,
                  onTap: () => provider.selectGenre(null),
                ),
                for (final genre in provider.genres)
                  _GenreChip(
                    label: genre,
                    selected: provider.selectedGenre == genre,
                    onTap: () => provider.selectGenre(genre),
                  ),
              ],
            ),
          ),
          Expanded(child: _buildResults(provider)),
        ],
      ),
    );
  }

  Widget _buildResults(ShowProvider provider) {
    if (provider.isLoading || provider.isSearching) {
      return LoadingStateView(
        message: provider.isSearching
            ? 'Mencari "${provider.query}"...'
            : 'Memuat katalog...',
      );
    }
    final error =
        provider.hasActiveSearch ? provider.searchError : provider.errorMessage;
    if (error != null) {
      return ErrorStateView(
        title: provider.hasActiveSearch
            ? 'Pencarian Gagal'
            : 'Gagal Memuat Katalog',
        message: error,
        onRetry: provider.hasActiveSearch
            ? provider.retrySearch
            : provider.loadShows,
      );
    }
    final shows = provider.visibleShows;
    if (shows.isEmpty) {
      return EmptyStateView(
        icon: Icons.search_off_rounded,
        title: 'Tidak Ada Judul yang Cocok',
        subtitle: provider.hasActiveSearch
            ? 'Coba kata kunci lain atau hapus filter genre.'
            : 'Tidak ada tayangan pada genre ini.',
        actionLabel: provider.selectedGenre != null || provider.hasActiveSearch
            ? 'Reset Filter'
            : null,
        onAction: () {
          _searchController.clear();
          provider.clearSearch();
          provider.selectGenre(null);
        },
      );
    }

    final watchlist = context.watch<WatchlistProvider>();
    if (!provider.isGridView) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: shows.length,
        itemBuilder: (context, index) {
          final show = shows[index];
          return ShowListTile(
            show: show,
            isSaved: watchlist.isSaved(show.id),
            onTap: () => _openDetail(show),
          );
        },
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = Responsive.gridColumns(constraints.maxWidth);
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 16,
            crossAxisSpacing: 12,
            childAspectRatio: 0.6,
          ),
          itemCount: shows.length,
          itemBuilder: (context, index) {
            final show = shows[index];
            return PosterCard(
              title: show.name,
              imageUrl: show.posterUrl,
              rating: show.rating,
              year: show.year,
              isSaved: watchlist.isSaved(show.id),
              onTap: () => _openDetail(show),
            );
          },
        );
      },
    );
  }
}

class _GenreChip extends StatelessWidget {
  const _GenreChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        selectedColor: AppColors.primary,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

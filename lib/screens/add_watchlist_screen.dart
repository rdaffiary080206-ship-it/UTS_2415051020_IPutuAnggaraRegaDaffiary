import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/show.dart';
import '../models/watchlist_item.dart';
import '../providers/watchlist_provider.dart';
import '../widgets/watchlist_form.dart';

/// CREATE: menambahkan film/series ke watchlist di database.
/// Jika [show] diberikan (dari Detail), form terisi otomatis.
class AddWatchlistScreen extends StatelessWidget {
  const AddWatchlistScreen({super.key, this.show});

  final Show? show;

  Future<void> _save(BuildContext context, WatchlistItem item) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await context.read<WatchlistProvider>().add(item);
      messenger.showSnackBar(
        SnackBar(content: Text('"${item.title}" ditambahkan ke watchlist')),
      );
      navigator.pop(true);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan: $e'),
          backgroundColor: Colors.red.shade800,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final initial = show == null
        ? const WatchlistItem(showId: null, title: '')
        : WatchlistItem.fromShow(show!);
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah ke Watchlist')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: WatchlistForm(
              initial: initial,
              titleEditable: show == null,
              submitLabel: 'Simpan ke Watchlist',
              onSubmit: (item) => _save(context, item),
            ),
          ),
        ),
      ),
    );
  }
}

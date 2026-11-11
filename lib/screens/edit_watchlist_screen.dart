import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/watchlist_item.dart';
import '../providers/watchlist_provider.dart';
import '../widgets/watchlist_form.dart';

/// UPDATE: mengubah status, progres, rating, atau catatan watchlist.
class EditWatchlistScreen extends StatelessWidget {
  const EditWatchlistScreen({super.key, required this.item});

  final WatchlistItem item;

  Future<void> _save(BuildContext context, WatchlistItem updated) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await context.read<WatchlistProvider>().update(updated);
      messenger.showSnackBar(
        SnackBar(content: Text('Perubahan "${updated.title}" disimpan')),
      );
      navigator.pop(true);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui: $e'),
          backgroundColor: Colors.red.shade800,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Watchlist')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: WatchlistForm(
              initial: item,
              titleEditable: item.showId == null,
              submitLabel: 'Simpan Perubahan',
              onSubmit: (updated) => _save(context, updated),
            ),
          ),
        ),
      ),
    );
  }
}

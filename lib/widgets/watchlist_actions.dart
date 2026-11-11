import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/show.dart';
import '../models/watchlist_item.dart';
import '../providers/watchlist_provider.dart';
import 'confirm_dialog.dart';

/// Alur hapus item watchlist yang dipakai di beberapa screen:
/// konfirmasi → hapus di database → SnackBar hasil.
/// Mengembalikan `true` jika item berhasil dihapus.
Future<bool> confirmAndDeleteWatchlistItem(
  BuildContext context,
  WatchlistItem item,
) async {
  final provider = context.read<WatchlistProvider>();
  final messenger = ScaffoldMessenger.of(context);

  final confirmed = await showConfirmDialog(
    context,
    title: 'Hapus dari Watchlist?',
    message: '"${item.title}" beserta rating dan catatanmu akan dihapus '
        'permanen dari database.',
  );
  if (!confirmed) return false;

  try {
    await provider.remove(item);
    messenger.showSnackBar(
      SnackBar(content: Text('"${item.title}" dihapus dari watchlist')),
    );
    return true;
  } catch (e) {
    messenger.showSnackBar(
      SnackBar(
        content: Text('Gagal menghapus: $e'),
        backgroundColor: Colors.red.shade800,
      ),
    );
    return false;
  }
}

/// Simpan cepat (satu ketukan) gaya tombol "+ Daftar Saya".
/// Jika sudah tersimpan, menghapus dengan konfirmasi.
Future<void> quickToggleWatchlist(BuildContext context, Show show) async {
  final provider = context.read<WatchlistProvider>();
  final existing = provider.findByShowId(show.id);
  if (existing != null) {
    await confirmAndDeleteWatchlistItem(context, existing);
    return;
  }

  final messenger = ScaffoldMessenger.of(context);
  try {
    await provider.quickAdd(show);
    messenger.showSnackBar(
      SnackBar(content: Text('"${show.name}" ditambahkan ke watchlist')),
    );
  } catch (e) {
    messenger.showSnackBar(
      SnackBar(
        content: Text('Gagal menyimpan: $e'),
        backgroundColor: Colors.red.shade800,
      ),
    );
  }
}

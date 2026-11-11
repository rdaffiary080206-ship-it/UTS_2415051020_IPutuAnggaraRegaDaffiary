import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/app_constants.dart';
import '../utils/env.dart';
import 'app_exception.dart';
import 'watchlist_data_source.dart';

/// Data source database Supabase untuk tabel `watchlist`.
/// Hanya bertugas menjalankan query dan mengembalikan Map mentah.
class SupabaseService implements WatchlistDataSource {
  SupabaseService._();

  static bool _initialized = false;

  /// Inisialisasi Supabase sekali saat aplikasi start.
  /// Jika kredensial belum diisi, aplikasi tetap berjalan
  /// dan fitur database menampilkan pesan error.
  static Future<void> initialize() async {
    if (!Env.isSupabaseConfigured || _initialized) return;
    await Supabase.initialize(
      url: Env.supabaseUrl,
      publishableKey: Env.supabasePublishableKey,
    );
    _initialized = true;
  }

  static final SupabaseService instance = SupabaseService._();

  SupabaseQueryBuilder get _table {
    if (!_initialized) {
      throw const DatabaseException(
        'Database belum dikonfigurasi. Jalankan aplikasi dengan '
        '--dart-define-from-file=env.json.',
      );
    }
    return Supabase.instance.client.from(AppConstants.watchlistTable);
  }

  /// READ: semua baris watchlist, terbaru di atas.
  @override
  Future<List<Map<String, dynamic>>> fetchAll() => _guard(() async {
        final rows =
            await _table.select().order('created_at', ascending: false);
        return List<Map<String, dynamic>>.from(rows);
      });

  /// CREATE: menyimpan baris baru dan mengembalikan baris tersimpan.
  @override
  Future<Map<String, dynamic>> insert(Map<String, dynamic> data) =>
      _guard(() => _table.insert(data).select().single());

  /// UPDATE: memperbarui baris berdasarkan id.
  @override
  Future<Map<String, dynamic>> update(int id, Map<String, dynamic> data) =>
      _guard(() => _table.update(data).eq('id', id).select().single());

  /// DELETE: menghapus baris berdasarkan id.
  @override
  Future<void> delete(int id) =>
      _guard(() async => await _table.delete().eq('id', id));

  /// Mengubah error Supabase/jaringan menjadi [AppException].
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      await initialize();
      return await action();
    } on AppException {
      rethrow;
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw const DatabaseException('Judul ini sudah ada di watchlist.');
      }
      if (e.code == '42P01' || e.code == 'PGRST205') {
        throw const DatabaseException(
          'Tabel watchlist belum dibuat. Jalankan supabase/schema.sql.',
        );
      }
      throw DatabaseException('Operasi database gagal: ${e.message}');
    } on AuthException catch (e) {
      throw DatabaseException('Akses database ditolak: ${e.message}');
    } catch (e) {
      final text = e.toString();
      if (text.contains('SocketException') ||
          text.contains('ClientException') ||
          text.contains('Failed host lookup')) {
        throw const NetworkException(
          'Tidak dapat terhubung ke database. Periksa koneksi internet.',
        );
      }
      throw DatabaseException('Terjadi kesalahan database: $text');
    }
  }
}

/// Kontrak data source watchlist. Diimplementasikan oleh
/// [SupabaseService]; bisa diganti implementasi palsu saat testing.
abstract class WatchlistDataSource {
  Future<List<Map<String, dynamic>>> fetchAll();
  Future<Map<String, dynamic>> insert(Map<String, dynamic> data);
  Future<Map<String, dynamic>> update(int id, Map<String, dynamic> data);
  Future<void> delete(int id);
}

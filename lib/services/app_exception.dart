/// Exception khusus aplikasi agar pesan error ke pengguna lebih jelas.
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Gagal terhubung ke internet / server.
class NetworkException extends AppException {
  const NetworkException([
    super.message = 'Tidak dapat terhubung ke server. Periksa koneksi internet.',
  ]);
}

/// Server REST API membalas dengan status error atau data tidak valid.
class ApiException extends AppException {
  const ApiException(super.message, {this.statusCode});
  final int? statusCode;
}

/// Operasi database (Supabase) gagal.
class DatabaseException extends AppException {
  const DatabaseException(super.message);
}

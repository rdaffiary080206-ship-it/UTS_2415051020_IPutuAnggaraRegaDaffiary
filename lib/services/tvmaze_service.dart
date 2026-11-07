import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../utils/app_constants.dart';
import 'app_exception.dart';

/// Data source REST API TVMaze. Hanya bertugas melakukan HTTP GET
/// dan mengembalikan JSON mentah.
class TvMazeService {
  TvMazeService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _timeout = Duration(seconds: 15);

  /// GET /shows?page={page} — daftar show (250 per halaman).
  Future<List<dynamic>> fetchShows({int page = 0}) =>
      _getList('/shows?page=$page');

  /// GET /search/shows?q={query} — hasil pencarian show.
  Future<List<dynamic>> searchShows(String query) =>
      _getList('/search/shows?q=${Uri.encodeQueryComponent(query)}');

  Future<List<dynamic>> _getList(String path) async {
    final uri = Uri.parse('${AppConstants.tvMazeBaseUrl}$path');
    try {
      final response = await _client.get(uri).timeout(_timeout);
      if (response.statusCode == 429) {
        throw const ApiException(
          'Terlalu banyak permintaan ke server. Coba lagi sebentar.',
          statusCode: 429,
        );
      }
      if (response.statusCode != 200) {
        throw ApiException(
          'Server mengembalikan error (${response.statusCode}).',
          statusCode: response.statusCode,
        );
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        throw const ApiException('Format data dari server tidak valid.');
      }
      return decoded;
    } on SocketException {
      throw const NetworkException();
    } on TimeoutException {
      throw const NetworkException('Koneksi ke server terlalu lama (timeout).');
    } on http.ClientException {
      throw const NetworkException();
    } on FormatException {
      throw const ApiException('Gagal membaca data dari server.');
    }
  }
}

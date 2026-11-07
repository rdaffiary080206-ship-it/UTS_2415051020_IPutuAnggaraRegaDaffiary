/// Konfigurasi environment yang dibaca saat build melalui
/// `--dart-define-from-file=env.json` (file env.json tidak di-commit).
///
/// Hanya berisi Supabase Project URL dan **anon public key**.
/// Jangan pernah mengisi service_role key di sini.
class Env {
  Env._();

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}

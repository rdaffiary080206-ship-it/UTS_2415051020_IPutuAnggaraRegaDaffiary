/// Konfigurasi environment yang dibaca saat build melalui
/// `--dart-define-from-file=env.json` (file env.json tidak di-commit).
///
/// Hanya berisi Supabase Project URL dan **publishable (anon) key**.
/// Jangan pernah mengisi secret / service_role key di sini.
class Env {
  Env._();

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabasePublishableKey =
      String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;
}

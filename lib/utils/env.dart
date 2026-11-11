/// Konfigurasi environment Supabase.
/// Menggunakan publishable (anon) key yang aman untuk client + RLS.
/// Jangan pernah mengisi secret / service_role key di sini.
class Env {
  Env._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://xmpcfjzbpecpmjcoarql.supabase.co',
  );

  static const String supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'sb_publishable_6BKCZcoa4xl2pF2XkbptmQ_zaif8mhr',
  );

  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;
}

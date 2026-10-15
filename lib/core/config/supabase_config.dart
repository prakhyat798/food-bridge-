/// Configuration file for Supabase Database & Auth.
///
/// HOW TO GET YOUR KEYS:
/// 1. Go to https://supabase.com/dashboard and open your project.
/// 2. Click "Project Settings" (gear icon) on the left sidebar.
/// 3. Click "API".
/// 4. Copy "Project URL" and paste into [supabaseUrl].
/// 5. Copy "Project API keys" -> `anon public` and paste into [supabaseAnonKey].
class SupabaseConfig {
  /// Live Supabase project URL
  static const String supabaseUrl = 'https://fmklzxrcifshlljkrurt.supabase.co';

  /// Live Supabase anon public key
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZta2x6eHJjaWZzaGxsamtydXJ0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTE4NzQyMzksImV4cCI6MjEwNzQ1MDIzOX0.SVIcl10vLNd0WdsR6qhQgp4spwmV075PsbhTgkJ2Hz0';

  /// Checks if valid Supabase credentials have been configured
  static bool get isConfigured {
    return supabaseUrl.isNotEmpty &&
        supabaseAnonKey.isNotEmpty &&
        !supabaseUrl.contains('YOUR_SUPABASE_PROJECT_ID') &&
        !supabaseAnonKey.contains('YOUR_SUPABASE_ANON_PUBLIC_KEY');
  }
}

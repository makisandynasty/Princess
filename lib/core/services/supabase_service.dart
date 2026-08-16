import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Central service for Supabase initialization and client access.
class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  static const String supabaseUrl = 'https://akdfkrdayflyjzoosaba.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_x6WNShmvhrHPUiiDEIhR3A_GWM13DgM';

  bool _initialized = false;

  /// Initialize Supabase Flutter SDK.
  Future<void> init() async {
    if (_initialized) return;
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: kDebugMode,
      );
      _initialized = true;
    } catch (e) {
      debugPrint('Supabase init error: $e');
    }
  }

  /// Get the active Supabase client.
  SupabaseClient get client => Supabase.instance.client;

  /// Current authenticated user (if any).
  User? get currentUser => _initialized ? client.auth.currentUser : null;

  /// Whether a user is currently signed in.
  bool get isAuthenticated => currentUser != null;

  /// Stream of authentication state changes.
  Stream<AuthState>? get authStateChanges =>
      _initialized ? client.auth.onAuthStateChange : null;
}

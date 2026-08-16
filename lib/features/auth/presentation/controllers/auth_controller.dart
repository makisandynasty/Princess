import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/supabase_service.dart';

/// State of authentication
class AuthStateModel {
  const AuthStateModel({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  final User? user;
  final bool isLoading;
  final String? errorMessage;

  bool get isAuthenticated => user != null;
  String get displayName =>
      user?.userMetadata?['full_name'] as String? ??
      user?.userMetadata?['name'] as String? ??
      user?.email?.split('@').first ??
      'Guest';

  String? get email => user?.email;
  String? get avatarUrl => user?.userMetadata?['avatar_url'] as String?;

  AuthStateModel copyWith({
    User? user,
    bool? isLoading,
    String? errorMessage,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthStateModel(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthController extends StateNotifier<AuthStateModel> {
  AuthController(this._supabaseService)
      : super(AuthStateModel(user: _supabaseService.currentUser)) {
    _subscription = _supabaseService.authStateChanges?.listen((data) {
      state = state.copyWith(user: data.session?.user, clearUser: data.session?.user == null);
    });
  }

  final SupabaseService _supabaseService;
  StreamSubscription<AuthState>? _subscription;

  /// Sign in using Google OAuth
  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final success = await _supabaseService.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'io.supabase.princes://login-callback/',
      );
      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      debugPrint('Google sign in error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Sign in Anonymously (Guest connection)
  Future<bool> signInAnonymously() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _supabaseService.client.auth.signInAnonymously();
      state = state.copyWith(
        user: response.user,
        isLoading: false,
      );
      return true;
    } catch (e) {
      debugPrint('Anonymous sign in error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Sign in with Email and Password
  Future<bool> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _supabaseService.client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      state = state.copyWith(
        user: response.user,
        isLoading: false,
      );
      return true;
    } catch (e) {
      debugPrint('Email sign in error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Sign up with Email and Password
  Future<bool> signUpWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _supabaseService.client.auth.signUp(
        email: email.trim(),
        password: password,
      );
      state = state.copyWith(
        user: response.user,
        isLoading: false,
      );
      return true;
    } catch (e) {
      debugPrint('Email sign up error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _supabaseService.client.auth.signOut();
      state = const AuthStateModel(user: null);
    } catch (e) {
      debugPrint('Sign out error: $e');
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthStateModel>((ref) {
  return AuthController(SupabaseService.instance);
});

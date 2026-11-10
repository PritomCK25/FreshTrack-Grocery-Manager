
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Register a new user
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _supabase.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'full_name': name.trim(),
      },
    );
  }

  // Login an existing user
  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  // Logout the current user
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  // Check whether a user is logged in
  bool get isLoggedIn {
    return _supabase.auth.currentSession != null;
  }

  // Get the current user's ID
  String? get currentUserId {
    return _supabase.auth.currentUser?.id;
  }
}

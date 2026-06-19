import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  // =========================
  // REGISTER
  // =========================
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    final userId = response.user?.id;

    if (userId != null) {
      await supabase.from('profiles').insert({
        'id': userId,
        'full_name': fullName,
        'email': email,
        'role': role,
      });
    }
  }

  // =========================
  // LOGIN
  // =========================
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // =========================
  // LOGOUT
  // =========================
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // =========================
  // CURRENT USER
  // =========================
  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }

  // =========================
  // GET USER NAME
  // =========================
  Future<String> getCurrentUserName() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      return "Guest";
    }

    try {
      final response = await supabase
          .from('profiles')
          .select('full_name')
          .eq('id', user.id)
          .single();

      return response['full_name'] ?? 'Guest';
    } catch (e) {
      print("ERROR GET NAME: $e");
      return "Guest";
    }
  }

  // =========================
  // GET USER ROLE
  // =========================
  Future<String> getCurrentUserRole() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      return "";
    }

    try {
      final response = await supabase
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .single();

      return response['role'] ?? "";
    } catch (e) {
      print("ERROR GET ROLE: $e");
      return "";
    }
  }

  // =========================
  // GET PROFILE DATA
  // =========================
  Future<Map<String, dynamic>?> getProfile() async {
    final user = supabase.auth.currentUser;

    if (user == null) return null;

    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      return response;
    } catch (e) {
      print("ERROR GET PROFILE: $e");
      return null;
    }
  }
}
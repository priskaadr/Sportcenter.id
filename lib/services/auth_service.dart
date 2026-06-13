import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {

  final supabase = Supabase.instance.client;

  Future signUp({
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

  Future signIn({
    required String email,
    required String password,
  }) async {
    await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<String> getCurrentUserName() async {

    final user = supabase.auth.currentUser;

    if (user == null) {
      return "Guest";
    }

    final response = await supabase
        .from('profiles')
        .select('full_name')
        .eq('id', user.id)
        .single();

    return response['full_name'] ?? 'Guest';
  }
}
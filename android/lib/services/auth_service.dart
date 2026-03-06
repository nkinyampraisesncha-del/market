import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  SupabaseClient get client => _client;

  User? get currentSupabaseUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
    String? universityId,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'name': name,
        'role': role,
        'university_id': universityId,
      },
    );

    if (response.user != null) {
      await _createUserProfile(
        userId: response.user!.id,
        email: email,
        name: name,
        role: role,
        universityId: universityId,
      );
    }

    return response;
  }

  Future<void> _createUserProfile({
    required String userId,
    required String email,
    required String name,
    required String role,
    String? universityId,
  }) async {
    await _client.from('profiles').upsert({
      'id': userId,
      'email': email,
      'name': name,
      'role': role,
      'university_id': universityId,
      'is_verified': false,
      'is_active': true,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<UserModel?> getUserProfile(String userId) async {
    final response =
        await _client.from('profiles').select().eq('id', userId).maybeSingle();

    if (response == null) return null;
    return UserModel.fromJson(response);
  }

  Future<UserModel> updateUserProfile(UserModel user) async {
    final response = await _client
        .from('profiles')
        .update(user.toJson())
        .eq('id', user.id)
        .select()
        .single();
    return UserModel.fromJson(response);
  }

  Future<void> updateProfileImage(String userId, String imageUrl) async {
    await _client.from('profiles').update({
      'profile_image_url': imageUrl,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', userId);
  }

  bool get isAuthenticated => _client.auth.currentUser != null;

  String? get currentUserId => _client.auth.currentUser?.id;
}

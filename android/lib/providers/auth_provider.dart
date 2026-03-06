import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.initial;
  UserModel? _currentUser;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isBuyer => _currentUser?.isBuyer ?? false;
  bool get isSeller => _currentUser?.isSeller ?? false;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  AuthProvider() {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((data) async {
      final event = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        await _loadUserProfile(session.user.id);
      } else if (event == AuthChangeEvent.signedOut) {
        _currentUser = null;
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      } else if (event == AuthChangeEvent.tokenRefreshed && session != null) {
        if (_currentUser == null) {
          await _loadUserProfile(session.user.id);
        }
      }
    });

    final user = _authService.currentSupabaseUser;
    if (user != null) {
      _loadUserProfile(user.id);
    } else {
      _status = AuthStatus.unauthenticated;
    }
  }

  Future<void> _loadUserProfile(String userId) async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final profile = await _authService.getUserProfile(userId);
      _currentUser = profile;
      _status = profile != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
      _errorMessage = null;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.signIn(
        email: email,
        password: password,
      );
      if (response.user != null) {
        await _loadUserProfile(response.user!.id);
        return true;
      }
      _status = AuthStatus.unauthenticated;
      _errorMessage = 'Sign in failed. Please try again.';
      notifyListeners();
      return false;
    } on AuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'An unexpected error occurred.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
    String? universityId,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.signUp(
        email: email,
        password: password,
        name: name,
        role: role,
        universityId: universityId,
      );
      if (response.user != null) {
        await _loadUserProfile(response.user!.id);
        return true;
      }
      _status = AuthStatus.unauthenticated;
      _errorMessage = 'Registration failed. Please try again.';
      notifyListeners();
      return false;
    } on AuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'An unexpected error occurred.';
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshUser() async {
    final userId = _authService.currentUserId;
    if (userId != null) {
      await _loadUserProfile(userId);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

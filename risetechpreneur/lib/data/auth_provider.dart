import 'package:flutter_riverpod/legacy.dart';

/// Lightweight representation of an authenticated user.
class AppUser {
  final String id;
  final String email;
  final String? displayName;

  AppUser({required this.id, required this.email, this.displayName});
}

/// Riverpod state for the current authenticated user (or `null` if logged out).
class AuthState extends StateNotifier<AppUser?> {
  AuthState() : super(null); // Initial state is null (Logged Out)

  /// Mocks a sign‑in flow.
  ///
  /// In production, replace this with `FirebaseAuth` (or your backend of
  /// choice) and persist the resulting user / token.
  Future<void> signIn(String email, String password) async {
    // TODO: Replace with await FirebaseAuth.instance.signInWithEmailAndPassword(...)
    await Future.delayed(const Duration(seconds: 1)); // Simulate Network Delay

    // Mock Success
    state = AppUser(id: '123', email: email, displayName: 'Demo User');
  }

  /// Mocks an email + password registration flow.
  Future<void> signUp(String email, String password, String name) async {
    // TODO: Replace with await FirebaseAuth.instance.createUserWithEmailAndPassword(...)
    await Future.delayed(const Duration(seconds: 1));

    state = AppUser(id: '456', email: email, displayName: name);
  }

  /// Clears the in‑memory auth state.
  Future<void> signOut() async {
    // TODO: await FirebaseAuth.instance.signOut();
    state = null;
  }
}

/// Global provider that exposes [AuthState] and the current [AppUser].
final authProvider = StateNotifierProvider<AuthState, AppUser?>((ref) {
  return AuthState();
});

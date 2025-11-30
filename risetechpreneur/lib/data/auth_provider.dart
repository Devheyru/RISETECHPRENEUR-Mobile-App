import 'package:flutter_riverpod/legacy.dart';

// Simple User Model
class AppUser {
  final String id;
  final String email;
  final String? displayName;

  AppUser({required this.id, required this.email, this.displayName});
}

// The State Class holding the current User (or null if logged out)
class AuthState extends StateNotifier<AppUser?> {
  AuthState() : super(null); // Initial state is null (Logged Out)

  // --- SIGN IN LOGIC ---
  Future<void> signIn(String email, String password) async {
    // TODO: Replace with await FirebaseAuth.instance.signInWithEmailAndPassword(...)
    await Future.delayed(const Duration(seconds: 1)); // Simulate Network Delay

    // Mock Success
    state = AppUser(id: '123', email: email, displayName: 'Demo User');
  }

  // --- SIGN UP LOGIC ---
  Future<void> signUp(String email, String password, String name) async {
    // TODO: Replace with await FirebaseAuth.instance.createUserWithEmailAndPassword(...)
    await Future.delayed(const Duration(seconds: 1));

    state = AppUser(id: '456', email: email, displayName: name);
  }

  // --- SIGN OUT ---
  Future<void> signOut() async {
    // TODO: await FirebaseAuth.instance.signOut();
    state = null;
  }
}

// The Global Provider to access Auth Logic anywhere
final authProvider = StateNotifierProvider<AuthState, AppUser?>((ref) {
  return AuthState();
});

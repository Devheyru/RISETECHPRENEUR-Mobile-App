import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Lightweight representation of an authenticated user.
class AppUser {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;

  AppUser({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
  });

  factory AppUser.fromFirebase(User user) {
    return AppUser(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }
}

/// Riverpod state for the current authenticated user (or `null` if logged out).
class AuthState extends StateNotifier<AppUser?> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthState() : super(null) {
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        state = AppUser.fromFirebase(user);
      } else {
        state = null;
      }
    });
  }

  /// Sign in with Email and Password
  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Sign up with Email and Password
  Future<void> signUp(
    String email,
    String password,
    String name,
    String phone,
  ) async {
    UserCredential cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user?.updateDisplayName(name);

    // Save user data to Firestore
    if (cred.user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set({
            'uid': cred.user!.uid,
            'email': email,
            'fullName': name,
            'phone': phone,
            'createdAt': FieldValue.serverTimestamp(),
            'enrolledCourses': [], // Placeholder for future enrollments
          });
    }

    await cred.user?.reload();
    final updatedUser = _auth.currentUser;
    if (updatedUser != null) {
      state = AppUser.fromFirebase(updatedUser);
    }
  }

  /// Clears the in‑memory auth state.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

/// Global provider that exposes [AuthState] and the current [AppUser].
final authProvider = StateNotifierProvider<AuthState, AppUser?>((ref) {
  return AuthState();
});

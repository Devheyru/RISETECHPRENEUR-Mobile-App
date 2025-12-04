import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Lightweight representation of an authenticated user.
class AppUser {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? token;

  AppUser({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.token,
  });

  String get displayName => "$firstName $lastName".trim();

  factory AppUser.fromJson(Map<String, dynamic> json, {String? token}) {
    return AppUser(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'],
      lastName: json['last_name'],
      phone: json['phone'],
      token: token,
    );
  }
}

/// Riverpod state for the current authenticated user (or `null` if logged out).
class AuthState extends StateNotifier<AppUser?> {
  final _storage = const FlutterSecureStorage();
  final String baseUrl = "https://rise-techpreneur.havanacademy.com/api";

  AuthState() : super(null) {
    _restoreSession();
  }

  /// Try to restore session from secure storage
  Future<void> _restoreSession() async {
    final token = await _storage.read(key: 'auth_token');
    final email = await _storage.read(key: 'auth_email');
    final firstName = await _storage.read(key: 'auth_first_name');
    final lastName = await _storage.read(key: 'auth_last_name');

    if (token != null && email != null) {
      state = AppUser(
        id: '',
        email: email,
        firstName: firstName,
        lastName: lastName,
        token: token,
      );
    }
  }

  /// Sign in with Email and Password
  Future<void> signIn(String email, String password) async {
    final url = Uri.parse('$baseUrl/login-user');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Assuming standard response structure
        final token = data['token'];
        final userData = data['user'];

        if (token != null) {
          await _storage.write(key: 'auth_token', value: token);
          await _storage.write(key: 'auth_email', value: email);

          if (userData != null) {
            final user = AppUser.fromJson(userData, token: token);
            await _storage.write(key: 'auth_first_name', value: user.firstName);
            await _storage.write(key: 'auth_last_name', value: user.lastName);
            state = user;
          } else {
            state = AppUser(id: '', email: email, token: token);
          }
        } else {
          throw Exception('Token not found in response');
        }
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  /// Sign up with required fields
  Future<void> signUp({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final url = Uri.parse('$baseUrl/create-user');

    final body = {
      "first_name": firstName,
      "last_name": lastName,
      "phone": phone,
      "email": email,
      "password": password,
      "password_confirmation": confirmPassword,
      "terms": true,
      "role": "normal",
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final userData = data['user'];

        if (token != null) {
          await _storage.write(key: 'auth_token', value: token);
          await _storage.write(key: 'auth_email', value: email);

          if (userData != null) {
            final user = AppUser.fromJson(userData, token: token);
            await _storage.write(key: 'auth_first_name', value: user.firstName);
            await _storage.write(key: 'auth_last_name', value: user.lastName);
            state = user;
          } else {
            state = AppUser(
              id: '',
              email: email,
              firstName: firstName,
              lastName: lastName,
              token: token,
            );
          }
        }
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    final token = state?.token;
    if (token != null) {
      final url = Uri.parse('$baseUrl/logout-user');
      try {
        await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      } catch (e) {
        print("Logout error: $e");
      }
    }

    await _storage.deleteAll();
    state = null;
  }

  /// Request Password Reset
  Future<void> requestPasswordReset(String email) async {
    final url = Uri.parse('$baseUrl/password/reset/request');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to request password reset');
      }
    } catch (e) {
      throw Exception('Failed to request password reset: $e');
    }
  }

  /// Reset Password
  Future<void> resetPassword({
    required String email,
    required String password,
    required String confirmPassword,
    required String token,
  }) async {
    final url = Uri.parse('$baseUrl/password/reset');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": email,
          "password": password,
          "password_confirmation": confirmPassword,
          "token": token,
        }),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to reset password');
      }
    } catch (e) {
      throw Exception('Failed to reset password: $e');
    }
  }

  /// Update Password (authenticated)
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    final token = state?.token;
    if (token == null) throw Exception("Not authenticated");

    final url = Uri.parse('$baseUrl/password/update');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "current_password": currentPassword,
          "new_password": newPassword,
          "new_password_confirmation": confirmNewPassword,
        }),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to update password');
      }
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
  }
}

/// Global provider that exposes [AuthState] and the current [AppUser].
final authProvider = StateNotifierProvider<AuthState, AppUser?>((ref) {
  return AuthState();
});

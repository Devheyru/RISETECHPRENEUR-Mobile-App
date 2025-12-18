import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:risetechpreneur/core/error_handler.dart';

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
    final id = await _storage.read(key: 'auth_user_id');
    final firstName = await _storage.read(key: 'auth_first_name');
    final lastName = await _storage.read(key: 'auth_last_name');

    if (token != null && email != null) {
      state = AppUser(
        id: id ?? '',
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
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({"email": email, "password": password}),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw NetworkException(message: 'Request timeout');
            },
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final userData = data['user'];

        if (token == null) {
          throw AuthException(
            message: 'Token not found in response',
            userFriendlyMessage: 'Login failed. Please try again.',
            code: 'NO_TOKEN',
          );
        }

        // Store authentication data
        await _storage.write(key: 'auth_token', value: token);
        await _storage.write(key: 'auth_email', value: email);

        if (userData != null) {
          final user = AppUser.fromJson(userData, token: token);

          // Store user details
          await _storage.write(key: 'auth_user_id', value: user.id);
          if (user.firstName != null) {
            await _storage.write(key: 'auth_first_name', value: user.firstName);
          }
          if (user.lastName != null) {
            await _storage.write(key: 'auth_last_name', value: user.lastName);
          }

          state = user;
        } else {
          state = AppUser(id: '', email: email, token: token);
        }
      } else if (response.statusCode == 401) {
        throw AuthException(
          message: 'Invalid credentials',
          userFriendlyMessage:
              'Invalid email or password. Please check and try again.',
          code: 'INVALID_CREDENTIALS',
        );
      } else if (response.statusCode == 404) {
        throw AuthException(
          message: 'User not found',
          userFriendlyMessage:
              'No account found with this email. Please sign up first.',
          code: 'USER_NOT_FOUND',
        );
      } else if (response.statusCode >= 500) {
        throw ServerException(message: 'Server error: ${response.statusCode}');
      } else {
        // Try to parse error message from response
        debugPrint('Login failed with status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');

        try {
          final error = jsonDecode(response.body);
          debugPrint('Parsed error: $error');

          final errorMessage =
              error['message'] ??
              error['error'] ??
              error['errors'] ??
              'Login failed';

          // Check for specific error patterns in the server response
          String userFriendlyMessage;
          String errorCode;

          final lowerMessage = errorMessage.toString().toLowerCase();
          debugPrint('Lower message: $lowerMessage');

          if (lowerMessage.contains('credential') ||
              lowerMessage.contains('password') &&
                  lowerMessage.contains('incorrect') ||
              lowerMessage.contains('invalid') &&
                  (lowerMessage.contains('email') ||
                      lowerMessage.contains('password'))) {
            userFriendlyMessage =
                'Invalid email or password. Please check and try again.';
            errorCode = 'INVALID_CREDENTIALS';
          } else if (lowerMessage.contains('not found') ||
              lowerMessage.contains('no user')) {
            userFriendlyMessage =
                'No account found with this email. Please sign up first.';
            errorCode = 'USER_NOT_FOUND';
          } else if (lowerMessage.contains('email') &&
              lowerMessage.contains('verified')) {
            userFriendlyMessage =
                'Please verify your email address before signing in.';
            errorCode = 'EMAIL_NOT_VERIFIED';
          } else if (lowerMessage.contains('account') &&
              lowerMessage.contains('suspended')) {
            userFriendlyMessage =
                'Your account has been suspended. Please contact support.';
            errorCode = 'ACCOUNT_SUSPENDED';
          } else {
            // Use server message if it's short and readable
            userFriendlyMessage =
                errorMessage.length < 100 && !errorMessage.contains('Exception')
                    ? errorMessage.toString()
                    : 'Login failed. Please try again.';
            errorCode = 'LOGIN_FAILED';
          }

          debugPrint('User friendly message: $userFriendlyMessage');

          throw AuthException(
            message: errorMessage.toString(),
            userFriendlyMessage: userFriendlyMessage,
            code: errorCode,
          );
        } catch (e) {
          debugPrint('Error parsing response: $e');
          if (e is AuthException) rethrow;

          // If we can't parse JSON, use the raw response body
          final rawBody = response.body;
          if (rawBody.isNotEmpty && rawBody.length < 200) {
            throw AuthException(
              message:
                  'Login failed with status ${response.statusCode}: $rawBody',
              userFriendlyMessage: rawBody,
              code: 'LOGIN_FAILED',
            );
          }

          throw AuthException(
            message: 'Login failed with status ${response.statusCode}',
            userFriendlyMessage: 'Login failed. Please try again.',
            code: 'LOGIN_FAILED',
          );
        }
      }
    } on SocketException {
      throw NetworkException();
    } on NetworkException {
      rethrow; // Re-throw network exceptions
    } on AuthException {
      rethrow; // Re-throw our custom auth exceptions
    } catch (e) {
      ErrorHandler.logError(e, StackTrace.current);
      throw AuthException(
        message: 'Login failed: $e',
        userFriendlyMessage: ErrorHandler.getErrorMessage(e),
        code: 'UNKNOWN_ERROR',
      );
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
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept':
                  'application/json', // Force server to return JSON, not HTML
            },
            body: jsonEncode(body),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw NetworkException(message: 'Request timeout');
            },
          );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final userData = data['user'];

        if (token == null) {
          throw AuthException(
            message: 'Token not found in response',
            userFriendlyMessage: 'Registration failed. Please try again.',
            code: 'NO_TOKEN',
          );
        }

        // Store authentication data
        await _storage.write(key: 'auth_token', value: token);
        await _storage.write(key: 'auth_email', value: email);

        if (userData != null) {
          final user = AppUser.fromJson(userData, token: token);

          // Store user details
          await _storage.write(key: 'auth_user_id', value: user.id);
          if (user.firstName != null) {
            await _storage.write(key: 'auth_first_name', value: user.firstName);
          }
          if (user.lastName != null) {
            await _storage.write(key: 'auth_last_name', value: user.lastName);
          }

          state = user;
        } else {
          // Fallback if user data not returned
          await _storage.write(key: 'auth_first_name', value: firstName);
          await _storage.write(key: 'auth_last_name', value: lastName);

          state = AppUser(
            id: '',
            email: email,
            firstName: firstName,
            lastName: lastName,
            token: token,
          );
        }
      } else if (response.statusCode == 409 || response.statusCode == 422) {
        // Conflict or validation error
        try {
          final error = jsonDecode(response.body);
          final errorMessage =
              error['message'] ?? error['error'] ?? 'Registration failed';
          final lowerMessage = errorMessage.toString().toLowerCase();

          // Check for specific error patterns
          String userFriendlyMessage;
          String errorCode;

          if (lowerMessage.contains('email') &&
              (lowerMessage.contains('exists') ||
                  lowerMessage.contains('taken') ||
                  lowerMessage.contains('already'))) {
            userFriendlyMessage =
                'An account with this email already exists. Please sign in instead.';
            errorCode = 'EMAIL_EXISTS';
          } else if (lowerMessage.contains('phone') &&
              (lowerMessage.contains('exists') ||
                  lowerMessage.contains('taken') ||
                  lowerMessage.contains('already'))) {
            userFriendlyMessage =
                'This phone number is already registered. Please use a different number.';
            errorCode = 'PHONE_EXISTS';
          } else if (lowerMessage.contains('email') &&
              lowerMessage.contains('invalid')) {
            userFriendlyMessage = 'Please enter a valid email address.';
            errorCode = 'INVALID_EMAIL';
          } else if (lowerMessage.contains('password') &&
              (lowerMessage.contains('short') ||
                  lowerMessage.contains('weak') ||
                  lowerMessage.contains('length'))) {
            userFriendlyMessage =
                'Password is too weak. Please use at least 6 characters.';
            errorCode = 'WEAK_PASSWORD';
          } else if (lowerMessage.contains('phone') &&
              lowerMessage.contains('invalid')) {
            userFriendlyMessage = 'Please enter a valid phone number.';
            errorCode = 'INVALID_PHONE';
          } else if (lowerMessage.contains('validation') ||
              lowerMessage.contains('required')) {
            // Try to extract field-specific validation errors
            if (error['errors'] != null && error['errors'] is Map) {
              final errors = error['errors'] as Map;
              final firstError = errors.values.first;
              userFriendlyMessage =
                  firstError is List && firstError.isNotEmpty
                      ? firstError[0].toString()
                      : errorMessage;
            } else {
              userFriendlyMessage =
                  errorMessage.length < 100 &&
                          !errorMessage.contains('Exception')
                      ? errorMessage
                      : 'Please check your information and try again.';
            }
            errorCode = 'VALIDATION_ERROR';
          } else {
            // Use server message if it's readable
            userFriendlyMessage =
                errorMessage.length < 100 && !errorMessage.contains('Exception')
                    ? errorMessage
                    : 'Registration failed. Please check your information.';
            errorCode = 'VALIDATION_ERROR';
          }

          throw AuthException(
            message: errorMessage,
            userFriendlyMessage: userFriendlyMessage,
            code: errorCode,
          );
        } catch (e) {
          if (e is AuthException) rethrow;
          throw AuthException(
            message: 'Registration failed',
            userFriendlyMessage:
                'Registration failed. Please check your information and try again.',
            code: 'REGISTRATION_FAILED',
          );
        }
      } else if (response.statusCode >= 500) {
        throw ServerException(message: 'Server error: ${response.statusCode}');
      } else {
        // Try to parse error message from response
        try {
          final error = jsonDecode(response.body);
          final errorMessage =
              error['message'] ?? error['error'] ?? 'Registration failed';
          throw AuthException(
            message: errorMessage,
            userFriendlyMessage:
                errorMessage.length < 100 && !errorMessage.contains('Exception')
                    ? errorMessage
                    : 'Registration failed. Please try again.',
            code: 'REGISTRATION_FAILED',
          );
        } catch (e) {
          if (e is AuthException) rethrow;
          throw AuthException(
            message: 'Registration failed with status ${response.statusCode}',
            userFriendlyMessage: 'Registration failed. Please try again.',
            code: 'REGISTRATION_FAILED',
          );
        }
      }
    } on SocketException {
      throw NetworkException();
    } on NetworkException {
      rethrow;
    } on AuthException {
      rethrow;
    } catch (e) {
      ErrorHandler.logError(e, StackTrace.current);
      throw AuthException(
        message: 'Registration failed: $e',
        userFriendlyMessage: ErrorHandler.getErrorMessage(e),
        code: 'UNKNOWN_ERROR',
      );
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
        ErrorHandler.logError(e, StackTrace.current);
      }
    }

    await _storage.deleteAll();
    state = null;
  }

  /// Request Password Reset
  ///
  /// Sends a password reset email to the user. The email contains a web link
  /// where the user can reset their password. After resetting on the web,
  /// the user should return to the app to sign in with their new password.
  Future<void> requestPasswordReset(String email) async {
    final url = Uri.parse('$baseUrl/password/reset/request');
    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({"email": email}),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw NetworkException(message: 'Request timeout');
            },
          );

      if (response.statusCode == 200) {
        return; // Success
      } else if (response.statusCode == 404) {
        throw AuthException(
          message: 'User not found',
          userFriendlyMessage: 'No account found with this email address.',
          code: 'USER_NOT_FOUND',
        );
      } else if (response.statusCode == 429) {
        throw AuthException(
          message: 'Too many requests',
          userFriendlyMessage:
              'Too many reset attempts. Please wait a few minutes and try again.',
          code: 'RATE_LIMITED',
        );
      } else if (response.statusCode >= 500) {
        throw ServerException(message: 'Server error: ${response.statusCode}');
      } else {
        try {
          final error = jsonDecode(response.body);
          final errorMessage =
              error['message'] ??
              error['error'] ??
              'Failed to request password reset';
          throw AuthException(
            message: errorMessage,
            userFriendlyMessage:
                errorMessage.length < 100 && !errorMessage.contains('Exception')
                    ? errorMessage
                    : 'Failed to send reset email. Please try again.',
            code: 'RESET_REQUEST_FAILED',
          );
        } catch (e) {
          if (e is AuthException) rethrow;
          throw AuthException(
            message: 'Failed to request password reset',
            userFriendlyMessage:
                'Failed to send reset email. Please try again.',
            code: 'RESET_REQUEST_FAILED',
          );
        }
      }
    } on SocketException {
      throw NetworkException();
    } on NetworkException {
      rethrow;
    } on AuthException {
      rethrow;
    } catch (e) {
      ErrorHandler.logError(e, StackTrace.current);
      throw AuthException(
        message: 'Failed to request password reset: $e',
        userFriendlyMessage: ErrorHandler.getErrorMessage(e),
        code: 'UNKNOWN_ERROR',
      );
    }
  }

  /// Reset Password
  /// 
  /// Completes the password reset flow using the token received via deep link.
  /// After successful reset, the user should be navigated to the login screen.
  Future<void> resetPassword({
    required String email,
    required String password,
    required String confirmPassword,
    required String token,
  }) async {
    final url = Uri.parse('$baseUrl/password/reset');
    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              "email": email,
              "password": password,
              "password_confirmation": confirmPassword,
              "token": token,
            }),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw NetworkException(message: 'Request timeout');
            },
          );

      if (response.statusCode == 200) {
        return; // Success
      } else if (response.statusCode == 400 || response.statusCode == 422) {
        try {
          final error = jsonDecode(response.body);
          final errorMessage =
              error['message'] ?? error['error'] ?? 'Failed to reset password';
          final lowerMessage = errorMessage.toString().toLowerCase();

          String userFriendlyMessage;
          String errorCode = 'RESET_FAILED';

          if (lowerMessage.contains('token') &&
              (lowerMessage.contains('invalid') ||
                  lowerMessage.contains('expired'))) {
            userFriendlyMessage =
                'This reset link has expired or is invalid. Please request a new one.';
            errorCode = 'TOKEN_EXPIRED';
          } else if (lowerMessage.contains('password') &&
              lowerMessage.contains('match')) {
            userFriendlyMessage = 'Passwords do not match. Please try again.';
            errorCode = 'PASSWORD_MISMATCH';
          } else if (lowerMessage.contains('password') &&
              (lowerMessage.contains('weak') ||
                  lowerMessage.contains('short') ||
                  lowerMessage.contains('length'))) {
            userFriendlyMessage =
                'Password is too weak. Please use at least 6 characters.';
            errorCode = 'WEAK_PASSWORD';
          } else {
            userFriendlyMessage =
                errorMessage.length < 100 && !errorMessage.contains('Exception')
                    ? errorMessage
                    : 'Failed to reset password. Please try again.';
          }

          throw AuthException(
            message: errorMessage,
            userFriendlyMessage: userFriendlyMessage,
            code: errorCode,
          );
        } catch (e) {
          if (e is AuthException) rethrow;
          throw AuthException(
            message: 'Failed to reset password',
            userFriendlyMessage: 'Failed to reset password. Please try again.',
            code: 'RESET_FAILED',
          );
        }
      } else if (response.statusCode >= 500) {
        throw ServerException(message: 'Server error: ${response.statusCode}');
      } else {
        try {
          final error = jsonDecode(response.body);
          final errorMessage =
              error['message'] ?? error['error'] ?? 'Failed to reset password';
          throw AuthException(
            message: errorMessage,
            userFriendlyMessage:
                errorMessage.length < 100 && !errorMessage.contains('Exception')
                    ? errorMessage
                    : 'Failed to reset password. Please try again.',
            code: 'RESET_FAILED',
          );
        } catch (e) {
          if (e is AuthException) rethrow;
          throw AuthException(
            message: 'Failed to reset password',
            userFriendlyMessage: 'Failed to reset password. Please try again.',
            code: 'RESET_FAILED',
          );
        }
      }
    } on SocketException {
      throw NetworkException();
    } on NetworkException {
      rethrow;
    } on AuthException {
      rethrow;
    } catch (e) {
      ErrorHandler.logError(e, StackTrace.current);
      throw AuthException(
        message: 'Failed to reset password: $e',
        userFriendlyMessage: ErrorHandler.getErrorMessage(e),
        code: 'UNKNOWN_ERROR',
      );
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
          'Accept': 'application/json',
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

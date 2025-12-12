import 'dart:io';

/// Custom exception class for authentication errors
class AuthException implements Exception {
  final String message;
  final String userFriendlyMessage;
  final String? code;

  AuthException({
    required this.message,
    required this.userFriendlyMessage,
    this.code,
  });

  @override
  String toString() => message;
}

/// Network-related exception
class NetworkException extends AuthException {
  NetworkException({String? message})
    : super(
        message: message ?? 'Network error occurred',
        userFriendlyMessage:
            'No internet connection. Please check your network and try again.',
        code: 'NETWORK_ERROR',
      );
}

/// Validation exception
class ValidationException extends AuthException {
  ValidationException({required String message})
    : super(
        message: message,
        userFriendlyMessage: message,
        code: 'VALIDATION_ERROR',
      );
}

/// Server error exception
class ServerException extends AuthException {
  ServerException({String? message})
    : super(
        message: message ?? 'Server error',
        userFriendlyMessage:
            'Something went wrong on our end. Please try again later.',
        code: 'SERVER_ERROR',
      );
}

/// Centralized error handler for the application
class ErrorHandler {
  /// Parse HTTP errors and convert to user-friendly messages
  static String getErrorMessage(dynamic error) {
    if (error is AuthException) {
      return error.userFriendlyMessage;
    }

    final errorString = error.toString().toLowerCase();

    // Network errors
    if (error is SocketException || errorString.contains('socket')) {
      return 'No internet connection. Please check your network and try again.';
    }

    if (errorString.contains('timeout')) {
      return 'Request timed out. Please check your connection and try again.';
    }

    if (errorString.contains('connection refused') ||
        errorString.contains('failed host lookup')) {
      return 'Unable to connect to the server. Please try again later.';
    }

    // Authentication errors
    if (errorString.contains('invalid credentials') ||
        errorString.contains('incorrect password') ||
        errorString.contains('wrong password')) {
      return 'Invalid email or password. Please check and try again.';
    }

    if (errorString.contains('user not found') ||
        errorString.contains('account not found')) {
      return 'No account found with this email. Please sign up first.';
    }

    if (errorString.contains('user already exists') ||
        errorString.contains('email already') ||
        errorString.contains('account already exists')) {
      return 'An account with this email already exists. Please sign in instead.';
    }

    if (errorString.contains('invalid email')) {
      return 'Please enter a valid email address.';
    }

    if (errorString.contains('weak password') ||
        errorString.contains('password too short')) {
      return 'Password is too weak. Please use at least 6 characters.';
    }

    if (errorString.contains('token expired') ||
        errorString.contains('session expired')) {
      return 'Your session has expired. Please sign in again.';
    }

    if (errorString.contains('invalid token')) {
      return 'Invalid or expired reset link. Please request a new one.';
    }

    if (errorString.contains('unauthorized') || errorString.contains('401')) {
      return 'Session expired. Please sign in again.';
    }

    if (errorString.contains('forbidden') || errorString.contains('403')) {
      return 'You don\'t have permission to perform this action.';
    }

    if (errorString.contains('not found') || errorString.contains('404')) {
      return 'The requested resource was not found.';
    }

    // Server errors
    if (errorString.contains('500') ||
        errorString.contains('internal server')) {
      return 'Server error. Please try again later.';
    }

    if (errorString.contains('503') ||
        errorString.contains('service unavailable')) {
      return 'Service is temporarily unavailable. Please try again later.';
    }

    // Validation errors
    if (errorString.contains('validation failed')) {
      return 'Please check your input and try again.';
    }

    if (errorString.contains('required field')) {
      return 'Please fill in all required fields.';
    }

    // Format errors
    if (errorString.contains('format')) {
      return 'Invalid format. Please check your input.';
    }

    // Password reset errors
    if (errorString.contains('passwords do not match')) {
      return 'Passwords do not match. Please check and try again.';
    }

    if (errorString.contains('current password')) {
      return 'Current password is incorrect.';
    }

    // Generic fallback
    if (errorString.contains('exception:')) {
      // Extract message after "Exception:"
      final parts = error.toString().split('Exception:');
      if (parts.length > 1) {
        final message = parts[1].trim();
        // Check if it's a user-friendly message already
        if (!message.contains('Stack') && message.length < 100) {
          return message;
        }
      }
    }

    // Final fallback
    return 'Something went wrong. Please try again later.';
  }

  /// Log error for debugging (can be extended with crash reporting)
  static void logError(dynamic error, StackTrace? stackTrace) {
    // In production, you might want to send this to a crash reporting service
    // like Sentry, Crashlytics, etc.
    print('ERROR: $error');
    if (stackTrace != null) {
      print('STACK TRACE: $stackTrace');
    }
  }

  /// Handle error and return user-friendly message
  static String handleError(dynamic error, [StackTrace? stackTrace]) {
    logError(error, stackTrace);
    return getErrorMessage(error);
  }
}

/// Extension for easy error handling in UI
extension ErrorHandlingExtension on Exception {
  String get userMessage => ErrorHandler.getErrorMessage(this);
}

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';

enum AppErrorKind { network, notFound, permission, authDisabled, unknown }

/// The only error type controllers and screens ever see.
class AppException implements Exception {
  const AppException(this.kind, this.message);

  final AppErrorKind kind;
  final String message;

  @override
  String toString() => 'AppException($kind): $message';
}

/// Maps any low-level failure (Firebase, timeouts, ...) to an [AppException].
AppException mapError(Object error) {
  if (error is AppException) return error;
  if (error is TimeoutException) {
    return const AppException(
      AppErrorKind.network,
      'The server took too long to respond. Check your connection and try again.',
    );
  }
  if (error is FirebaseException) {
    switch (error.code) {
      case 'unavailable':
      case 'deadline-exceeded':
      case 'network-request-failed':
        return const AppException(
          AppErrorKind.network,
          'No internet connection. Check your connection and try again.',
        );
      case 'permission-denied':
        return const AppException(
          AppErrorKind.permission,
          'Permission denied. Check the Firestore rules and that Anonymous sign-in is enabled.',
        );
      case 'operation-not-allowed':
        return const AppException(
          AppErrorKind.authDisabled,
          'Anonymous sign-in is turned off. Enable it in Firebase Console > Authentication > Sign-in method.',
        );
      case 'not-found':
        return const AppException(AppErrorKind.notFound, 'Not found.');
    }
  }
  return const AppException(AppErrorKind.unknown, 'Something went wrong. Please try again.');
}

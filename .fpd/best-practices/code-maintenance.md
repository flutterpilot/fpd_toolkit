---
title: Code Maintenance
description: This rule outlines best practices for long-term code maintenance in Flutter and Dart. It covers setting up code generation with build_runner and freezed, adhering to comprehensive documentation standards with dartdoc, implementing robust error handling patterns with sealed classes, and establishing a structured logging system.
alwaysApply: false
globs:
  - '**/lib/**'
  - '**/pubspec.yaml'
  - '**/*.md'
  - '**/analysis_options.yaml'
---
# Code Maintenance

## Code Generation

### Build Runner Setup:
```yaml
# pubspec.yaml
dev_dependencies:
  build_runner: ^2.4.7
  json_serializable: ^6.7.1
  freezed: ^2.4.6
  json_annotation: ^4.8.1
```

```dart
// models/user.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '../../flutter-dart-best-practices/user.freezed.dart';
part '../../flutter-dart-best-practices/user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String name,
    required String email,
    @Default(true) bool isActive,
    DateTime? createdAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

## Documentation Standards

```dart
/// Service for handling user operations
/// 
/// This service provides methods to:
/// - Fetch users from the server
/// - Create new users
/// - Update existing user information
/// - Delete users
/// 
/// Usage example:
/// ```dart
/// final userService = UserService();
/// final users = await userService.getUsers();
/// ```
class UserService {
  /// Creates a new instance of [UserService]
  /// 
  /// [dio] Custom HTTP client (optional)
  UserService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  /// Fetches all users from the server
  /// 
  /// Returns a list of [User] or throws [ApiException] in case of error.
  /// 
  /// Throws:
  /// - [ApiException] for network or server errors
  /// - [FormatException] when the response is invalid
  Future<List<User>> getUsers() async {
    // Implementation...
  }

  /// Fetches a specific user by their ID
  /// 
  /// [userId] Unique ID of the user to fetch
  /// 
  /// Returns the found [User] or throws [ApiException] if not found.
  /// 
  /// Example:
  /// ```dart
  /// final user = await userService.getUserById('123');
  /// print(user.name);
  /// ```
  Future<User> getUserById(String userId) async {
    // Implementation...
  }
}
```

## Error Handling Patterns

```dart
// core/error/failures.dart
abstract class Failure extends Equatable {
  const Failure(this.message);
  
  final String message;

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

// core/error/exceptions.dart
class ServerException implements Exception {
  const ServerException(this.message);
  final String message;
}

class NetworkException implements Exception {
  const NetworkException(this.message);
  final String message;
}

class CacheException implements Exception {
  const CacheException(this.message);
  final String message;
}

// utils/result.dart
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

class Error<T> extends Result<T> {
  const Error(this.failure);
  final Failure failure;
}

// Extension methods for Result
extension ResultExtension<T> on Result<T> {
  bool get isSuccess => this is Success<T>;
  bool get isError => this is Error<T>;
  
  T? get data => isSuccess ? (this as Success<T>).data : null;
  Failure? get failure => isError ? (this as Error<T>).failure : null;
  
  R fold<R>(R Function(Failure) onError, R Function(T) onSuccess) {
    return switch (this) {
      Success<T>() => onSuccess((this as Success<T>).data),
      Error<T>() => onError((this as Error<T>).failure),
    };
  }
}
```

## Logging System

```dart
// utils/logger.dart
class Logger {
  static const String _logTag = 'MyApp';
  
  static void debug(String message, [String? tag]) {
    if (kDebugMode) {
      developer.log(
        message,
        name: tag ?? _logTag,
        level: 500,
      );
    }
  }

  static void info(String message, [String? tag]) {
    developer.log(
      message,
      name: tag ?? _logTag,
      level: 800,
    );
  }

  static void warning(String message, [String? tag]) {
    developer.log(
      message,
      name: tag ?? _logTag,
      level: 900,
    );
  }

  static void error(String message, [Object? error, StackTrace? stackTrace, String? tag]) {
    developer.log(
      message,
      name: tag ?? _logTag,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void logApiRequest(String method, String url, Map<String, dynamic>? data) {
    if (kDebugMode) {
      debug('API Request: $method $url ${data != null ? '\nData: $data' : ''}');
    }
  }

  static void logApiResponse(String url, int statusCode, dynamic data) {
    if (kDebugMode) {
      debug('API Response: $url - Status: $statusCode\nData: $data');
    }
  }
}
``` 
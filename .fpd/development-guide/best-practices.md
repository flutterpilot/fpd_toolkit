---
title: Best Practices
description: This rule outlines best practices for building robust Flutter applications. It provides standardized configurations for pubspec.yaml and analysis_options.yaml, and includes code examples for creating well-structured widgets, data models using equatable, services with comprehensive error handling, and thorough unit and widget tests.
alwaysApply: false
globs:
  - '**/*.dart'
  - '**/pubspec.yaml'
  - '**/analysis_options.yaml'
---
# Best Practices

## 1. pubspec.yaml Configuration

### Basic Template
```yaml
name: my_awesome_app
description: An amazing Flutter app that follows best practices
publish_to: none
version: 1.0.0+1

environment:
  sdk: ^3.7.0-0
  flutter: ">=3.24.0"

dependencies:
  flutter:
    sdk: flutter
  
  # UI Components
  cupertino_icons: ^1.0.3
  
  # State Management
  flutter_bloc: ^8.1.3
  provider: ^6.1.1
  
  # Navigation
  go_router: ^15.0.0
  
  # Network
  dio: ^5.4.0
  
  # Storage
  shared_preferences: ^2.2.2
  
  # Utils
  equatable: ^2.0.5

dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # Linting
  flutter_lints: ^5.0.0
  
  # Testing
  bloc_test: ^9.1.5
  mocktail: ^1.0.1
  
  # Code Generation
  build_runner: ^2.4.7
  
  # Integration Testing
  integration_test:
    sdk: flutter

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/icons/
  
  fonts:
    - family: CustomFont
      fonts:
        - asset: assets/fonts/CustomFont-Regular.ttf
        - asset: assets/fonts/CustomFont-Bold.ttf
          weight: 700
```

## 2. analysis_options.yaml Configuration

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "**/*.gr.dart"
    - build/**
  errors:
    invalid_annotation_target: ignore
    missing_required_param: error
    missing_return: error
    todo: ignore

linter:
  rules:
    # Dart Style
    - prefer_single_quotes
    - avoid_unnecessary_containers
    - prefer_const_constructors
    - prefer_const_literals_to_create_immutables
    - prefer_const_declarations
    - prefer_final_locals
    - unnecessary_const
    - unnecessary_new
    - sort_child_properties_last
    
    # Documentation
    - public_member_api_docs
    - comment_references
    
    # Design
    - prefer_relative_imports
    - avoid_print
    - avoid_web_libraries_in_flutter
    - use_key_in_widget_constructors
    - sized_box_for_whitespace
    - use_full_hex_values_for_flutter_colors
    
    # Errors
    - avoid_returning_null_for_future
    - avoid_slow_async_io
    - cancel_subscriptions
    - close_sinks
    - literal_only_boolean_expressions
    - test_types_in_equals
    - throw_in_finally
    - unnecessary_statements
    - unrelated_type_equality_checks
    - use_rethrow_when_possible
    - valid_regexps
    
    # Performance
    - avoid_function_literals_in_foreach_calls
    - prefer_for_elements_to_map_fromIterable
    - prefer_if_elements_to_conditional_expressions
    - prefer_spread_collections
```

## 3. Code Structure

### Basic Widget
```dart
import 'package:flutter/material.dart';

/// Widget that displays the user's profile
class UserProfileWidget extends StatelessWidget {
  /// Creates a new instance of [UserProfileWidget]
  const UserProfileWidget({
    required this.user,
    this.onTap,
    super.key,
  });

  /// User to display
  final User user;

  /// Callback executed when the widget is tapped
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(user.avatarUrl),
        ),
        title: Text(user.name),
        subtitle: Text(user.email),
        onTap: onTap,
      ),
    );
  }
}
```

### Data Model
```dart
import 'package:equatable/equatable.dart';

/// Represents a user in the system
class User extends Equatable {
  /// Creates a new instance of [User]
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    this.isActive = true,
  });

  /// Unique user identifier
  final String id;

  /// Full name of the user
  final String name;

  /// User's email address
  final String email;

  /// User's avatar URL
  final String avatarUrl;

  /// Indicates if the user is active
  final bool isActive;

  /// Creates a copy of the user with updated fields
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Converts the user to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'is_active': isActive,
    };
  }

  /// Creates a user from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [id, name, email, avatarUrl, isActive];

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, '
        'avatarUrl: $avatarUrl, isActive: $isActive)';
  }
}
```

### Service with Error Handling
```dart
import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';

/// Custom exception for API errors
class ApiException implements Exception {
  /// Creates a new instance of [ApiException]
  const ApiException(this.message, [this.statusCode]);

  /// Error message
  final String message;

  /// HTTP status code (optional)
  final int? statusCode;

  @override
  String toString() => 'ApiException: $message';
}

/// Service to handle user operations
class UserService {
  /// Creates a new instance of [UserService]
  UserService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  /// Gets all users
  Future<List<User>> getUsers() async {
    try {
      final response = await _dio.get('/users');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((json) => User.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw ApiException(
          'Failed to fetch users',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ApiException(_handleDioError(e));
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  /// Gets a user by ID
  Future<User> getUserById(String id) async {
    try {
      final response = await _dio.get('/users/$id');
      
      if (response.statusCode == 200) {
        return User.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ApiException(
          'User not found',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ApiException(_handleDioError(e));
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  /// Creates a new user
  Future<User> createUser(User user) async {
    try {
      final response = await _dio.post(
        '/users',
        data: user.toJson(),
      );
      
      if (response.statusCode == 201) {
        return User.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ApiException(
          'Failed to create user',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ApiException(_handleDioError(e));
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout';
      case DioExceptionType.sendTimeout:
        return 'Send timeout';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout';
      case DioExceptionType.badResponse:
        return 'Server error: ${e.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      case DioExceptionType.connectionError:
        return 'Connection error';
      case DioExceptionType.unknown:
        return 'Unknown error: ${e.message}';
      default:
        return 'Network error';
    }
  }
}
```

## 4. Testing

### Unit Test
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';

import '../lib/models/user.dart';
import '../lib/services/user_service.dart';

class MockDio extends Mock implements Dio {}

void main() {
  group('UserService', () {
    late UserService userService;
    late MockDio mockDio;

    setUp(() {
      mockDio = MockDio();
      userService = UserService(dio: mockDio);
    });

    group('getUsers', () {
      test('should return list of users when API call is successful', () async {
        // Arrange
        const mockUsers = [
          {
            'id': '1',
            'name': 'John Doe',
            'email': 'john@example.com',
            'avatar_url': 'https://example.com/avatar.jpg',
            'is_active': true,
          }
        ];

        when(() => mockDio.get('/users')).thenAnswer(
          (_) async => Response(
            data: mockUsers,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/users'),
          ),
        );

        // Act
        final result = await userService.getUsers();

        // Assert
        expect(result, isA<List<User>>());
        expect(result, hasLength(1));
        expect(result.first.id, equals('1'));
        expect(result.first.name, equals('John Doe'));
        verify(() => mockDio.get('/users')).called(1);
      });

      test('should throw ApiException when API call fails', () async {
        // Arrange
        when(() => mockDio.get('/users')).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/users'),
            type: DioExceptionType.connectionTimeout,
          ),
        );

        // Act & Assert
        expect(
          () => userService.getUsers(),
          throwsA(isA<ApiException>()),
        );
      });
    });
  });
}
```

### Widget Test
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/models/user.dart';
import '../lib/widgets/user_profile_widget.dart';

void main() {
  group('UserProfileWidget', () {
    const testUser = User(
      id: '1',
      name: 'John Doe',
      email: 'john@example.com',
      avatarUrl: 'https://example.com/avatar.jpg',
    );

    testWidgets('should display user information', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserProfileWidget(user: testUser),
          ),
        ),
      );

      // Assert
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('john@example.com'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (tester) async {
      // Arrange
      bool wasTapped = false;
      void handleTap() {
        wasTapped = true;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserProfileWidget(
              user: testUser,
              onTap: handleTap,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(ListTile));
      await tester.pump();

      // Assert
      expect(wasTapped, isTrue);
    });
  });
}
``` 
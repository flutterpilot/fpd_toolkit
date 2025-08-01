---
title: Fundamentals
description: This rule establishes the foundational principles for Dart and Flutter development. It details core design principles such as simplicity and maintainability, and defines strict naming conventions for packages, files, classes, methods, and variables to ensure code consistency and readability across projects.
alwaysApply: false
globs:
  - '**/*.dart'
  - '**/pubspec.yaml'
---
# Fundamentals

## Design Principles

1. **Simplicity**: Code should be clear and easy to understand
2. **Reusability**: Create reusable components
3. **Performance**: Optimize for performance from the start
4. **Maintainability**: Write code that is easy to maintain
5. **Testability**: Design with testing in mind

## Naming Conventions

### Packages and Files
```dart
// ✅ Correct - snake_case
my_awesome_package
user_profile_widget.dart
authentication_service.dart

// ❌ Incorrect
MyAwesomePackage
userProfileWidget.dart
AuthenticationService.dart
```

### Classes and Types
```dart
// ✅ Correct - PascalCase
class UserProfileWidget extends StatelessWidget {}
abstract class DatabaseService {}
enum ConnectionStatus { connected, disconnected }

// ❌ Incorrect
class userProfileWidget {}
class database_service {}
```

### Variables and Methods
```dart
// ✅ Correct - camelCase
String userName = 'John';
void fetchUserData() {}
final int maxRetries = 3;

// ❌ Incorrect
String user_name = 'John';
void FetchUserData() {}
final int MAX_RETRIES = 3;
```

### Constants
```dart
// ✅ Correct - lowerCamelCase for local constants
const int defaultTimeout = 30;
const String apiBaseUrl = 'https://api.example.com';

// ✅ Correct - SCREAMING_SNAKE_CASE for global constants
static const int MAX_RETRY_ATTEMPTS = 3;
static const String DEFAULT_USER_AGENT = 'MyApp/1.0';
``` 
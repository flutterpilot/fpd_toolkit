---
title: Testing and Quality Assurance
description: This rule establishes a comprehensive strategy for testing and quality assurance in Flutter projects. It covers the testing pyramid, provides setup utilities for tests, includes examples for integration tests, explains how to generate coverage reports, and provides a template for a CI pipeline using GitHub Actions.
alwaysApply: false
globs:
  - '**/test/**'
  - '**/integration_test/**'
  - '**/lib/**'
  - '**/pubspec.yaml'
---
# Testing and Quality Assurance

## Testing Strategy

### 1. Testing Pyramid

```
    /\
   /  \      E2E Tests (Integration)
  /____\     Widget Tests
 /      \    Unit Tests
/__________\

```

### 2. Testing Setup

**test/test_utils.dart:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Utilities for testing
class TestUtils {
  /// Creates a MaterialApp for widget testing
  static Widget createTestApp(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
  }

  /// Pump widget with MaterialApp wrapper
  static Future<void> pumpWithMaterial(
  WidgetTester tester,
  Widget widget,
  ) async {
  await tester.pumpWidget(createTestApp(widget));
  }

  /// Waits for an animation to complete
  static Future<void> pumpAndSettle(WidgetTester tester) async {
  await tester.pumpAndSettle(const Duration(milliseconds: 100));
  }
}

/// Custom matcher to verify types
Matcher isInstanceOf<T>() => TypeMatcher<T>();
```

### 3. Integration Tests

**integration_test/app_test.dart:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:my_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
  testWidgets('complete user flow', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Verify initial screen
    expect(find.text('Welcome'), findsOneWidget);

    // Navigate to user list
    await tester.tap(find.byKey(const Key('users_button')));
    await tester.pumpAndSettle();

    // Verify user list
    expect(find.byType(ListView), findsOneWidget);

    // Tap first user
    await tester.tap(find.byType(ListTile).first);
    await tester.pumpAndSettle();

    // Verify user details
    expect(find.text('User Details'), findsOneWidget);
  });
  });
}
```

## Coverage Reports

```bash
# Install lcov (macOS)
brew install lcov

# Run tests with coverage
flutter test --coverage

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Open report
open coverage/html/index.html
```

## Continuous Integration

**.github/workflows/ci.yml:**
```yaml
name: CI

on:
  push:
  branches: [ main, develop ]
  pull_request:
  branches: [ main ]

jobs:
  test:
  runs-on: ubuntu-latest

  steps:
  - uses: actions/checkout@v4
  
  - name: Setup Flutter
    uses: subosito/flutter-action@v2
    with:
    flutter-version: '3.24.0'
  
  - name: Install dependencies
    run: flutter pub get
  
  - name: Analyze code
    run: flutter analyze
  
  - name: Check formatting
    run: dart format --set-exit-if-changed .
  
  - name: Run tests
    run: flutter test --coverage
  
  - name: Upload coverage to Codecov
    uses: codecov/codecov-action@v3
    with:
    file: coverage/lcov.info

  build:
  runs-on: ubuntu-latest
  needs: test

  steps:
  - uses: actions/checkout@v4
  
  - name: Setup Flutter
    uses: subosito/flutter-action@v2
    with:
    flutter-version: '3.24.0'
  
  - name: Install dependencies
    run: flutter pub get
  
  - name: Build APK
    run: flutter build apk --debug
  
  - name: Build iOS (no signing)
    run: flutter build ios --no-codesign
    if: runner.os == 'macOS'
``` 
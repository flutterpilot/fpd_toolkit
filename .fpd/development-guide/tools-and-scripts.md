---
title: Tools and Scripts
description: This rule provides a set of powerful tools and scripts to automate and streamline the development workflow. It includes a Dart script for initial project setup, a versatile Makefile for common commands like building and testing, and a pre-commit Git hook to enforce code quality standards.
alwaysApply: false
globs:
  - '**/tool/**'
  - '**/Makefile'
  - '**/.git/hooks/'
  - '**/.github/**'
---
# Tools and Scripts

## Initial Setup Script

**tool/setup.dart:**
```dart
#!/usr/bin/env dart

import 'dart:io';

Future<void> main() async {
  print('🚀 Setting up Flutter project...\n');
  
  // Install global tools
  await _runCommand('dart pub global activate pana');
  await _runCommand('dart pub global activate dart_code_metrics');
  await _runCommand('dart pub global activate very_good_cli');
  
  // Install dependencies
  await _runCommand('flutter pub get');
  
  // Generate code if necessary
  if (File('build.yaml').existsSync()) {
    await _runCommand('dart run build_runner build --delete-conflicting-outputs');
  }
  
  // Run initial analysis
  await _runCommand('flutter analyze');
  
  // Run tests
  await _runCommand('flutter test');
  
  print('\n✅ Project successfully configured!');
  print('📋 Next steps:');
  print('   - Review analysis_options.yaml');
  print('   - Set up your IDE');
  print('   - Start developing! 🎉');
}

Future<void> _runCommand(String command) async {
  print('Running: $command');
  
  final parts = command.split(' ');
  final result = await Process.run(
    parts.first,
    parts.skip(1).toList(),
    runInShell: true,
  );
  
  if (result.exitCode != 0) {
    print('❌ Error running: $command');
    print(result.stderr);
  } else {
    print('✅ Completed: $command\n');
  }
}
```

## Makefile for Common Commands

**Makefile:**
```makefile
.PHONY: help setup clean build test analyze format coverage doctor

help: ## Show help
  @grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

setup: ## Initial project setup
  @dart tool/setup.dart

clean: ## Clean generated files
  @flutter clean
  @dart run build_runner clean

build: ## Build the application
  @flutter build apk
  @flutter build ios --no-codesign

test: ## Run all tests
  @flutter test --coverage

analyze: ## Run static analysis
  @flutter analyze
  @dart run dart_code_metrics:metrics analyze lib

format: ## Format code
  @dart format --set-exit-if-changed .

coverage: ## Generate coverage report
  @flutter test --coverage
  @genhtml coverage/lcov.info -o coverage/html
  @open coverage/html/index.html

doctor: ## Check Flutter setup
  @flutter doctor -v

deps: ## Update dependencies
  @flutter pub upgrade
  @flutter pub get

generate: ## Generate code
  @dart run build_runner build --delete-conflicting-outputs

publish-dry: ## Simulate publishing
  @dart pub publish --dry-run

publish: ## Publish to pub.dev
  @dart pub publish

version-patch: ## Increment patch version
  @dart tool/version_bump.dart patch

version-minor: ## Increment minor version
  @dart tool/version_bump.dart minor

version-major: ## Increment major version
  @dart tool/version_bump.dart major
```

## Pre-commit Script

**.git/hooks/pre-commit:**
```bash
#!/bin/sh

echo "🔍 Running pre-commit hooks..."

# Format code
echo "📝 Formatting code..."
dart format --set-exit-if-changed .
if [ $? -ne 0 ]; then
  echo "❌ Code formatting failed"
  exit 1
fi

# Static analysis
echo "🔬 Running static analysis..."
flutter analyze
if [ $? -ne 0 ]; then
  echo "❌ Static analysis failed"
  exit 1
fi

# Tests
echo "🧪 Running tests..."
flutter test
if [ $? -ne 0 ]; then
  echo "❌ Tests failed"
  exit 1
fi

echo "✅ Pre-commit hooks completed successfully!"
``` 
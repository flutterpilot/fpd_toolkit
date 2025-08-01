---
title: Maintenance and Versioning
description: This rule outlines best practices for maintaining and versioning Dart and Flutter projects. It explains Semantic Versioning (Major, Minor, Patch), provides a standard CHANGELOG.md template based on Keep a Changelog, and includes a reusable Dart script to automate version bumping.
alwaysApply: false
globs:
  - '**/pubspec.yaml'
  - '**/CHANGELOG.md'
  - '**/*.md'
---
# Maintenance and Versioning

## Semantic Versioning

Follow [Semantic Versioning](https://semver.org/):

- **MAJOR** (1.0.0): Incompatible API changes
- **MINOR** (0.1.0): New backwards-compatible functionality
- **PATCH** (0.0.1): Backwards-compatible bug fixes

### Examples:
- `1.0.0` → `1.0.1`: Bug fix
- `1.0.0` → `1.1.0`: New functionality
- `1.0.0` → `2.0.0`: Breaking change

## CHANGELOG.md Template

```markdown
## Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

### [Unreleased]

#### Added
- New functionality pending release

#### Changed
- Changes to existing functionality

#### Deprecated
- Functionality to be removed

#### Removed
- Functionality removed

#### Fixed
- Bug fixes

#### Security
- Security updates

### [1.2.0] - 2024-01-15

#### Added
- Dark mode support
- New API for advanced configuration
- Documentation for additional examples

#### Changed
- Improved cache performance
- Updated configuration UI

#### Fixed
- Fixed crash when closing the app
- Resolved memory issue on iOS

### [1.1.0] - 2023-12-10

#### Added
- OAuth authentication support
- New customizable themes

#### Fixed
- Fixed sync issue
- Improved stability on Android

### [1.0.0] - 2023-11-01

#### Added
- Initial release
- Complete core functionality
- Basic documentation
- Unit and integration tests

[Unreleased]: https://github.com/usuario/proyecto/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/usuario/proyecto/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/usuario/proyecto/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/usuario/proyecto/releases/tag/v1.0.0
```

## Automation Scripts

**tool/version_bump.dart:**
```dart
#!/usr/bin/env dart

import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart tool/version_bump.dart <major|minor|patch>');
    exit(1);
  }

  final type = args[0];
  final pubspecFile = File('pubspec.yaml');
  
  if (!pubspecFile.existsSync()) {
    print('pubspec.yaml not found');
    exit(1);
  }

  final content = pubspecFile.readAsStringSync();
  final versionRegex = RegExp(r'version:\s*(\d+)\.(\d+)\.(\d+)(\+\d+)?');
  final match = versionRegex.firstMatch(content);
  
  if (match == null) {
    print('Version not found in pubspec.yaml');
    exit(1);
  }

  var major = int.parse(match.group(1)!);
  var minor = int.parse(match.group(2)!);
  var patch = int.parse(match.group(3)!);
  final buildNumber = match.group(4) ?? '+1';

  switch (type) {
    case 'major':
      major++;
      minor = 0;
      patch = 0;
      break;
    case 'minor':
      minor++;
      patch = 0;
      break;
    case 'patch':
      patch++;
      break;
    default:
      print('Invalid version type: $type');
      exit(1);
  }

  final newVersion = '$major.$minor.$patch$buildNumber';
  final newContent = content.replaceFirst(versionRegex, 'version: $newVersion');
  
  pubspecFile.writeAsStringSync(newContent);
  print('Version updated to: $newVersion');
}
``` 
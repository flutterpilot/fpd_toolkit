---
title: Project Structure
description: This rule defines the standard project structure for different types of Dart and Flutter projects. It provides clear, scalable directory layouts for a standard Flutter application, a Flutter plugin, and a pure Dart package, promoting organization and maintainability from the start.
alwaysApply: false
globs:
  - '**/pubspec.yaml'
  - '**/lib/**'
  - '**/README.md'
---
# Project Structure

## Standard Flutter Application

```
my_flutter_app/
├── 📄 pubspec.yaml
├── 📄 README.md
├── 📄 CHANGELOG.md
├── 📄 LICENSE
├── 📄 analysis_options.yaml
├── 📄 .gitignore
├── 📁 lib/
│   ├── 📄 main.dart
│   ├── 📁 core/
│   │   ├── 📁 constants/
│   │   ├── 📁 exceptions/
│   │   ├── 📁 extensions/
│   │   └── 📁 utils/
│   ├── 📁 data/
│   │   ├── 📁 datasources/
│   │   ├── 📁 models/
│   │   └── 📁 repositories/
│   ├── 📁 domain/
│   │   ├── 📁 entities/
│   │   ├── 📁 repositories/
│   │   └── 📁 usecases/
│   ├── 📁 presentation/
│   │   ├── 📁 pages/
│   │   ├── 📁 widgets/
│   │   └── 📁 providers/
│   └── 📁 services/
├── 📁 test/
│   ├── 📁 unit/
│   ├── 📁 widget/
│   └── 📁 integration/
├── 📁 assets/
│   ├── 📁 images/
│   ├── 📁 icons/
│   └── 📁 fonts/
└── 📁 docs/
    ├── 📄 api.md
    └── 📄 architecture.md
```

## Flutter Plugin

```
my_flutter_plugin/
├── 📄 pubspec.yaml
├── 📄 README.md
├── 📄 CHANGELOG.md
├── 📄 LICENSE
├── 📄 analysis_options.yaml
├── 📁 lib/
│   ├── 📄 my_plugin.dart
│   └── 📁 src/
│       ├── 📄 my_plugin_platform_interface.dart
│       ├── 📄 my_plugin_method_channel.dart
│       └── 📄 my_plugin_web.dart
├── 📁 android/
│   └── 📁 src/main/java/
├── 📁 ios/
│   └── 📁 Classes/
├── 📁 web/
├── 📁 example/
│   ├── 📄 pubspec.yaml
│   └── 📁 lib/
├── 📁 test/
└── 📁 pigeons/
    └── 📄 messages.dart
```

## Dart Package

```
my_dart_package/
├── 📄 pubspec.yaml
├── 📄 README.md
├── 📄 CHANGELOG.md
├── 📄 LICENSE
├── 📄 analysis_options.yaml
├── 📁 lib/
│   ├── 📄 my_package.dart
│   └── 📁 src/
│       ├── 📄 models/
│       ├── 📄 services/
│       └── 📄 utils/
├── 📁 test/
├── 📁 example/
└── 📁 tool/
``` 
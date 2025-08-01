---
title: Environment Setup
description: This rule provides a standardized guide for setting up a Flutter and Dart development environment. It includes commands to verify installation, a list of recommended global tools like pana and very_good_cli, and a curated list of VS Code extensions and settings to ensure a consistent and productive workflow.
alwaysApply: false
globs:
  - '**/pubspec.yaml'
  - '**/analysis_options.yaml'
  - '**/*.md'
---
# Environment Setup

## Required SDKs and Tools

```bash
# Verify installation
flutter doctor -v
dart --version

# Recommended global tools
dart pub global activate pana                # Package analysis
dart pub global activate dart_code_metrics   # Code metrics
dart pub global activate very_good_cli       # Project CLI
```

## Editor Setup

### VS Code Extensions
- Dart
- Flutter
- Bracket Pair Colorizer
- GitLens
- Error Lens
- Flutter Tree
- Pubspec Assist

### VS Code Configuration (`settings.json`)
```json
{
  "dart.previewFlutterUiGuides": true,
  "dart.previewFlutterUiGuidesCustomTracking": true,
  "dart.closingLabels": true,
  "dart.showMainCodeLens": false,
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true,
    "source.organizeImports": true
  },
  "dart.lineLength": 80
}
``` 
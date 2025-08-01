---
title: Publishing on pub.dev
description: This rule is a comprehensive guide to publishing a package on pub.dev. It details how to prepare pubspec.yaml metadata, craft a professional README.md, validate the package using pana and other tools, and meet the quality criteria required for a high score on the platform.
alwaysApply: false
globs:
  - "**/pubspec.yaml"
  - "**/README.md"
  - "**/CHANGELOG.md"
  - "**/LICENSE"
  - "**/analysis_options.yaml"
  - "**/example/**"
  - "**/lib/**"
  - "**/test/**"
---
# Publishing on pub.dev

## Preparation for Publishing

### 1. Complete metadata in pubspec.yaml
```yaml
name: my_awesome_package
description: An awesome package that does awesome things in an awesome way
version: 1.0.0
homepage: https://github.com/user/my_awesome_package
repository: https://github.com/user/my_awesome_package
issue_tracker: https://github.com/user/my_awesome_package/issues
documentation: https://pub.dev/documentation/my_awesome_package/latest/

environment:
  sdk: ^3.7.0-0
  flutter: ">=3.24.0"

# Remove publish_to: none when ready to publish
# publish_to: none
```

### 2. Create complete documentation

**README.md Template:**
```markdown
## 📦 My Awesome Package

[![pub package](https://img.shields.io/pub/v/my_awesome_package.svg)](https://pub.dev/packages/my_awesome_package)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A concise and clear description of what your package does.

### ✨ Features

- 🚀 Fast and efficient
- 📱 Multiplatform support
- 🎨 Highly customizable
- 🧪 Fully tested

### 📥 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  my_awesome_package: ^1.0.0
```

Then run:

```bash
flutter pub get
```

### 🚀 Basic Usage

```dart
import 'package:my_awesome_package/my_awesome_package.dart';

void main() {
  final awesome = AwesomeClass();
  awesome.doSomethingAwesome();
}
```

### 📖 Documentation

#### API Reference

Check the [full documentation](https://pub.dev/documentation/my_awesome_package/latest/) for API details.

#### Examples

See the [example/](example/) folder for complete examples.

### 🤝 Contributing

Contributions are welcome! Please:

1. Fork the project
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### 🙋‍♂️ Support

If you have questions or issues:

- 📧 Email: your-email@example.com
- 🐛 Issues: [GitHub Issues](https://github.com/user/my_awesome_package/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/user/my_awesome_package/discussions)
```

### 3. Pre-publish Validation

```bash
# Analyze the package
dart pub global run pana .

# Check formatting
dart format --set-exit-if-changed .

# Run static analysis
dart analyze

# Run tests
flutter test

# Validate pubspec
dart pub publish --dry-run
```

### 4. Publish

```bash
# Publish to pub.dev
dart pub publish
```

## pub.dev Quality Criteria

To achieve the highest score on pub.dev, make sure to:

### ✅ Required Files
- [x] Complete and valid `pubspec.yaml`
- [x] Descriptive `README.md` with examples
- [x] `CHANGELOG.md` with version history
- [x] `LICENSE` with OSI license
- [x] Configured `analysis_options.yaml`

### ✅ Documentation (20+ points)
- [x] At least 20% of public APIs documented
- [x] Code examples in README
- [x] `example/` folder with functional project

### ✅ Platform Support (10+ points)
- [x] Multiplatform support when applicable
- [x] Correct platform declaration in pubspec.yaml

### ✅ Static Analysis (30+ points)
- [x] No analysis errors
- [x] Use of standard lints
- [x] Code follows Dart conventions

### ✅ Updated Dependencies (10+ points)
- [x] Updated SDK constraints
- [x] Recent dependency versions
- [x] No obsolete dependencies
``` 
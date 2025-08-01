# FPD Toolkit Examples

This directory contains examples demonstrating how to use FPD Toolkit both as a CLI tool and programmatically.

## Running the Example

To run the main example:

```bash
dart run example/fpd_toolkit_example.dart
```

## CLI Usage Examples

### Basic Package Creation

```bash
# Create a Dart package
fpd-toolkit create package my_package --description "My awesome package"

# Create a Flutter application
fpd-toolkit create app my_app --description "My Flutter application"

# Create a Flutter plugin
fpd-toolkit create plugin my_plugin --platforms android,ios --description "My plugin"
```

### Package Validation

```bash
# Validate a package for pub.dev scoring
fpd-toolkit validate my_package
```

### Interactive Guides

```bash
# List all available guides
fpd-toolkit guide --list

# Access specific guides
fpd-toolkit guide best-practices architecture-structure
fpd-toolkit guide development-guide testing-and-quality-assurance
```

### Code Examples

```bash
# View widget examples
fpd-toolkit example widget

# View state management examples
fpd-toolkit example state

# View testing examples
fpd-toolkit example testing
```

## Programmatic Usage

You can also use FPD Toolkit programmatically in your Dart applications:

```dart
import 'package:fpd_toolkit/fpd_toolkit.dart';

Future<void> main() async {
  // Create a package programmatically
  await FpdToolkit.run([
    'create',
    'package',
    'my_package',
    '--description',
    'Created programmatically'
  ]);
}
```

## Advanced Examples

### Cross-Platform Plugin

```bash
fpd-toolkit create plugin cross_platform_plugin \
  --platforms android,ios,web,windows,macos,linux \
  --description "Universal cross-platform plugin"
```

### Custom Template Usage

```bash
fpd-toolkit create package custom_package \
  --template ~/my_templates/custom_template \
  --description "Package with custom template"
```

### Validation with Detailed Output

```bash
fpd-toolkit validate my_package --verbose
```

## Best Practices

1. Always validate your packages before publishing
2. Use descriptive package names and descriptions
3. Follow the interactive guides for best practices
4. Run tests after package generation
5. Check pub.dev scoring with `dart pub publish --dry-run`

For more information, see the main [README.md](../README.md) file.
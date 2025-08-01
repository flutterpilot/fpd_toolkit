import 'dart:io';
import 'package:args/args.dart';
import 'package:yaml/yaml.dart';
import 'base_command.dart';
import '../utils/logger.dart';
import '../utils/interactive_prompt.dart';

/// Command to validate existing packages
class ValidateCommand extends Command {
  late final ArgParser _argParser;

  ValidateCommand() {
    _argParser = ArgParser()
      ..addFlag(
        'strict',
        abbr: 's',
        negatable: false,
        help: 'Validación estricta (más estricto que pub.dev)',
      )
      ..addFlag(
        'fix',
        abbr: 'f',
        negatable: false,
        help: 'Intenta arreglar problemas automáticamente',
      )
      ..addFlag(
        'non-interactive',
        negatable: false,
        help: 'Run in non-interactive mode',
      )
      ..addFlag(
        'help',
        abbr: 'h',
        negatable: false,
        help: 'Show help for this command',
      );
  }

  @override
  String get name => 'validate';

  @override
  String get description => 'Validate an existing Flutter/Dart package';

  @override
  ArgParser get argParser => _argParser;

  @override
  Future<void> run(ArgResults argResults) async {
    if (argResults['help'] as bool) {
      showHelp();
      return;
    }

    final isNonInteractive = argResults['non-interactive'] as bool;
    final args = argResults.rest;
    String packagePath;
    
    if (args.isNotEmpty) {
      packagePath = args[0];
    } else {
      if (isNonInteractive) {
        packagePath = '.';
      } else {
        packagePath = InteractivePrompt.promptText(
          question: 'Package directory to validate',
          defaultValue: '.',
          required: true,
        ) ?? '.';
      }
    }

    final packageDir = Directory(packagePath);
    if (!packageDir.existsSync()) {
      if (isNonInteractive) {
        Logger.error('❌ Directory not found: $packagePath');
        return;
      }
      
      Logger.error('❌ Directory not found: $packagePath');
      final shouldContinue = InteractivePrompt.promptConfirm(
        question: 'Would you like to select a different directory?',
        defaultValue: true,
      );
      
      if (!shouldContinue) {
        return;
      }
      
      packagePath = InteractivePrompt.promptText(
        question: 'Package directory to validate',
        defaultValue: '.',
        required: true,
      ) ?? '.';
      
      final newPackageDir = Directory(packagePath);
      if (!newPackageDir.existsSync()) {
        Logger.error('❌ Directory not found: $packagePath');
        return;
      }
    }

    final strict = argResults['strict'] as bool;
    final fix = argResults['fix'] as bool;

    Logger.info('🔍 Validating package in: ${packageDir.path}');
    
    final issues = <ValidationIssue>[];
    
    // Validar archivos requeridos
    await _validateRequiredFiles(packageDir, issues, fix);
    
    // Validar pubspec.yaml
    await _validatePubspec(packageDir, issues, strict, fix);
    
    // Validar estructura de directorios
    await _validateDirectoryStructure(packageDir, issues, fix);
    
    // Validar documentación
    await _validateDocumentation(packageDir, issues, strict, fix);
    
    // Mostrar resultados
    _showResults(issues, packagePath);
  }

  Future<void> _validateRequiredFiles(Directory packageDir, List<ValidationIssue> issues, bool fix) async {
    final requiredFiles = ['pubspec.yaml', 'README.md', 'CHANGELOG.md', 'LICENSE'];
    
    for (final fileName in requiredFiles) {
      final file = File('${packageDir.path}/$fileName');
      if (!file.existsSync()) {
        issues.add(ValidationIssue(
          type: IssueType.error,
          message: 'Missing file: $fileName',
          file: fileName,
          fixable: fix && fileName != 'pubspec.yaml',
        ));
        
        if (fix && fileName != 'pubspec.yaml') {
          await _createMissingFile(packageDir, fileName);
          Logger.info('🔧 Created missing file: $fileName');
        }
      } else {
        Logger.success('✅ $fileName found');
      }
    }
  }

  Future<void> _validatePubspec(Directory packageDir, List<ValidationIssue> issues, bool strict, bool fix) async {
    final pubspecFile = File('${packageDir.path}/pubspec.yaml');
    if (!pubspecFile.existsSync()) {
      return;
    }

    try {
      final content = await pubspecFile.readAsString();
      final yaml = loadYaml(content) as Map;

      // Validaciones básicas
      _checkPubspecField(yaml, 'name', issues, true);
      _checkPubspecField(yaml, 'description', issues, true);
      _checkPubspecField(yaml, 'version', issues, true);
      _checkPubspecField(yaml, 'environment', issues, true);

      // Validaciones estrictas
      if (strict) {
        _checkPubspecField(yaml, 'homepage', issues, false);
        _checkPubspecField(yaml, 'repository', issues, false);
        _checkPubspecField(yaml, 'issue_tracker', issues, false);
        _checkPubspecField(yaml, 'documentation', issues, false);
      }

      // Validar versión semántica
      if (yaml.containsKey('version')) {
        final version = yaml['version'].toString();
        if (!_isValidSemanticVersion(version)) {
          issues.add(ValidationIssue(
            type: IssueType.warning,
            message: 'Version does not follow semantic versioning: $version',
            file: 'pubspec.yaml',
          ));
        }
      }

      // Validar publish_to
      if (!yaml.containsKey('publish_to') || yaml['publish_to'] != 'none') {
        issues.add(ValidationIssue(
          type: IssueType.warning,
          message: 'Consider using "publish_to: none" to avoid accidental publication',
          file: 'pubspec.yaml',
        ));
      }

      Logger.success('✅ pubspec.yaml validated');

    } catch (e) {
      issues.add(ValidationIssue(
        type: IssueType.error,
        message: 'Error reading pubspec.yaml: $e',
        file: 'pubspec.yaml',
      ));
    }
  }

  Future<void> _validateDirectoryStructure(Directory packageDir, List<ValidationIssue> issues, bool fix) async {
    // Validar lib/
    final libDir = Directory('${packageDir.path}/lib');
    if (!libDir.existsSync()) {
      issues.add(ValidationIssue(
        type: IssueType.error,
        message: 'Missing directory: lib/',
        file: 'lib/',
        fixable: fix,
      ));
      
      if (fix) {
        await libDir.create();
        Logger.info('🔧 Created directory: lib/');
      }
    } else {
      // Buscar archivo principal
      final pubspecFile = File('${packageDir.path}/pubspec.yaml');
      if (pubspecFile.existsSync()) {
        try {
          final content = await pubspecFile.readAsString();
          final yaml = loadYaml(content) as Map;
          
          if (yaml.containsKey('name')) {
            final packageName = yaml['name'].toString();
            final mainFile = File('${packageDir.path}/lib/$packageName.dart');
            
            if (!mainFile.existsSync()) {
              issues.add(ValidationIssue(
                type: IssueType.error,
                message: 'Missing main file: lib/$packageName.dart',
                file: 'lib/$packageName.dart',
                fixable: fix,
              ));
              
              if (fix) {
                await _createMainLibraryFile(packageDir, packageName);
                Logger.info('🔧 Created main file: lib/$packageName.dart');
              }
            } else {
              Logger.success('✅ Main file found: lib/$packageName.dart');
            }
          }
        } catch (e) {
          // Ignorar errores de YAML, ya se validan en otro lugar
        }
      }
    }

    // Validar test/
    final testDir = Directory('${packageDir.path}/test');
    if (!testDir.existsSync()) {
      issues.add(ValidationIssue(
        type: IssueType.warning,
        message: 'Recommended directory missing: test/',
        file: 'test/',
        fixable: fix,
      ));
      
      if (fix) {
        await testDir.create();
        await _createBasicTestFile(packageDir);
        Logger.info('🔧 Created directory: test/ with basic test');
      }
    } else {
      Logger.success('✅ Directory test/ found');
    }

    Logger.success('✅ Directory structure validated');
  }

  Future<void> _validateDocumentation(Directory packageDir, List<ValidationIssue> issues, bool strict, bool fix) async {
    // Validar README.md
    final readmeFile = File('${packageDir.path}/README.md');
    if (readmeFile.existsSync()) {
      final content = await readmeFile.readAsString();
      
      if (content.length < 100) {
        issues.add(ValidationIssue(
          type: IssueType.warning,
          message: 'README.md too short, consider adding more information',
          file: 'README.md',
        ));
      }
      
      if (!content.contains('##') && !content.contains('#')) {
        issues.add(ValidationIssue(
          type: IssueType.warning,
          message: 'README.md without sections, consider adding headers',
          file: 'README.md',
        ));
      }
      
      if (strict && !content.contains('```')) {
        issues.add(ValidationIssue(
          type: IssueType.warning,
          message: 'README.md without code examples',
          file: 'README.md',
        ));
      }
    }

    // Validar analysis_options.yaml
    final analysisFile = File('${packageDir.path}/analysis_options.yaml');
    if (!analysisFile.existsSync()) {
      issues.add(ValidationIssue(
        type: IssueType.warning,
        message: 'Recommended file missing: analysis_options.yaml',
        file: 'analysis_options.yaml',
        fixable: fix,
      ));
      
      if (fix) {
        await _createAnalysisOptionsFile(packageDir);
        Logger.info('🔧 Created: analysis_options.yaml');
      }
    }
  }

  void _checkPubspecField(Map yaml, String field, List<ValidationIssue> issues, bool required) {
    if (!yaml.containsKey(field)) {
      issues.add(ValidationIssue(
        type: required ? IssueType.error : IssueType.warning,
        message: 'pubspec.yaml: Missing field "$field"',
        file: 'pubspec.yaml',
      ));
    }
  }

  bool _isValidSemanticVersion(String version) {
    final regex = RegExp(r'^\d+\.\d+\.\d+(\+\d+)?(-[\w\.-]+)?$');
    return regex.hasMatch(version);
  }

  Future<void> _createMissingFile(Directory packageDir, String fileName) async {
    final file = File('${packageDir.path}/$fileName');
    
    switch (fileName) {
      case 'README.md':
        await file.writeAsString(_getReadmeTemplate());
        break;
      case 'CHANGELOG.md':
        await file.writeAsString(_getChangelogTemplate());
        break;
      case 'LICENSE':
        await file.writeAsString(_getLicenseTemplate());
        break;
    }
  }

  Future<void> _createMainLibraryFile(Directory packageDir, String packageName) async {
    final file = File('${packageDir.path}/lib/$packageName.dart');
    await file.writeAsString('''
/// $packageName - A new Flutter/Dart package
library $packageName;

export 'src/${packageName}_base.dart';
''');

    final srcDir = Directory('${packageDir.path}/lib/src');
    await srcDir.create(recursive: true);
    
    final srcFile = File('${packageDir.path}/lib/src/${packageName}_base.dart');
    await srcFile.writeAsString('''
/// Base class for $packageName
class ${_toPascalCase(packageName)} {
  /// Creates a new instance of ${_toPascalCase(packageName)}
  const ${_toPascalCase(packageName)}();
  
  /// Example method
  String hello() {
    return 'Hello from $packageName!';
  }
}
''');
  }

  Future<void> _createBasicTestFile(Directory packageDir) async {
    // Intentar obtener el nombre del paquete
    String packageName = 'package';
    
    final pubspecFile = File('${packageDir.path}/pubspec.yaml');
    if (pubspecFile.existsSync()) {
      try {
        final content = await pubspecFile.readAsString();
        final yaml = loadYaml(content) as Map;
        if (yaml.containsKey('name')) {
          packageName = yaml['name'].toString();
        }
      } catch (e) {
        // Usar valor por defecto
      }
    }

    final testFile = File('${packageDir.path}/test/${packageName}_test.dart');
    await testFile.writeAsString('''
import 'package:flutter_test/flutter_test.dart';
import 'package:$packageName/$packageName.dart';

void main() {
  group('$packageName', () {
    test('should be tested', () {
      // TODO: Implement tests
      expect(true, isTrue);
    });
  });
}
''');
  }

  Future<void> _createAnalysisOptionsFile(Directory packageDir) async {
    final file = File('${packageDir.path}/analysis_options.yaml');
    await file.writeAsString('''
include: package:lints/recommended.yaml

linter:
  rules:
    - prefer_single_quotes
    - avoid_unnecessary_containers
    - prefer_const_constructors
    - prefer_const_literals_to_create_immutables
    - prefer_final_locals
    - unnecessary_const
    - unnecessary_new

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
  errors:
    missing_required_param: error
    missing_return: error
''');
  }

  String _getReadmeTemplate() {
    return '''
# Package Name

A brief description of what this package does.

## Features

- Feature 1
- Feature 2
- Feature 3

## Getting started

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  package_name: ^1.0.0
```

## Usage

```dart
import 'package:package_name/package_name.dart';

// Example usage
final example = PackageName();
example.doSomething();
```

## Additional information

Tell users more about the package: where to find more information, how to 
contribute to the package, how to file issues, what response they can expect 
from the package authors, and more.
''';
  }

  String _getChangelogTemplate() {
    return '''
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial release

## [1.0.0] - ${DateTime.now().toIso8601String().split('T')[0]}

### Added
- Initial version
''';
  }

  String _getLicenseTemplate() {
    return '''
MIT License

Copyright (c) ${DateTime.now().year} Your Name

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
''';
  }

  String _toPascalCase(String input) {
    return input.split('_').map((word) => 
      word[0].toUpperCase() + word.substring(1)).join('');
  }

  void _showResults(List<ValidationIssue> issues, String packagePath) {
    final errors = issues.where((i) => i.type == IssueType.error).length;
    final warnings = issues.where((i) => i.type == IssueType.warning).length;

    if (issues.isEmpty) {
      Logger.success('\n✅ Valid package! Follows best practices.');
      Logger.info('\n📋 Additional recommendations:');
      Logger.info('   - Run "dart pub deps" to verify dependencies');
      Logger.info('   - Run "dart analyze" for static analysis');
      Logger.info('   - Run "dart test" to execute tests');
      Logger.info('   - Consider using "pana" for complete pub.dev analysis');
    } else {
      Logger.error('\n❌ Found $errors errors and $warnings warnings:');
      
      for (final issue in issues) {
        final icon = issue.type == IssueType.error ? '❌' : '⚠️';
        final fixableText = issue.fixable ? ' (auto-corregible)' : '';
        Logger.info('   $icon ${issue.message}$fixableText');
      }

      if (issues.any((i) => i.fixable)) {
        Logger.info('\n🔧 To auto-fix issues:');
        Logger.info('   fpd-toolkit validate $packagePath --fix');
      }
    }

    Logger.info('\n📈 Estimated pub.dev score:');
    final score = _calculateScore(errors, warnings);
    final scoreColor = score >= 100 ? '🟢' : score >= 80 ? '🟡' : '🔴';
    Logger.info('   $scoreColor $score/130 points');
  }

  int _calculateScore(int errors, int warnings) {
    int score = 130;
    score -= errors * 20;
    score -= warnings * 5;
    return score < 0 ? 0 : score;
  }

  @override
  void showHelp() {
    print('''
$description

Usage: fpd-toolkit validate [directory] [options]

Arguments (optional in interactive mode):
  [directory]          Package directory to validate (default: current directory)

Options:
  -s, --strict         Strict validation (stricter than pub.dev)
  -f, --fix            Attempt to automatically fix issues
      --non-interactive Run in non-interactive mode
  -h, --help           Show this help

Interactive Examples:
  fpd-toolkit validate                    # Interactive mode - asks for directory if needed
  fpd-toolkit validate ./my_package       # Validates specific directory

Non-Interactive Examples:
  fpd-toolkit validate --non-interactive  # Validates current directory
  fpd-toolkit validate ./my_package --strict --fix --non-interactive

Validation checks:
  ✅ Required files (pubspec.yaml, README.md, etc.)
  ✅ Directory structure
  ✅ pubspec.yaml metadata
  ✅ Basic documentation
  ✅ Analysis configuration

Scoring:
  🟢 100+ points: Excellent quality
  🟡 80+ points:  Good quality  
  🔴 <80 points:  Needs improvements
''');
  }
}

/// Types of validation issues
enum IssueType { error, warning }

/// Represents an issue found during validation
class ValidationIssue {
  const ValidationIssue({
    required this.type,
    required this.message,
    required this.file,
    this.fixable = false,
  });

  final IssueType type;
  final String message;
  final String file;
  final bool fixable;
}
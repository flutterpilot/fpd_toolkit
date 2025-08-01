import 'dart:io';
import 'package:args/args.dart';
import 'package:yaml/yaml.dart';
import 'base_command.dart';
import '../utils/logger.dart';
import '../utils/interactive_prompt.dart';

/// Command to initialize existing projects
class InitCommand extends Command {
  late final ArgParser _argParser;

  InitCommand() {
    _argParser = ArgParser()
      ..addFlag(
        'force',
        abbr: 'f',
        negatable: false,
        help: 'Overwrite existing files',
      )
      ..addFlag(
        'analysis',
        negatable: false,
        help: 'Configure analysis_options.yaml',
        defaultsTo: true,
      )
      ..addFlag(
        'ci',
        negatable: false,
        help: 'Configure GitHub Actions CI/CD',
        defaultsTo: true,
      )
      ..addFlag(
        'doc',
        negatable: false,
        help: 'Improve existing documentation',
        defaultsTo: true,
      )
      ..addFlag(
        'tests',
        negatable: false,
        help: 'Add basic test structure',
        defaultsTo: true,
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
  String get name => 'init';

  @override
  String get description => 'Initialize an existing Flutter/Dart project with best practices';

  @override
  ArgParser get argParser => _argParser;

  @override
  Future<void> run(ArgResults argResults) async {
    if (argResults['help'] as bool) {
      showHelp();
      return;
    }

    final isNonInteractive = argResults['non-interactive'] as bool;
    final currentDir = Directory.current;
    final pubspecFile = File('${currentDir.path}/pubspec.yaml');

    if (!pubspecFile.existsSync()) {
      Logger.error('❌ No pubspec.yaml found in current directory');
      Logger.info('   Make sure you are in the project root directory');
      return;
    }

    // Get configuration options
    final config = await _gatherInitConfiguration(argResults, isNonInteractive);
    if (config == null) {
      Logger.info('Initialization cancelled');
      return;
    }

    Logger.info('🔧 Initializing Flutter/Dart project...\n');

    try {
      // Detect project type
      final projectType = await _detectProjectType(pubspecFile);
      Logger.info('📦 Detected project type: $projectType');

      // Configure analysis_options.yaml
      if (config.setupAnalysis) {
        await _setupAnalysisOptions(currentDir, config.force, projectType);
      }

      // Configure CI/CD
      if (config.setupCI) {
        await _setupGitHubActions(currentDir, config.force, projectType);
      }

      // Improve documentation
      if (config.improveDocs) {
        await _improveDocumentation(currentDir, config.force, projectType);
      }

      // Configure tests
      if (config.setupTests) {
        await _setupTestStructure(currentDir, config.force, projectType);
      }

      // Create additional utility files
      await _createUtilityFiles(currentDir, config.force, projectType);

      Logger.success('\n✅ Project initialized successfully!');
      _showNextSteps(projectType);

    } catch (e) {
      Logger.error('❌ Error initializing project: $e');
      exit(1);
    }
  }

  /// Gather initialization configuration interactively or from arguments
  Future<InitConfig?> _gatherInitConfiguration(ArgResults argResults, bool isNonInteractive) async {
    if (!isNonInteractive) {
      InteractivePrompt.showHeader('🔧 FPD Toolkit - Project Initializer');
      InteractivePrompt.showInfo('Adding best practices to your existing Flutter/Dart project');
      print('');
    }

    // Get force flag
    bool force = argResults['force'] as bool;
    if (!force && !isNonInteractive) {
      force = InteractivePrompt.promptConfirm(
        question: 'Overwrite existing files if they exist?',
        defaultValue: false,
      );
    }

    // Get analysis setup preference
    bool setupAnalysis = argResults['analysis'] as bool;
    if (!isNonInteractive) {
      setupAnalysis = InteractivePrompt.promptConfirm(
        question: 'Configure analysis_options.yaml with best practices?',
        defaultValue: true,
      );
    }

    // Get CI/CD setup preference
    bool setupCI = argResults['ci'] as bool;
    if (!isNonInteractive) {
      setupCI = InteractivePrompt.promptConfirm(
        question: 'Configure GitHub Actions CI/CD?',
        defaultValue: true,
      );
    }

    // Get documentation improvement preference
    bool improveDocs = argResults['doc'] as bool;
    if (!isNonInteractive) {
      improveDocs = InteractivePrompt.promptConfirm(
        question: 'Improve existing documentation?',
        defaultValue: true,
      );
    }

    // Get test setup preference
    bool setupTests = argResults['tests'] as bool;
    if (!isNonInteractive) {
      setupTests = InteractivePrompt.promptConfirm(
        question: 'Add basic test structure?',
        defaultValue: true,
      );
    }

    // Show summary if interactive
    if (!isNonInteractive) {
      print('');
      InteractivePrompt.showHeader('📋 Configuration Summary');
      print('  Overwrite existing files: ${force ? "Yes" : "No"}');
      print('  Configure analysis: ${setupAnalysis ? "Yes" : "No"}');
      print('  Setup CI/CD: ${setupCI ? "Yes" : "No"}');
      print('  Improve docs: ${improveDocs ? "Yes" : "No"}');
      print('  Setup tests: ${setupTests ? "Yes" : "No"}');
      print('');

      final shouldContinue = InteractivePrompt.promptConfirm(
        question: 'Initialize project with these settings?',
        defaultValue: true,
      );

      if (!shouldContinue) {
        return null;
      }
      print('');
    }

    return InitConfig(
      force: force,
      setupAnalysis: setupAnalysis,
      setupCI: setupCI,
      improveDocs: improveDocs,
      setupTests: setupTests,
    );
  }

  Future<String> _detectProjectType(File pubspecFile) async {
    try {
      final content = await pubspecFile.readAsString();
      final yaml = loadYaml(content) as Map;

      // Verificar si es una app Flutter
      if (yaml.containsKey('flutter')) {
        final flutter = yaml['flutter'] as Map?;
        
        if (flutter?.containsKey('plugin') == true) {
          return 'flutter_plugin';
        } else if (flutter?.containsKey('module') == true) {
          return 'flutter_module';
        } else {
          return 'flutter_app';
        }
      }

      // Verificar si tiene dependencias de Flutter
      final dependencies = yaml['dependencies'] as Map?;
      if (dependencies?.containsKey('flutter') == true) {
        return 'flutter_package';
      }

      // Es un paquete Dart puro
      return 'dart_package';

    } catch (e) {
      Logger.warning('⚠️ No se pudo detectar el tipo de proyecto, asumiendo flutter_app');
      return 'flutter_app';
    }
  }

  Future<void> _setupAnalysisOptions(Directory currentDir, bool force, String projectType) async {
    final analysisFile = File('${currentDir.path}/analysis_options.yaml');
    
    if (analysisFile.existsSync() && !force) {
      Logger.info('⏭️ analysis_options.yaml ya existe (usa --force para sobrescribir)');
      return;
    }

    final isFlutterProject = projectType.startsWith('flutter');
    final content = _getAnalysisOptionsContent(isFlutterProject);
    
    await analysisFile.writeAsString(content);
    Logger.success('✅ Configurado analysis_options.yaml');
  }

  Future<void> _setupGitHubActions(Directory currentDir, bool force, String projectType) async {
    final githubDir = Directory('${currentDir.path}/.github/workflows');
    await githubDir.create(recursive: true);

    final ciFile = File('${githubDir.path}/ci.yml');
    
    if (ciFile.existsSync() && !force) {
      Logger.info('⏭️ GitHub Actions CI ya existe (usa --force para sobrescribir)');
      return;
    }

    final content = _getCIContent(projectType);
    await ciFile.writeAsString(content);
    Logger.success('✅ Configurado GitHub Actions CI/CD');
  }

  Future<void> _improveDocumentation(Directory currentDir, bool force, String projectType) async {
    // Mejorar README.md
    final readmeFile = File('${currentDir.path}/README.md');
    if (!readmeFile.existsSync() || force) {
      final content = await _getImprovedReadmeContent(currentDir, projectType);
      await readmeFile.writeAsString(content);
      Logger.success('✅ Mejorado README.md');
    }

    // Crear/mejorar CHANGELOG.md
    final changelogFile = File('${currentDir.path}/CHANGELOG.md');
    if (!changelogFile.existsSync()) {
      await changelogFile.writeAsString(_getChangelogContent());
      Logger.success('✅ Creado CHANGELOG.md');
    }

    // Verificar LICENSE
    final licenseFile = File('${currentDir.path}/LICENSE');
    if (!licenseFile.existsSync()) {
      await licenseFile.writeAsString(_getLicenseContent());
      Logger.success('✅ Creado LICENSE');
    }
  }

  Future<void> _setupTestStructure(Directory currentDir, bool force, String projectType) async {
    final testDir = Directory('${currentDir.path}/test');
    await testDir.create(recursive: true);

    // Crear estructura de tests según el tipo de proyecto
    if (projectType == 'flutter_app') {
      await _createFlutterAppTestStructure(testDir, force);
    } else if (projectType == 'flutter_plugin') {
      await _createPluginTestStructure(testDir, force);
    } else {
      await _createDartPackageTestStructure(testDir, force);
    }

    Logger.success('✅ Configurada estructura de tests');
  }

  Future<void> _createUtilityFiles(Directory currentDir, bool force, String projectType) async {
    // Crear Makefile
    final makeFile = File('${currentDir.path}/Makefile');
    if (!makeFile.existsSync() || force) {
      await makeFile.writeAsString(_getMakefileContent(projectType));
      Logger.success('✅ Creado Makefile');
    }

    // Crear .gitignore mejorado
    final gitignoreFile = File('${currentDir.path}/.gitignore');
    if (!gitignoreFile.existsSync() || force) {
      await gitignoreFile.writeAsString(_getGitignoreContent());
      Logger.success('✅ Configurado .gitignore');
    }

    // Crear scripts de desarrollo
    final toolDir = Directory('${currentDir.path}/tool');
    await toolDir.create(recursive: true);
    
    final setupScript = File('${toolDir.path}/setup.dart');
    if (!setupScript.existsSync() || force) {
      await setupScript.writeAsString(_getSetupScriptContent());
      Logger.success('✅ Creado script de setup');
    }
  }

  String _getAnalysisOptionsContent(bool isFlutterProject) {
    final include = isFlutterProject ? 'package:flutter_lints/flutter.yaml' : 'package:lints/recommended.yaml';
    
    return '''
include: $include

linter:
  rules:
    # Style
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
    - use_key_in_widget_constructors
    - sized_box_for_whitespace
    
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
''';
  }

  String _getCIContent(String projectType) {
    final isFlutterProject = projectType.startsWith('flutter');
    
    return '''
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
    
    - name: Setup ${isFlutterProject ? 'Flutter' : 'Dart'}
      uses: ${isFlutterProject ? 'subosito/flutter-action@v2' : 'dart-lang/setup-dart@v1'}
      with:
        ${isFlutterProject ? 'flutter-version: \'3.24.0\'' : 'dart-version: \'3.7.0\''}
    
    - name: Install dependencies
      run: ${isFlutterProject ? 'flutter' : 'dart'} pub get
    
    - name: Verify formatting
      run: dart format --output=none --set-exit-if-changed .
    
    - name: Analyze project source
      run: ${isFlutterProject ? 'flutter' : 'dart'} analyze
    
    - name: Run tests
      run: ${isFlutterProject ? 'flutter' : 'dart'} test${isFlutterProject ? ' --coverage' : ''}
    
    ${isFlutterProject ? '''- name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        file: coverage/lcov.info''' : ''}

  ${isFlutterProject ? '''build:
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
      run: flutter build apk --debug''' : ''}
''';
  }

  Future<String> _getImprovedReadmeContent(Directory currentDir, String projectType) async {
    String projectName = 'My Project';
    
    // Intentar obtener el nombre del proyecto
    try {
      final pubspecFile = File('${currentDir.path}/pubspec.yaml');
      final content = await pubspecFile.readAsString();
      final yaml = loadYaml(content) as Map;
      projectName = yaml['name']?.toString() ?? projectName;
    } catch (e) {
      // Usar nombre por defecto
    }

    final isFlutterProject = projectType.startsWith('flutter');
    
    return '''
# $projectName

${_getProjectTypeDescription(projectType)}

## Features

- 🚀 Modern ${isFlutterProject ? 'Flutter' : 'Dart'} development
- ✅ Best practices implementation
- 🧪 Comprehensive testing
- 📱 ${isFlutterProject ? 'Cross-platform support' : 'Multi-platform compatibility'}
- 🔧 CI/CD ready

## Getting Started

### Prerequisites

- ${isFlutterProject ? 'Flutter 3.24.0+' : 'Dart 3.7.0+'}
- ${isFlutterProject ? 'Android Studio / VS Code' : 'VS Code / IntelliJ'}

### Installation

1. Clone the repository:
\`\`\`bash
git clone https://github.com/username/$projectName.git
cd $projectName
\`\`\`

2. Install dependencies:
\`\`\`bash
${isFlutterProject ? 'flutter' : 'dart'} pub get
\`\`\`

3. ${isFlutterProject ? 'Run the app:' : 'Run tests:'}
\`\`\`bash
${isFlutterProject ? 'flutter run' : 'dart test'}
\`\`\`

## Usage

${_getUsageSection(projectType)}

## Development

### Running Tests

\`\`\`bash
${isFlutterProject ? 'flutter' : 'dart'} test
\`\`\`

### Code Generation (if applicable)

\`\`\`bash
dart run build_runner build
\`\`\`

### Linting

\`\`\`bash
${isFlutterProject ? 'flutter' : 'dart'} analyze
dart format --set-exit-if-changed .
\`\`\`

## Contributing

1. Fork the project
2. Create your feature branch (\`git checkout -b feature/amazing-feature\`)
3. Commit your changes (\`git commit -m 'Add amazing feature'\`)
4. Push to the branch (\`git push origin feature/amazing-feature\`)
5. Open a Pull Request

## Architecture

This project follows ${_getArchitectureDescription(projectType)}.

## Dependencies

Key dependencies used in this project:

${_getDependenciesSection(projectType)}

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If you have any questions or issues:

- 📧 Email: your-email@example.com
- 🐛 Issues: [GitHub Issues](https://github.com/username/$projectName/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/username/$projectName/discussions)
''';
  }

  String _getProjectTypeDescription(String projectType) {
    switch (projectType) {
      case 'flutter_app':
        return 'A beautiful Flutter application built with modern best practices.';
      case 'flutter_plugin':
        return 'A Flutter plugin that provides native platform functionality.';
      case 'flutter_package':
        return 'A Flutter package with reusable widgets and utilities.';
      case 'dart_package':
        return 'A Dart package with utilities and tools for Dart/Flutter development.';
      default:
        return 'A modern Dart/Flutter project.';
    }
  }

  String _getUsageSection(String projectType) {
    switch (projectType) {
      case 'flutter_app':
        return '''
This Flutter app provides [describe main functionality].

### Key Features

- Feature 1: Description
- Feature 2: Description
- Feature 3: Description''';
      case 'flutter_plugin':
        return '''
Add this plugin to your `pubspec.yaml`:

\`\`\`yaml
dependencies:
  your_plugin: ^1.0.0
\`\`\`

Then use it in your code:

\`\`\`dart
import 'package:your_plugin/your_plugin.dart';

// Example usage
final result = await YourPlugin.doSomething();
\`\`\`''';
      case 'dart_package':
        return '''
Add this package to your `pubspec.yaml`:

\`\`\`yaml
dependencies:
  your_package: ^1.0.0
\`\`\`

Import and use:

\`\`\`dart
import 'package:your_package/your_package.dart';

// Example usage
final utility = YourUtility();
utility.doSomething();
\`\`\`''';
      default:
        return 'Documentation coming soon...';
    }
  }

  String _getArchitectureDescription(String projectType) {
    switch (projectType) {
      case 'flutter_app':
        return 'Clean Architecture principles with clear separation of concerns';
      case 'flutter_plugin':
        return 'platform interface pattern for maximum maintainability';
      case 'dart_package':
        return 'modular design with clear public APIs';
      default:
        return 'modern software engineering practices';
    }
  }

  String _getDependenciesSection(String projectType) {
    switch (projectType) {
      case 'flutter_app':
        return '''
- **flutter_bloc**: State management
- **get_it**: Dependency injection
- **dio**: HTTP client
- **shared_preferences**: Local storage''';
      case 'flutter_plugin':
        return '''
- **plugin_platform_interface**: Platform abstraction
- **flutter**: Core Flutter framework''';
      case 'dart_package':
        return '''
- **meta**: Annotations
- **test**: Testing framework''';
      default:
        return '''
See `pubspec.yaml` for the complete list of dependencies.''';
    }
  }

  String _getChangelogContent() {
    return '''
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial project setup with fpd-toolkit-toolkit

### Changed

### Deprecated

### Removed

### Fixed

### Security

## [1.0.0] - ${DateTime.now().toIso8601String().split('T')[0]}

### Added
- Initial release
- Basic functionality
- Documentation
- Test structure
''';
  }

  String _getLicenseContent() {
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

  Future<void> _createFlutterAppTestStructure(Directory testDir, bool force) async {
    final dirs = ['unit', 'widget', 'integration'];
    
    for (final dir in dirs) {
      final directory = Directory('${testDir.path}/$dir');
      await directory.create(recursive: true);
    }

    // Test básico de widget
    final widgetTestFile = File('${testDir.path}/widget/app_test.dart');
    if (!widgetTestFile.existsSync() || force) {
      await widgetTestFile.writeAsString('''
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('App Widget Tests', () {
    testWidgets('App should build without errors', (tester) async {
      // TODO: Implement widget tests
      expect(true, isTrue);
    });
  });
}
''');
    }
  }

  Future<void> _createPluginTestStructure(Directory testDir, bool force) async {
    final testFile = File('${testDir.path}/plugin_test.dart');
    if (!testFile.existsSync() || force) {
      await testFile.writeAsString('''
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Plugin Tests', () {
    test('should initialize correctly', () {
      // TODO: Implement plugin tests
      expect(true, isTrue);
    });
  });
}
''');
    }
  }

  Future<void> _createDartPackageTestStructure(Directory testDir, bool force) async {
    final testFile = File('${testDir.path}/package_test.dart');
    if (!testFile.existsSync() || force) {
      await testFile.writeAsString('''
import 'package:test/test.dart';

void main() {
  group('Package Tests', () {
    test('should work correctly', () {
      // TODO: Implement package tests
      expect(true, isTrue);
    });
  });
}
''');
    }
  }

  String _getMakefileContent(String projectType) {
    final isFlutterProject = projectType.startsWith('flutter');
    final cmd = isFlutterProject ? 'flutter' : 'dart';
    
    return '''
.PHONY: help clean deps test analyze format build

help: ## Show this help
\t@grep -E '^[a-zA-Z_-]+:.*?## .*\$\$' \$(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\\033[36m%-20s\\033[0m %s\\n", \$\$1, \$\$2}'

clean: ## Clean build files
\t@$cmd clean

deps: ## Get dependencies
\t@$cmd pub get

test: ## Run tests
\t@$cmd test${isFlutterProject ? ' --coverage' : ''}

analyze: ## Run static analysis
\t@$cmd analyze

format: ## Format code
\t@dart format --set-exit-if-changed .

${isFlutterProject ? '''build: ## Build the app
\t@flutter build apk

run: ## Run the app
\t@flutter run

doctor: ## Check Flutter setup
\t@flutter doctor -v''' : '''build: ## Build the package
\t@dart compile exe bin/main.dart'''}

setup: ## Setup development environment
\t@dart tool/setup.dart

ci: deps analyze test ## Run CI pipeline locally
''';
  }

  String _getGitignoreContent() {
    return '''
# Miscellaneous
*.class
*.log
*.pyc
*.swp
.DS_Store
.atom/
.buildlog/
.history
.svn/
migrate_working_dir/

# IntelliJ related
*.iml
*.ipr
*.iws
.idea/

# VS Code related
.vscode/

# Flutter/Dart/Pub related
**/doc/api/
**/ios/Flutter/.last_build_id
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
/build/

# Symbolication related
app.*.symbols

# Obfuscation related
app.*.map.json

# Android Studio will place build artifacts here
/android/app/debug
/android/app/profile
/android/app/release

# Coverage
coverage/

# Environment
.env
.env.local
.env.*.local

# Database
*.db
*.sqlite
*.sqlite3

# Logs
logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db
''';
  }

  String _getSetupScriptContent() {
    return '''
#!/usr/bin/env dart

import 'dart:io';

Future<void> main() async {
  print('🚀 Setting up development environment...\\n');
  
  // Check if Flutter/Dart is installed
  final result = await Process.run('flutter', ['--version']);
  if (result.exitCode != 0) {
    final dartResult = await Process.run('dart', ['--version']);
    if (dartResult.exitCode != 0) {
      print('❌ Flutter/Dart not found. Please install first.');
      exit(1);
    }
  }
  
  // Install dependencies
  print('📦 Installing dependencies...');
  await _runCommand('flutter', ['pub', 'get']);
  
  // Generate code if needed
  if (File('build.yaml').existsSync()) {
    print('🔨 Generating code...');
    await _runCommand('dart', ['run', 'build_runner', 'build']);
  }
  
  // Run initial analysis
  print('🔍 Running analysis...');
  await _runCommand('flutter', ['analyze']);
  
  print('\\n✅ Setup complete! Happy coding! 🎉');
}

Future<void> _runCommand(String command, List<String> args) async {
  final result = await Process.run(command, args);
  if (result.exitCode != 0) {
    print('❌ Command failed: \$command \${args.join(' ')}');
    print(result.stderr);
    exit(1);
  }
}
''';
  }

  void _showNextSteps(String projectType) {
    final isFlutterProject = projectType.startsWith('flutter');
    
    Logger.info('\n📋 Próximos pasos:');
    Logger.info('   1. make deps          # Instalar dependencias');
    Logger.info('   2. make analyze       # Ejecutar análisis');
    Logger.info('   3. make test          # Ejecutar tests');
    
    if (isFlutterProject) {
      Logger.info('   4. make run           # Ejecutar la app');
    } else {
      Logger.info('   4. make build         # Compilar el paquete');
    }
    
    Logger.info('\n🔧 Configured tools:');
    Logger.info('   ✅ Static analysis with lints');
    Logger.info('   ✅ GitHub Actions CI/CD');
    Logger.info('   ✅ Improved documentation');
    Logger.info('   ✅ Test structure');
    Logger.info('   ✅ Development scripts (Makefile)');
    
    Logger.info('\n📖 For more information:');
    Logger.info('   fpd-toolkit guide --all');
    Logger.info('   make help');
  }

  @override
  void showHelp() {
    print('''
$description

Usage: fpd-toolkit init [options]

Options (all optional in interactive mode):
  -f, --force          Overwrite existing files
      --[no-]analysis  Configure analysis_options.yaml (default: on)
      --[no-]ci         Configure GitHub Actions CI/CD (default: on)
      --[no-]doc        Improve existing documentation (default: on)
      --[no-]tests      Add basic test structure (default: on)
      --non-interactive Run in non-interactive mode
  -h, --help           Show this help

This command configures:
  📊 analysis_options.yaml with recommended lints
  🔄 GitHub Actions for automatic CI/CD
  📚 Improved documentation (README, CHANGELOG, LICENSE)
  🧪 Organized test structure
  🛠️ Makefile with useful commands
  📝 Development scripts
  🙈 Complete .gitignore

Interactive Examples:
  fpd-toolkit init                    # Interactive mode - asks for preferences
  fpd-toolkit init --force           # Interactive mode with force overwrite

Non-Interactive Examples:
  fpd-toolkit init --non-interactive # Complete configuration with defaults
  fpd-toolkit init --force --no-ci --non-interactive # Specific configuration

Note: Run from project root directory (where pubspec.yaml is located)
''');
  }
}

/// Configuration for project initialization
class InitConfig {
  const InitConfig({
    required this.force,
    required this.setupAnalysis,
    required this.setupCI,
    required this.improveDocs,
    required this.setupTests,
  });

  final bool force;
  final bool setupAnalysis;
  final bool setupCI;
  final bool improveDocs;
  final bool setupTests;
}
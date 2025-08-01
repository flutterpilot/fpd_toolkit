import 'dart:io';
import '../utils/logger.dart';
import '../utils/file_utils.dart';
import '../utils/validator.dart';

/// Opciones para generar un paquete
class PackageOptions {
  const PackageOptions({
    required this.name,
    required this.type,
    required this.description,
    required this.author,
    required this.organization,
    required this.platforms,
    required this.outputDir,
    this.template,
    this.force = false,
  });

  final String name;
  final String type;
  final String description;
  final String author;
  final String organization;
  final List<String> platforms;
  final String outputDir;
  final String? template;
  final bool force;
}

/// Generador de paquetes Flutter/Dart
class PackageGenerator {
  /// Genera un paquete con las opciones especificadas
  Future<void> generate(PackageOptions options) async {
    Logger.verbose('Iniciando generación de paquete: ${options.name}');
    
    // Crear directorio de salida
    final outputDir = await FileUtils.ensureDirectoryExists(options.outputDir);
    
    // Generar según el tipo
    switch (options.type) {
      case 'app':
        await _generateFlutterApp(outputDir, options);
        break;
      case 'plugin':
        await _generateFlutterPlugin(outputDir, options);
        break;
      case 'package':
        await _generateDartPackage(outputDir, options);
        break;
      default:
        throw ArgumentError('Tipo de paquete no soportado: ${options.type}');
    }
    
    Logger.verbose('Generación completada');
  }

  Future<void> _generateFlutterApp(Directory outputDir, PackageOptions options) async {
    Logger.verbose('Generando aplicación Flutter');
    
    // Crear estructura de directorios
    await _createDirectoryStructure(outputDir, [
      'lib',
      'test',
      'assets/images',
      'assets/fonts',
    ]);

    // Generar archivos
    await _generatePubspec(outputDir, options);
    await _generateReadme(outputDir, options);
    await _generateChangelog(outputDir, options);
    await _generateLicense(outputDir, options);
    await _generateAnalysisOptions(outputDir, options);
    await _generateGitignore(outputDir, options);
    
    // Generar documentación y checklists
    await _generateProjectDocumentation(outputDir, options);
    
    // Archivos de código
    await _generateMainDart(outputDir, options);
    await _generateBasicTest(outputDir, options);
  }

  Future<void> _generateFlutterPlugin(Directory outputDir, PackageOptions options) async {
    Logger.verbose('Generando plugin Flutter');
    
    // Crear estructura de directorios
    final dirs = ['lib/src', 'test', 'example'];
    
    // Agregar directorios específicos de plataforma
    for (final platform in options.platforms) {
      switch (platform) {
        case 'android':
          dirs.add('android/src/main/java');
          break;
        case 'ios':
          dirs.add('ios/Classes');
          break;
        case 'web':
          dirs.add('lib/src');
          break;
        case 'windows':
          dirs.add('windows');
          break;
        case 'linux':
          dirs.add('linux');
          break;
        case 'macos':
          dirs.add('macos/Classes');
          break;
      }
    }

    await _createDirectoryStructure(outputDir, dirs);

    // Generar archivos
    await _generatePubspec(outputDir, options);
    await _generateReadme(outputDir, options);
    await _generateChangelog(outputDir, options);
    await _generateLicense(outputDir, options);
    await _generateAnalysisOptions(outputDir, options);
    await _generateGitignore(outputDir, options);
    
    // Generar documentación y checklists
    await _generateProjectDocumentation(outputDir, options);
    
    // Archivos específicos de plugin
    await _generatePluginFiles(outputDir, options);
  }

  Future<void> _generateDartPackage(Directory outputDir, PackageOptions options) async {
    Logger.verbose('Generando paquete Dart');
    
    // Crear estructura básica
    await _createDirectoryStructure(outputDir, [
      'lib/src',
      'test',
      'example',
    ]);

    // Generar archivos
    await _generatePubspec(outputDir, options);
    await _generateReadme(outputDir, options);
    await _generateChangelog(outputDir, options);
    await _generateLicense(outputDir, options);
    await _generateAnalysisOptions(outputDir, options);
    await _generateGitignore(outputDir, options);
    
    // Generar documentación y checklists
    await _generateProjectDocumentation(outputDir, options);
    
    // Archivos de código
    await _generateLibraryFile(outputDir, options);
    await _generateBasicTest(outputDir, options);
  }

  Future<void> _createDirectoryStructure(Directory outputDir, List<String> paths) async {
    for (final path in paths) {
      await FileUtils.ensureDirectoryExists('${outputDir.path}/$path');
    }
  }

  Future<void> _generatePubspec(Directory outputDir, PackageOptions options) async {
    final content = _getPubspecContent(options);
    await FileUtils.writeStringToFile('${outputDir.path}/pubspec.yaml', content);
  }

  Future<void> _generateReadme(Directory outputDir, PackageOptions options) async {
    final content = _getReadmeContent(options);
    await FileUtils.writeStringToFile('${outputDir.path}/README.md', content);
  }

  Future<void> _generateChangelog(Directory outputDir, PackageOptions options) async {
    final content = _getChangelogContent(options);
    await FileUtils.writeStringToFile('${outputDir.path}/CHANGELOG.md', content);
  }

  Future<void> _generateLicense(Directory outputDir, PackageOptions options) async {
    final content = _getLicenseContent(options);
    await FileUtils.writeStringToFile('${outputDir.path}/LICENSE', content);
  }

  Future<void> _generateAnalysisOptions(Directory outputDir, PackageOptions options) async {
    final content = _getAnalysisOptionsContent(options);
    await FileUtils.writeStringToFile('${outputDir.path}/analysis_options.yaml', content);
  }

  Future<void> _generateGitignore(Directory outputDir, PackageOptions options) async {
    final content = _getGitignoreContent();
    await FileUtils.writeStringToFile('${outputDir.path}/.gitignore', content);
  }

  Future<void> _generateMainDart(Directory outputDir, PackageOptions options) async {
    final content = _getMainDartContent(options);
    await FileUtils.writeStringToFile('${outputDir.path}/lib/main.dart', content);
  }

  Future<void> _generateLibraryFile(Directory outputDir, PackageOptions options) async {
    final content = _getLibraryFileContent(options);
    await FileUtils.writeStringToFile('${outputDir.path}/lib/${options.name}.dart', content);
    
    // Crear archivo base
    final baseContent = _getBaseClassContent(options);
    await FileUtils.writeStringToFile('${outputDir.path}/lib/src/${options.name}_base.dart', baseContent);
  }

  Future<void> _generateBasicTest(Directory outputDir, PackageOptions options) async {
    final content = _getTestContent(options);
    await FileUtils.writeStringToFile('${outputDir.path}/test/${options.name}_test.dart', content);
  }

  Future<void> _generatePluginFiles(Directory outputDir, PackageOptions options) async {
    // Platform interface
    final interfaceContent = _getPlatformInterfaceContent(options);
    await FileUtils.writeStringToFile(
      '${outputDir.path}/lib/src/${options.name}_platform_interface.dart',
      interfaceContent,
    );

    // Method channel implementation
    final methodChannelContent = _getMethodChannelContent(options);
    await FileUtils.writeStringToFile(
      '${outputDir.path}/lib/src/${options.name}_method_channel.dart',
      methodChannelContent,
    );

    // Main plugin file
    final pluginContent = _getPluginMainContent(options);
    await FileUtils.writeStringToFile('${outputDir.path}/lib/${options.name}.dart', pluginContent);
  }

  String _getPubspecContent(PackageOptions options) {
    final isFlutterProject = options.type == 'app' || options.type == 'plugin';
    
    final buffer = StringBuffer();
    
    // Información básica
    buffer.writeln('name: ${options.name}');
    buffer.writeln('description: ${options.description}');
    buffer.writeln('version: 1.0.0');
    
    if (options.type != 'app') {
      buffer.writeln('homepage: https://github.com/yourorg/${options.name}');
      buffer.writeln('repository: https://github.com/yourorg/${options.name}');
      buffer.writeln('issue_tracker: https://github.com/yourorg/${options.name}/issues');
      buffer.writeln('documentation: https://pub.dev/documentation/${options.name}/latest/');
    } else {
      buffer.writeln('publish_to: none');
    }

    // Environment
    buffer.writeln();
    buffer.writeln('environment:');
    buffer.writeln('  sdk: ^3.7.0-0');
    
    if (isFlutterProject) {
      buffer.writeln('  flutter: ">=3.24.0"');
    }

    // Dependencies
    buffer.writeln();
    buffer.writeln('dependencies:');
    
    if (isFlutterProject) {
      buffer.writeln('  flutter:');
      buffer.writeln('    sdk: flutter');
    }

    if (options.type == 'app') {
      buffer.writeln('  cupertino_icons: ^1.0.3');
    } else if (options.type == 'plugin') {
      buffer.writeln('  plugin_platform_interface: ^2.1.8');
    }

    // Dev Dependencies
    buffer.writeln();
    buffer.writeln('dev_dependencies:');
    
    if (isFlutterProject) {
      buffer.writeln('  flutter_test:');
      buffer.writeln('    sdk: flutter');
      buffer.writeln('  lints: ^5.0.0');
    } else {
      buffer.writeln('  test: ^1.24.0');
      buffer.writeln('  lints: ^5.0.0');
    }

    // Flutter section
    if (isFlutterProject) {
      buffer.writeln();
      buffer.writeln('flutter:');

      if (options.type == 'app') {
        buffer.writeln('  uses-material-design: true');
        buffer.writeln();
        buffer.writeln('  assets:');
        buffer.writeln('    - assets/images/');
        buffer.writeln();
        buffer.writeln('  fonts:');
        buffer.writeln('    - family: CustomFont');
        buffer.writeln('      fonts:');
        buffer.writeln('        - asset: assets/fonts/CustomFont-Regular.ttf');
      } else if (options.type == 'plugin') {
        buffer.writeln('  plugin:');
        buffer.writeln('    platforms:');
        
        for (final platform in options.platforms) {
          switch (platform) {
            case 'android':
              buffer.writeln('      android:');
              buffer.writeln('        package: ${options.organization}.${options.name}');
              buffer.writeln('        pluginClass: ${Validator.toPascalCase(options.name)}Plugin');
              break;
            case 'ios':
              buffer.writeln('      ios:');
              buffer.writeln('        pluginClass: Swift${Validator.toPascalCase(options.name)}Plugin');
              break;
            case 'web':
              buffer.writeln('      web:');
              buffer.writeln('        pluginClass: ${Validator.toPascalCase(options.name)}Web');
              buffer.writeln('        fileName: ${options.name}_web.dart');
              break;
            case 'windows':
              buffer.writeln('      windows:');
              buffer.writeln('        pluginClass: ${Validator.toPascalCase(options.name)}PluginCApi');
              break;
            case 'linux':
              buffer.writeln('      linux:');
              buffer.writeln('        pluginClass: ${Validator.toPascalCase(options.name)}Plugin');
              break;
            case 'macos':
              buffer.writeln('      macos:');
              buffer.writeln('        pluginClass: ${Validator.toPascalCase(options.name)}Plugin');
              break;
          }
        }
      }
    }

    return buffer.toString();
  }

  String _getReadmeContent(PackageOptions options) {
    return '''
# ${options.name}

${options.description}

## Features

- 🚀 Modern ${options.type == 'app' ? 'Flutter application' : options.type == 'plugin' ? 'Flutter plugin' : 'Dart package'}
- ✅ Best practices implementation
- 🧪 Comprehensive testing
- 📱 ${options.type == 'app' ? 'Cross-platform support' : 'Multi-platform compatibility'}

## Getting started

${options.type == 'app' ? '''
1. Clone the repository
2. Run `flutter pub get`
3. Run `flutter run`''' : '''
Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  ${options.name}: ^1.0.0
```

Then run:

```bash
${options.type == 'plugin' ? 'flutter' : 'dart'} pub get
```'''}

## Usage

```dart
import 'package:${options.name}/${options.name}.dart';

${_getUsageExample(options)}
```

## Additional information

This ${options.type} was generated using [FPD Toolkit](https://pub.dev/packages/fpd_toolkit).

## Contributing

Contributions are welcome! Please read our contributing guidelines before submitting PRs.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
''';
  }

  String _getUsageExample(PackageOptions options) {
    switch (options.type) {
      case 'app':
        return '''
// This is a Flutter app - run with `flutter run`
void main() {
  runApp(MyApp());
}''';
      case 'plugin':
        return '''
// Example plugin usage
final result = await ${Validator.toPascalCase(options.name)}.getPlatformVersion();
print('Platform version: \$result');''';
      case 'package':
        return '''
// Example package usage
final ${Validator.toCamelCase(options.name)} = ${Validator.toPascalCase(options.name)}();
${Validator.toCamelCase(options.name)}.doSomething();''';
      default:
        return '// Usage example will be added here';
    }
  }

  String _getChangelogContent(PackageOptions options) {
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
- Initial version of ${options.name}
- ${options.description}
- Basic functionality and structure
- Comprehensive documentation
- Test coverage
''';
  }

  String _getLicenseContent(PackageOptions options) {
    return '''
MIT License

Copyright (c) ${DateTime.now().year} ${options.author}

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

  String _getAnalysisOptionsContent(PackageOptions options) {
    final isFlutterProject = options.type == 'app' || options.type == 'plugin';
    
    return '''
include: package:lints/recommended.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "**/*.gr.dart"
    - build/**
    - "scripts/**"
    - ".fpd/**"
    - "example/**"
    - "test/**"
  errors:
    invalid_annotation_target: ignore
    missing_required_param: error
    missing_return: error
    todo: ignore

linter:
  rules:
    # Preferencias de estilo
    prefer_single_quotes: true
    prefer_const_constructors: true
    prefer_const_declarations: true
    prefer_final_fields: true
    prefer_final_locals: true
    
    # Documentación
    public_member_api_docs: false  # Deshabilitado para paquetes utilitarios
    
    # Imports
    avoid_relative_lib_imports: true
    prefer_relative_imports: true
    
    # Naming
    camel_case_types: true
    
    # Otros
    avoid_print: false  # Permitido en paquetes utilitarios
    avoid_unnecessary_containers: true
    ${isFlutterProject ? '''
    # Flutter específico
    use_key_in_widget_constructors: true
    sized_box_for_whitespace: true
    sort_child_properties_last: true''' : ''}
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
**/.fpd/api/
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
''';
  }

  String _getMainDartContent(PackageOptions options) {
    return '''
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// Main application widget
class MyApp extends StatelessWidget {
  /// Creates the main application
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${Validator.toPascalCase(options.name)}',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '${Validator.toPascalCase(options.name)} Home Page'),
    );
  }
}

/// Home page widget
class MyHomePage extends StatefulWidget {
  /// Creates the home page
  const MyHomePage({super.key, required this.title});

  /// Title to display in the app bar
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '\$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
''';
  }

  String _getLibraryFileContent(PackageOptions options) {
    return '''
/// ${options.description}
library ${options.name};

export 'src/${options.name}_base.dart';
''';
  }

  String _getBaseClassContent(PackageOptions options) {
    final className = Validator.toPascalCase(options.name);
    
    return '''
/// Base class for ${options.name}
class $className {
  /// Creates a new instance of [$className]
  const $className();
  
  /// Example method that returns a greeting
  String hello() {
    return 'Hello from ${options.name}!';
  }
}
''';
  }

  String _getTestContent(PackageOptions options) {
    final isFlutterProject = options.type == 'app' || options.type == 'plugin';
    final testImport = isFlutterProject ? 'package:flutter_test/flutter_test.dart' : 'package:test/test.dart';
    
    return '''
import '$testImport';
import 'package:${options.name}/${options.name}.dart';

void main() {
  group('${Validator.toPascalCase(options.name)}', () {
    test('should be tested', () {
      // TODO: Implement actual tests
      expect(true, isTrue);
    });
  });
}
''';
  }

  String _getPlatformInterfaceContent(PackageOptions options) {
    final className = Validator.toPascalCase(options.name);
    
    return '''
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '${options.name}_method_channel.dart';

/// The interface that implementations of ${options.name} must implement.
abstract class ${className}Platform extends PlatformInterface {
  /// Constructs a ${className}Platform.
  ${className}Platform() : super(token: _token);

  static final Object _token = Object();

  static ${className}Platform _instance = MethodChannel$className();

  /// The default instance of [${className}Platform] to use.
  static ${className}Platform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [${className}Platform] when
  /// they register themselves.
  static set instance(${className}Platform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Get the platform version.
  Future<String?> getPlatformVersion() {
    throw UnimplementedError('getPlatformVersion() has not been implemented.');
  }
}
''';
  }

  String _getMethodChannelContent(PackageOptions options) {
    final className = Validator.toPascalCase(options.name);
    
    return '''
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '${options.name}_platform_interface.dart';

/// An implementation of [${className}Platform] that uses method channels.
class MethodChannel$className extends ${className}Platform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('${options.name}');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
''';
  }

  String _getPluginMainContent(PackageOptions options) {
    final className = Validator.toPascalCase(options.name);
    
    return '''
import '${options.name}_platform_interface.dart';

/// ${options.description}
class $className {
  /// Get the platform version.
  Future<String?> getPlatformVersion() {
    return ${className}Platform.instance.getPlatformVersion();
  }
}
''';
  }

  /// Genera toda la documentación del proyecto copiando la estructura .fpd/
  Future<void> _generateProjectDocumentation(Directory outputDir, PackageOptions options) async {
    Logger.verbose('Generando documentación del proyecto');
    
    // Copiar estructura .fpd/ dinámicamente
    await _copyFpdStructure(outputDir, options);
    
    // CONTRIBUTING.md (permanece en la raíz)
    await _generateContributingGuide(outputDir, options);
  }

  /// Copia dinámicamente la estructura .fpd/ desde el directorio actual del fpd_toolkit
  Future<void> _copyFpdStructure(Directory outputDir, PackageOptions options) async {
    // Buscar el directorio .fpd del fpd_toolkit
    final currentDir = Directory.current;
    final fpdSourceDir = Directory('${currentDir.path}/.fpd');
    
    if (!fpdSourceDir.existsSync()) {
      Logger.verbose('No se encontró directorio .fpd fuente, creando estructura básica');
      await _createBasicFpdStructure(outputDir, options);
      return;
    }

    final fpdTargetDir = Directory('${outputDir.path}/.fpd');
    await fpdTargetDir.create(recursive: true);

    // Copiar recursivamente la estructura
    await _copyFpdDirectory(fpdSourceDir, fpdTargetDir, options);
  }

  /// Copia recursivamente el contenido de .fpd adaptando el contenido
  Future<void> _copyFpdDirectory(Directory source, Directory target, PackageOptions options) async {
    await for (final entity in source.list()) {
      if (entity is Directory) {
        final targetSubDir = Directory('${target.path}/${entity.path.split('/').last}');
        await targetSubDir.create(recursive: true);
        await _copyFpdDirectory(entity, targetSubDir, options);
      } else if (entity is File && entity.path.endsWith('.md')) {
        final targetFile = File('${target.path}/${entity.path.split('/').last}');
        await _adaptFpdFile(entity, targetFile, options);
      }
    }
  }

  /// Adapta el contenido de un archivo .fpd para el nuevo package
  Future<void> _adaptFpdFile(File sourceFile, File targetFile, PackageOptions options) async {
    try {
      final content = await sourceFile.readAsString();
      
      // Adaptar el contenido según el tipo de package y sus opciones
      String adaptedContent = content
          .replaceAll('fpd_toolkit', options.name)
          .replaceAll('FPD Toolkit', _getPackageDisplayName(options))
          .replaceAll('Flutter/Dart package generator', options.description);
      
      // Adaptaciones específicas por tipo de package
      switch (options.type) {
        case 'app':
          adaptedContent = _adaptForFlutterApp(adaptedContent, options);
          break;
        case 'plugin':
          adaptedContent = _adaptForFlutterPlugin(adaptedContent, options);
          break;
        case 'package':
          adaptedContent = _adaptForDartPackage(adaptedContent, options);
          break;
      }

      await targetFile.writeAsString(adaptedContent);
    } catch (e) {
      Logger.verbose('Error adaptando archivo ${sourceFile.path}: $e');
      // En caso de error, crear archivo básico
      await targetFile.writeAsString(_getBasicDocContent(options));
    }
  }

  /// Crea estructura básica de .fpd si no existe la fuente
  Future<void> _createBasicFpdStructure(Directory outputDir, PackageOptions options) async {
    final fpdDir = Directory('${outputDir.path}/.fpd');
    await fpdDir.create(recursive: true);
    
    // Crear README básico
    final readmeFile = File('${fpdDir.path}/README.md');
    await readmeFile.writeAsString(_getBasicFpdReadme(options));
  }

  String _getPackageDisplayName(PackageOptions options) {
    return options.name
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _adaptForFlutterApp(String content, PackageOptions options) {
    return content
        .replaceAll('dart pub get', 'flutter pub get')
        .replaceAll('dart test', 'flutter test')
        .replaceAll('dart run', 'flutter run');
  }

  String _adaptForFlutterPlugin(String content, PackageOptions options) {
    return content
        .replaceAll('dart pub get', 'flutter pub get')
        .replaceAll('dart test', 'flutter test')
        .replaceAll('package development', 'plugin development')
        .replaceAll('Dart package', 'Flutter plugin');
  }

  String _adaptForDartPackage(String content, PackageOptions options) {
    return content
        .replaceAll('Flutter', 'Dart')
        .replaceAll('flutter pub get', 'dart pub get')
        .replaceAll('flutter test', 'dart test');
  }

  String _getBasicDocContent(PackageOptions options) {
    return '''
# ${_getPackageDisplayName(options)} Documentation

${options.description}

## Development

This ${options.type} follows best practices for ${options.type == 'app' ? 'Flutter applications' : options.type == 'plugin' ? 'Flutter plugins' : 'Dart packages'}.

## Getting Started

1. Install dependencies: `${options.type == 'app' || options.type == 'plugin' ? 'flutter' : 'dart'} pub get`
2. Run tests: `${options.type == 'app' || options.type == 'plugin' ? 'flutter' : 'dart'} test`
${options.type == 'app' ? '3. Run the app: `flutter run`' : ''}

## Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for details.
''';
  }

  String _getBasicFpdReadme(PackageOptions options) {
    return '''
# ${_getPackageDisplayName(options)} - Development Documentation

This directory contains all development guides, best practices, and resources for the ${options.name} ${options.type}.

## Structure

This documentation follows the FPD (Flutter/Dart Package Development) standard for maintaining high-quality ${options.type == 'app' ? 'applications' : options.type == 'plugin' ? 'plugins' : 'packages'}.

## Usage

Refer to the main [README.md](../README.md) for usage instructions.
''';
  }


  Future<void> _generateContributingGuide(Directory outputDir, PackageOptions options) async {
    final content = _getContributingContent(options);
    await FileUtils.writeStringToFile('${outputDir.path}/CONTRIBUTING.md', content);
  }






  String _getContributingContent(PackageOptions options) {
    final isFlutter = options.type == 'app' || options.type == 'plugin';
    
    return '''
# Contributing to ${Validator.toPascalCase(options.name)}

We're excited that you're interested in contributing! This document outlines the process for contributing to this project.

## 🤝 Code of Conduct

By participating in this project, you agree to abide by our code of conduct:

- **Be respectful** and inclusive
- **Be constructive** in discussions and feedback
- **Focus on the best outcome** for the community
- **Show empathy** towards other community members

## 🚀 Getting Started

### Development Setup

1. **Fork the repository**
   ```bash
   git clone https://github.com/yourusername/${options.name}.git
   cd ${options.name}
   ```

2. **Install dependencies**
   ```bash
   dart pub get
   ```

3. **Verify setup**
   ```bash
   dart analyze
   dart test
   ${isFlutter ? 'flutter test' : ''}
   ```

### Development Environment
- **Dart SDK**: ≥ 3.7.0
${isFlutter ? '- **Flutter SDK**: ≥ 3.24.0' : ''}
- **IDE**: VS Code or IntelliJ with Dart extensions
- **Git**: For version control

## 📝 How to Contribute

### 1. Reporting Bugs

Before creating a bug report:
- **Search existing issues** to avoid duplicates
- **Use the latest version** to ensure the bug still exists
- **Provide minimal reproduction** case

**Bug Report Template:**
```markdown
**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. See error

**Expected behavior**
What you expected to happen.

**Environment:**
- Dart version: 
- ${isFlutter ? 'Flutter version:' : 'Package version:'}
- OS: 
- Device: 

**Additional context**
Any other context about the problem.
```

### 2. Suggesting Features

Feature requests are welcome! Please:
- **Check existing issues** for similar requests
- **Explain the use case** clearly
- **Consider the scope** of the change
- **Be open to discussion** about implementation

**Feature Request Template:**
```markdown
**Is your feature request related to a problem?**
A clear description of what the problem is.

**Describe the solution you'd like**
A clear description of what you want to happen.

**Describe alternatives you've considered**
Other solutions or features you've considered.

**Additional context**
Any other context or screenshots about the feature request.
```

### 3. Code Contributions

#### Branch Strategy
- **main**: Stable release branch
- **develop**: Development branch (if applicable)
- **feature/xxx**: Feature development
- **fix/xxx**: Bug fixes
- **docs/xxx**: Documentation updates

#### Development Workflow

1. **Create a branch**
   ```bash
   git checkout -b feature/my-new-feature
   ```

2. **Make your changes**
   - Follow [coding standards](#coding-standards)
   - Add tests for new functionality
   - Update documentation if needed

3. **Test your changes**
   ```bash
   dart analyze
   dart test
   dart format .
   ```

4. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat: add new feature description"
   ```

5. **Push to your fork**
   ```bash
   git push origin feature/my-new-feature
   ```

6. **Create a Pull Request**

## 📋 Coding Standards

### Dart Style Guide
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use `dart format` for consistent formatting
- Follow naming conventions:
  - **Classes**: PascalCase (`MyClass`)
  - **Variables/Functions**: camelCase (`myVariable`)
  - **Constants**: lowerCamelCase (`defaultValue`)
  - **Files**: snake_case (`my_file.dart`)

### Code Quality
- **Documentation**: Document all public APIs
- **Testing**: Maintain ≥ 80% test coverage
- **Error Handling**: Implement proper error handling
- **Performance**: Consider performance implications

### Example Code Style
```dart
/// Calculates the area of a rectangle.
/// 
/// Takes [width] and [height] as parameters and returns
/// the calculated area as a [double].
/// 
/// Example:
/// ```dart
/// final area = calculateArea(10.0, 5.0); // Returns 50.0
/// ```
/// 
/// Throws [ArgumentError] if width or height is negative.
double calculateArea(double width, double height) {
  if (width < 0 || height < 0) {
    throw ArgumentError('Width and height must be non-negative');
  }
  
  return width * height;
}
```

## 🧪 Testing Guidelines

### Test Requirements
- **Unit tests** for all new functionality
- **Integration tests** for complex features
${isFlutter ? '- **Widget tests** for UI components' : ''}
- **Tests must pass** before PR approval

### Test Structure
```dart
group('FeatureName', () {
  late FeatureClass feature;
  
  setUp(() {
    feature = FeatureClass();
  });
  
  group('methodName', () {
    test('should return expected result when given valid input', () {
      // Arrange
      final input = 'valid_input';
      final expected = 'expected_output';
      
      // Act
      final result = feature.methodName(input);
      
      // Assert
      expect(result, equals(expected));
    });
    
    test('should throw exception when given invalid input', () {
      // Arrange
      final invalidInput = 'invalid';
      
      // Act & Assert
      expect(
        () => feature.methodName(invalidInput),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
});
```

## 📚 Documentation

### Documentation Standards
- **API Documentation**: Use `///` for public APIs
- **README**: Keep examples up to date
- **CHANGELOG**: Follow [Keep a Changelog](https://keepachangelog.com/)
- **Code Comments**: Explain "why", not "what"

### Documentation Updates
When making changes that affect:
- **Public API**: Update API documentation
- **Usage**: Update README examples
- **Behavior**: Update relevant documentation
- **Breaking Changes**: Update migration guide

## 🔄 Pull Request Process

### PR Requirements
- [ ] **Tests**: All tests pass
- [ ] **Linting**: No analysis issues
- [ ] **Documentation**: Updated if necessary
- [ ] **Changelog**: Updated for user-facing changes
- [ ] **Description**: Clear description of changes

### PR Template
```markdown
## Description
Brief description of changes made.

## Type of Change
- [ ] Bug fix (non-breaking change that fixes an issue)
- [ ] New feature (non-breaking change that adds functionality)
- [ ] Breaking change (fix or feature that causes existing functionality to change)
- [ ] Documentation update

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Tests added/updated
- [ ] All tests pass
```

### Review Process
1. **Automated checks** must pass (CI/CD)
2. **Code review** by maintainer(s)
3. **Address feedback** if required
4. **Approval** and merge

## 🏷️ Versioning

We follow [Semantic Versioning](https://semver.org/):
- **PATCH** (1.0.1): Bug fixes
- **MINOR** (1.1.0): New features (backwards compatible)
- **MAJOR** (2.0.0): Breaking changes

### Commit Messages
Follow [Conventional Commits](https://www.conventionalcommits.org/):
- `feat:` New features
- `fix:` Bug fixes
- `docs:` Documentation changes
- `style:` Code style changes (formatting)
- `refactor:` Code refactoring
- `test:` Adding/updating tests
- `chore:` Maintenance tasks

Examples:
```
feat: add support for custom themes
fix: resolve memory leak in image cache
docs: update API documentation for v2.0
```

## 🚀 Release Process

### For Maintainers
1. **Update version** in `pubspec.yaml`
2. **Update CHANGELOG.md**
3. **Create release branch**
4. **Final testing**
5. **Merge to main**
6. **Tag release**
7. **Publish to pub.dev**

## 🤔 Questions?

- **General questions**: Create a [GitHub Discussion](https://github.com/yourorg/${options.name}/discussions)
- **Bug reports**: Create an [Issue](https://github.com/yourorg/${options.name}/issues)
- **Feature requests**: Create an [Issue](https://github.com/yourorg/${options.name}/issues)

## 🙏 Recognition

Contributors will be:
- **Listed** in CONTRIBUTORS.md
- **Mentioned** in release notes
- **Tagged** in social media announcements (if desired)

## 📄 License

By contributing, you agree that your contributions will be licensed under the same license as the project (see [LICENSE](LICENSE) file).

---

**Thank you for contributing to ${Validator.toPascalCase(options.name)}!** 🎉

Your contributions help make this project better for everyone. Whether you're fixing bugs, adding features, improving documentation, or helping other users, every contribution is valuable and appreciated.
''';
  }
}
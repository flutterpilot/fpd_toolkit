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
      'doc',
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
    final dirs = ['lib/src', 'test', 'example', 'doc'];
    
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
      'doc',
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
    - "doc/**"
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

  /// Genera toda la documentación del proyecto
  Future<void> _generateProjectDocumentation(Directory outputDir, PackageOptions options) async {
    Logger.verbose('Generando documentación del proyecto');
    
    // Guía de desarrollo Flutter/Dart
    await _generateDevelopmentGuide(outputDir, options);
    
    // Mejores prácticas
    await _generateBestPracticesGuide(outputDir, options);
    
    // Checklists de desarrollo
    await _generateDevelopmentChecklists(outputDir, options);
    
    // CONTRIBUTING.md
    await _generateContributingGuide(outputDir, options);
  }

  Future<void> _generateDevelopmentGuide(Directory outputDir, PackageOptions options) async {
    final content = _getDevelopmentGuideContent(options);
    await FileUtils.writeStringToFile('${outputDir.path}/doc/DEVELOPMENT_GUIDE.md', content);
  }

  Future<void> _generateBestPracticesGuide(Directory outputDir, PackageOptions options) async {
    final content = _getBestPracticesContent(options);
    await FileUtils.writeStringToFile('${outputDir.path}/doc/BEST_PRACTICES.md', content);
  }

  Future<void> _generateDevelopmentChecklists(Directory outputDir, PackageOptions options) async {
    // Checklist de desarrollo
    final devChecklist = _getDevChecklistContent(options);
    await FileUtils.writeStringToFile('${outputDir.path}/doc/DEV_CHECKLIST.md', devChecklist);
    
    // Checklist de testing
    final testChecklist = _getTestChecklistContent(options);
    await FileUtils.writeStringToFile('${outputDir.path}/doc/TEST_CHECKLIST.md', testChecklist);
    
    // Checklist de publicación
    final pubChecklist = _getPublishChecklistContent(options);
    await FileUtils.writeStringToFile('${outputDir.path}/doc/PUBLISH_CHECKLIST.md', pubChecklist);
  }

  Future<void> _generateContributingGuide(Directory outputDir, PackageOptions options) async {
    final content = _getContributingContent(options);
    await FileUtils.writeStringToFile('${outputDir.path}/CONTRIBUTING.md', content);
  }

  String _getDevelopmentGuideContent(PackageOptions options) {
    return '''
# Guía de Desarrollo - ${Validator.toPascalCase(options.name)}

Esta guía contiene las mejores prácticas y patrones de desarrollo para este proyecto ${options.type}.

## 🏗️ Arquitectura

### Estructura del Proyecto
```
${options.name}/
├── lib/
│   ├── ${options.name}.dart          # API pública
│   └── src/                          # Implementación interna
├── test/                             # Tests unitarios
├── example/                          # Ejemplos de uso
├── doc/                              # Documentación
└── pubspec.yaml                      # Configuración
```

### Principios de Diseño
- **Single Responsibility**: Cada clase tiene una única responsabilidad
- **Open/Closed**: Abierto para extensión, cerrado para modificación
- **Dependency Inversion**: Depender de abstracciones, no de concreciones

## 🎨 Convenciones de Código

### Naming
- **Packages**: snake_case (`${options.name}`)
- **Classes**: PascalCase (`${Validator.toPascalCase(options.name)}`)
- **Variables/Functions**: camelCase (`getValue`)
- **Constants**: lowerCamelCase (`defaultValue`)

### Documentación
- Documentar todas las APIs públicas
- Usar `///` para doc comments
- Incluir ejemplos en la documentación

```dart
/// Calculates the sum of two numbers.
/// 
/// Example:
/// ```dart
/// final result = add(2, 3); // Returns 5
/// ```
int add(int a, int b) => a + b;
```

## 🧪 Testing

### Estructura de Tests
- Un archivo de test por clase
- Usar `group()` para organizar tests relacionados
- Naming descriptivo para tests

```dart
group('${Validator.toPascalCase(options.name)}', () {
  test('should return correct value when valid input', () {
    // Arrange
    final instance = ${Validator.toPascalCase(options.name)}();
    
    // Act
    final result = instance.process('valid');
    
    // Assert
    expect(result, equals('expected'));
  });
});
```

### Coverage
- Mantener coverage mínimo del 80%
- Priorizar tests de lógica crítica
- Usar mocks para dependencias externas

## 🚀 Performance

### Mejores Prácticas
- Evitar operaciones costosas en constructores
- Usar `const` constructors cuando sea posible
- Implementar `toString()` eficientemente
- Considerar lazy loading para recursos pesados

## 🔒 Seguridad

### Validación de Input
- Validar todos los inputs externos
- Sanitizar data del usuario
- Usar tipos seguros (non-nullable)

### Manejo de Errores
- Usar exceptions específicas
- Proporcionar mensajes de error útiles
- Documentar exceptions que pueden lanzarse

## 📦 Dependencias

### Gestión
- Mantener dependencias actualizadas
- Revisar regularmente vulnerabilidades
- Usar versiones específicas en production

### Análisis
```bash
# Analizar dependencias obsoletas
dart pub outdated

# Analizar vulnerabilidades
dart pub deps
```

## 🔄 CI/CD

### Pre-commit Hooks
- Formateo automático
- Análisis estático
- Tests unitarios

### Pipeline
1. **Análisis**: `dart analyze`
2. **Tests**: `dart test --coverage`
3. **Formato**: `dart format --set-exit-if-changed .`
4. **Build**: Verificar que compila

## 📝 Versionado

### Semantic Versioning
- **MAJOR**: Cambios incompatibles
- **MINOR**: Nueva funcionalidad compatible
- **PATCH**: Bug fixes compatibles

### Changelog
- Mantener CHANGELOG.md actualizado
- Seguir formato [Keep a Changelog](https://keepachangelog.com/)
- Documentar breaking changes claramente

## 🤝 Contribución

Ver [CONTRIBUTING.md](../CONTRIBUTING.md) para detalles sobre cómo contribuir.

## 📚 Recursos

- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Flutter Best Practices](https://docs.flutter.dev/development/best-practices)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
''';
  }

  String _getBestPracticesContent(PackageOptions options) {
    final isFlutter = options.type == 'app' || options.type == 'plugin';
    
    return '''
# Mejores Prácticas - ${Validator.toPascalCase(options.name)}

## 🎯 Principios Fundamentales

### Clean Code
- **Nombres descriptivos**: Variables y funciones con nombres claros
- **Funciones pequeñas**: Una responsabilidad por función
- **Comentarios útiles**: Explicar el "por qué", no el "qué"

### SOLID Principles
- **S** - Single Responsibility Principle
- **O** - Open/Closed Principle  
- **L** - Liskov Substitution Principle
- **I** - Interface Segregation Principle
- **D** - Dependency Inversion Principle

## 🏗️ Arquitectura

${isFlutter ? '''
### Clean Architecture (Flutter)
```
Presentation Layer (UI)
    ↓
Business Logic Layer (BLoC/Cubit)
    ↓
Data Layer (Repository)
    ↓
Data Sources (API/Database)
```

### State Management
- **BLoC**: Para aplicaciones complejas
- **Provider**: Para estado simple-moderado
- **Riverpod**: Para inyección de dependencias
- **GetX**: Para prototipado rápido
''' : '''
### Package Architecture
```
lib/
├── src/
│   ├── models/      # Data models
│   ├── services/    # Business logic
│   └── utils/       # Utilities
└── ${options.name}.dart  # Public API
```
'''}

## 📝 Convenciones de Código

### Formatting
```dart
// ✅ Good
final List<String> items = [
  'item1',
  'item2',
  'item3',
];

// ❌ Bad
final List<String> items = ['item1', 'item2', 'item3'];
```

### Error Handling
```dart
// ✅ Good
try {
  final result = await riskyOperation();
  return Success(result);
} on SpecificException catch (e) {
  return Failure('Specific error: \${e.message}');
} catch (e) {
  return Failure('Unexpected error: \$e');
}

// ❌ Bad
try {
  return await riskyOperation();
} catch (e) {
  return null; // No context about the error
}
```

## 🧪 Testing Strategies

### Test Pyramid
```
        E2E Tests (5%)
      ↗               ↖
 Integration Tests (15%)
↗                       ↖
   Unit Tests (80%)
```

### Test Categories
- **Unit**: Lógica individual
- **Widget**: UI components (Flutter)
- **Integration**: Flujos completos
- **Golden**: Visual regression

${isFlutter ? '''
### Widget Testing
```dart
testWidgets('should display correct text', (tester) async {
  await tester.pumpWidget(MyWidget(text: 'Hello'));
  
  expect(find.text('Hello'), findsOneWidget);
});
```
''' : ''}

## ⚡ Performance

### Optimization
- **Lazy Loading**: Cargar recursos cuando se necesiten
- **Caching**: Cachear datos costosos de obtener
- **Debouncing**: Para operaciones frecuentes

${isFlutter ? '''
### Flutter Performance
- **const constructors**: Para widgets inmutables
- **ListView.builder**: Para listas largas
- **Image caching**: Para imágenes de red
- **Animation disposal**: Liberar controladores
''' : ''}

### Memory Management
```dart
// ✅ Good - Dispose resources
@override
void dispose() {
  _controller.dispose();
  _subscription.cancel();
  super.dispose();
}
```

## 🔒 Seguridad

### Input Validation
```dart
// ✅ Good
String? validateEmail(String? email) {
  if (email == null || email.isEmpty) {
    return 'Email is required';
  }
  
  final emailRegex = RegExp(r'^[^@]+@[^@]+\\.[^@]+');
  if (!emailRegex.hasMatch(email)) {
    return 'Invalid email format';
  }
  
  return null;
}
```

### Sensitive Data
- **No hardcode secrets**: Usar variables de entorno
- **Encrypt storage**: Para datos sensibles locales
- **HTTPS only**: Para comunicación de red

## 📱 ${isFlutter ? 'UI/UX' : 'API Design'}

${isFlutter ? '''
### Material Design
- Seguir Material Design Guidelines
- Usar Theme para consistencia
- Implementar Dark Mode

### Responsive Design
```dart
class ResponsiveWidget extends StatelessWidget {
  @override
  Widget build(context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return DesktopLayout();
        } else {
          return MobileLayout();
        }
      },
    );
  }
}
```

### Accessibility
- Semantic labels para screen readers
- Sufficient color contrast
- Touch target sizes (44x44 minimum)
''' : '''
### API Design
- **Consistent naming**: camelCase para métodos
- **Clear return types**: Usar tipos específicos
- **Documentation**: Documentar todas las APIs públicas

```dart
/// Processes user data and returns result.
/// 
/// Throws [ValidationException] if data is invalid.
/// Returns [ProcessResult] with success/failure status.
Future<ProcessResult> processUserData(UserData data) async {
  // Implementation
}
```
'''}

## 🌐 Internacionalización

${isFlutter ? '''
### i18n Setup
```dart
// pubspec.yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: any

// MaterialApp
MaterialApp(
  localizationsDelegates: [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: [
    Locale('en', ''),
    Locale('es', ''),
  ],
)
```
''' : ''}

### String Management
- Externalizar todos los strings
- Usar keys descriptivos
- Considerar pluralización

## 📊 Monitoring

### Logging
```dart
import 'dart:developer' as developer;

void logInfo(String message) {
  developer.log(message, name: '${options.name}');
}

void logError(String message, [Object? error, StackTrace? stack]) {
  developer.log(
    message,
    name: '${options.name}',
    error: error,
    stackTrace: stack,
    level: 1000, // Error level
  );
}
```

### Analytics
- Track key user actions
- Monitor performance metrics
- Set up crash reporting

## 🚀 Deployment

### Pre-deployment Checklist
- [ ] All tests passing
- [ ] Code coverage ≥ 80%
- [ ] Documentation updated
- [ ] Version bumped
- [ ] Changelog updated

### Release Process
1. **Feature freeze**
2. **QA testing**
3. **Staging deployment**
4. **Production deployment**
5. **Post-deployment monitoring**

## 📚 Learning Resources

- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
${isFlutter ? '- [Flutter Documentation](https://docs.flutter.dev/)' : '- [Package Development](https://dart.dev/guides/libraries/create-library-packages)'}
- [Testing Best Practices](https://dart.dev/guides/testing)

---

**Recuerda**: Estas son guías, no reglas absolutas. Adapta según el contexto del proyecto.
''';
  }

  String _getDevChecklistContent(PackageOptions options) {
    final isFlutter = options.type == 'app' || options.type == 'plugin';
    
    return '''
# Development Checklist - ${Validator.toPascalCase(options.name)}

## 🚀 Setup Inicial

### Entorno de Desarrollo
- [ ] Dart SDK ≥ 3.7.0 instalado
${isFlutter ? '- [ ] Flutter SDK ≥ 3.24.0 instalado' : ''}
- [ ] IDE configurado (VS Code/IntelliJ)
- [ ] Extensiones Dart/Flutter instaladas
- [ ] Git configurado

### Proyecto
- [ ] `dart pub get` ejecutado sin errores
- [ ] `dart analyze` sin warnings/errors
- [ ] `dart test` pasa todos los tests
- [ ] `dart format` aplicado

## 📝 Antes de Cada Feature

### Planificación
- [ ] Requirement claramente definido
- [ ] Design/Architecture discutido
- [ ] Breaking changes identificados
- [ ] Tests strategy definida

### Branch Setup
- [ ] Nueva branch desde main/develop
- [ ] Naming convention seguido (`feature/`, `fix/`, `refactor/`)
- [ ] Branch actualizada con latest changes

## 💻 Durante el Desarrollo

### Código
- [ ] Seguir naming conventions
- [ ] Documentar APIs públicas
- [ ] Implementar error handling
- [ ] Evitar código duplicado
- [ ] Usar tipos no-nullable cuando sea posible

### Testing
- [ ] Tests unitarios para nueva lógica
${isFlutter ? '- [ ] Widget tests para nuevos widgets' : ''}
- [ ] Tests de edge cases
- [ ] Mocks para dependencias externas
- [ ] Coverage ≥ 80% mantenido

### Performance
- [ ] No operaciones costosas en main thread
- [ ] Memory leaks verificados
- [ ] Lazy loading implementado donde corresponde
${isFlutter ? '- [ ] Build times aceptables' : ''}

## 🔍 Code Review

### Self Review
- [ ] Código formateado (`dart format`)
- [ ] Análisis estático limpio (`dart analyze`)
- [ ] Tests pasando (`dart test`)
- [ ] Documentación actualizada
- [ ] TODO/FIXME comentarios resueltos

### PR Preparation
- [ ] Descripción clara del cambio
- [ ] Screenshots/GIFs para UI changes
- [ ] Breaking changes documentados
- [ ] Migration guide si es necesario

## 📦 Build & Deploy

### Pre-build
- [ ] Version bumped siguiendo semver
- [ ] CHANGELOG.md actualizado
- [ ] Documentation generada
- [ ] Example app funciona

### Build Verification
${isFlutter ? '''- [ ] `flutter build apk` exitoso (Android)
- [ ] `flutter build ios` exitoso (iOS)
- [ ] `flutter build web` exitoso (Web)''' : '- [ ] `dart compile exe` exitoso'}
- [ ] No warnings en build
- [ ] Tests en CI pasando

### Quality Checks
- [ ] Linting rules aplicadas
- [ ] Security scan realizado
- [ ] Dependencias audit ejecutado
- [ ] Performance benchmarks verificados

## 🧪 Testing Checklist

### Unit Tests
- [ ] Funciones puras testeadas
- [ ] Edge cases cubiertos
- [ ] Error conditions testeadas
- [ ] Mocks utilizados apropiadamente

${isFlutter ? '''### Widget Tests
- [ ] Widget rendering verificado
- [ ] User interactions testeadas
- [ ] State changes validados
- [ ] Golden tests para UI críticos

### Integration Tests
- [ ] End-to-end flows funcionando
- [ ] Navigation testeada
- [ ] API integration verificada
- [ ] Platform-specific features testeadas''' : '''### Integration Tests
- [ ] API endpoints testeados
- [ ] Database operations verificadas
- [ ] External services mocked
- [ ] Error scenarios cubiertos'''}

## 📊 Performance Checklist

### Memory
- [ ] No memory leaks detectados
- [ ] Resources properly disposed
- [ ] Caching strategy implementada
- [ ] Large objects release verificado

### Speed
${isFlutter ? '''- [ ] App startup time < 3s
- [ ] Frame drops minimizados
- [ ] Image loading optimizado
- [ ] List scrolling suave''' : '''- [ ] Function execution time optimizada
- [ ] Database queries eficientes
- [ ] Network calls minimizadas
- [ ] Async operations non-blocking'''}

## 🔒 Security Checklist

### Code Security
- [ ] No hardcoded secrets/keys
- [ ] Input validation implementada
- [ ] SQL injection prevention
- [ ] XSS protection (si aplica)

### Data Security
- [ ] Sensitive data encrypted
- [ ] Secure communication (HTTPS)
- [ ] Authentication implemented
- [ ] Authorization checks en place

## 📱 ${isFlutter ? 'Platform' : 'Compatibility'} Checklist

${isFlutter ? '''### Android
- [ ] Material Design guidelines seguidas
- [ ] Permissions correctamente declaradas
- [ ] Proguard rules actualizadas
- [ ] APK size optimizado

### iOS
- [ ] Human Interface Guidelines seguidas
- [ ] Info.plist configurado
- [ ] App Store guidelines cumplidas
- [ ] IPA size optimizado

### Web
- [ ] PWA capabilities consideradas
- [ ] Responsive design implementado
- [ ] Browser compatibility verificada
- [ ] SEO optimizado''' : '''### Dart Versions
- [ ] Minimum Dart SDK especificado
- [ ] Latest Dart features utilizadas apropiadamente
- [ ] Backwards compatibility mantenida

### Platforms
- [ ] Cross-platform compatibility verificada
- [ ] Platform-specific code properly isolated
- [ ] Conditional imports utilizados correctamente'''}

## 📝 Documentation Checklist

### Code Documentation
- [ ] Public APIs documentadas
- [ ] Complex logic explicada
- [ ] Examples incluidos en doc comments
- [ ] Return types y exceptions documentados

### Project Documentation
- [ ] README.md actualizado
- [ ] API documentation generada
- [ ] Examples actualizados
- [ ] Migration guides escritas (si aplica)

## ✅ Final Checks

### Before Merge
- [ ] All CI checks passing
- [ ] Code review approved
- [ ] Conflicts resolved
- [ ] Feature branch up to date

### Before Release
- [ ] Version tags creados
- [ ] Release notes escritas
- [ ] Backwards compatibility verificada
- [ ] Rollback plan definido

---

**Tip**: Marca cada item antes de considerar la tarea completa. ¡La calidad es responsabilidad de todos! 🎯
''';
  }

  String _getTestChecklistContent(PackageOptions options) {
    final isFlutter = options.type == 'app' || options.type == 'plugin';
    
    return '''
# Testing Checklist - ${Validator.toPascalCase(options.name)}

## 🎯 Test Strategy

### Coverage Goals
- [ ] **Unit Tests**: ≥ 80% coverage
- [ ] **Critical Path**: 100% coverage
${isFlutter ? '- [ ] **Widget Tests**: UI components covered' : '- [ ] **Integration Tests**: API flows covered'}
- [ ] **Edge Cases**: Error scenarios tested

### Test Types Priority
1. **Unit Tests** (80%) - Fast, isolated, reliable
2. **Integration Tests** (15%) - Real component interaction
3. **E2E Tests** (5%) - Full user workflows

## 🧪 Unit Testing

### Setup
- [ ] Test files in `test/` directory
- [ ] Naming convention: `*_test.dart`
- [ ] One test file per source file
- [ ] Test groups organized logically

### Test Structure (AAA Pattern)
```dart
test('should return expected result when valid input provided', () {
  // Arrange - Setup test data
  final input = 'valid_input';
  final expected = 'expected_output';
  
  // Act - Execute the function
  final result = functionUnderTest(input);
  
  // Assert - Verify the result
  expect(result, equals(expected));
});
```

### Coverage Areas
- [ ] **Happy Path**: Normal execution flow
- [ ] **Edge Cases**: Boundary conditions
- [ ] **Error Cases**: Exception handling
- [ ] **Null Safety**: Null/empty inputs
- [ ] **Data Validation**: Input validation logic

### Best Practices
- [ ] Tests are independent (no shared state)
- [ ] Descriptive test names
- [ ] One assertion per test (when possible)
- [ ] Use setUp/tearDown for common initialization
- [ ] Mock external dependencies

### Example Unit Test
```dart
group('${Validator.toPascalCase(options.name)}', () {
  late ${Validator.toPascalCase(options.name)} instance;
  
  setUp(() {
    instance = ${Validator.toPascalCase(options.name)}();
  });
  
  group('processData', () {
    test('should return processed data when valid input', () {
      // Arrange
      final input = TestData.validInput();
      
      // Act
      final result = instance.processData(input);
      
      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, isNotNull);
    });
    
    test('should throw ValidationException when invalid input', () {
      // Arrange
      final invalidInput = TestData.invalidInput();
      
      // Act & Assert
      expect(
        () => instance.processData(invalidInput),
        throwsA(isA<ValidationException>()),
      );
    });
  });
});
```

${isFlutter ? '''
## 🎨 Widget Testing

### Setup
- [ ] Import `package:flutter_test/flutter_test.dart`
- [ ] Use `testWidgets` for widget tests
- [ ] Pump widgets with `tester.pumpWidget()`

### Widget Test Areas
- [ ] **Rendering**: Widget displays correctly
- [ ] **Interactions**: Tap, scroll, input events
- [ ] **State Changes**: UI updates on state change
- [ ] **Navigation**: Route transitions
- [ ] **Animations**: Animation behavior

### Widget Test Example
```dart
testWidgets('should display loading indicator when loading', (tester) async {
  // Arrange
  final widget = MyWidget(isLoading: true);
  
  // Act
  await tester.pumpWidget(MaterialApp(home: widget));
  
  // Assert
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
  expect(find.text('Data'), findsNothing);
});

testWidgets('should handle tap events correctly', (tester) async {
  // Arrange
  bool tapped = false;
  final widget = MyButton(onTap: () => tapped = true);
  
  // Act
  await tester.pumpWidget(MaterialApp(home: widget));
  await tester.tap(find.byType(MyButton));
  await tester.pump();
  
  // Assert
  expect(tapped, isTrue);
});
```

### Golden Tests
- [ ] Critical UI components have golden tests
- [ ] Different screen sizes tested
- [ ] Light/dark themes covered
- [ ] Platform-specific variations

```dart
testWidgets('golden test for main screen', (tester) async {
  await tester.pumpWidget(MyApp());
  await expectLater(
    find.byType(MyApp),
    matchesGoldenFile('main_screen.png'),
  );
});
```
''' : ''}

## 🔗 Integration Testing

### Setup
- [ ] Test real component interactions
- [ ] Use real dependencies (where possible)
- [ ] Test data flow between layers

### Integration Areas
- [ ] **API Calls**: Network requests/responses
- [ ] **Database**: CRUD operations
- [ ] **File I/O**: Reading/writing files
- [ ] **External Services**: Third-party integrations

### Mocking Strategy
- [ ] Mock external APIs
- [ ] Mock expensive operations
- [ ] Use dependency injection for testability

```dart
group('Integration Tests', () {
  late ApiClient mockApiClient;
  late Repository repository;
  
  setUp(() {
    mockApiClient = MockApiClient();
    repository = Repository(apiClient: mockApiClient);
  });
  
  test('should fetch and parse data from API', () async {
    // Arrange
    when(mockApiClient.fetchData())
        .thenAnswer((_) async => ApiResponse.success(testData));
    
    // Act
    final result = await repository.getData();
    
    // Assert
    expect(result.isSuccess, isTrue);
    expect(result.data, equals(expectedData));
    verify(mockApiClient.fetchData()).called(1);
  });
});
```

## 🔥 Error Testing

### Exception Handling
- [ ] Network failures handled
- [ ] Invalid data scenarios covered
- [ ] Resource not found cases
- [ ] Permission denied situations

### Error Test Checklist
- [ ] **Timeout Errors**: Network/operation timeouts
- [ ] **Format Errors**: Invalid data format
- [ ] **Validation Errors**: Input validation failures
- [ ] **System Errors**: File system, memory issues

```dart
test('should handle network timeout gracefully', () async {
  // Arrange
  when(mockApiClient.fetchData())
      .thenThrow(TimeoutException('Request timeout', Duration(seconds: 30)));
  
  // Act
  final result = await repository.getData();
  
  // Assert
  expect(result.isFailure, isTrue);
  expect(result.error, contains('timeout'));
});
```

## 📊 Performance Testing

### Performance Areas
- [ ] **Response Times**: Function execution time
- [ ] **Memory Usage**: Memory allocation/deallocation
- [ ] **Resource Leaks**: Proper cleanup verification

```dart
test('should complete operation within acceptable time', () async {
  final stopwatch = Stopwatch()..start();
  
  await expensiveOperation();
  
  stopwatch.stop();
  expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // < 1 second
});
```

## 🧹 Test Maintenance

### Regular Tasks
- [ ] Remove obsolete tests
- [ ] Update tests for code changes
- [ ] Refactor duplicate test code
- [ ] Keep test data updated

### Test Code Quality
- [ ] DRY principle applied
- [ ] Clear test structure
- [ ] Meaningful assertions
- [ ] Proper cleanup in tearDown

## 🚀 CI/CD Testing

### Continuous Integration
- [ ] Tests run on every commit
- [ ] Tests run on multiple platforms
- [ ] Coverage reports generated
- [ ] Failed tests block merges

### Test Environment
- [ ] Consistent test environment
- [ ] Test data isolated
- [ ] Parallel test execution
- [ ] Flaky test detection

## 📈 Test Metrics

### Coverage Tracking
```bash
# Generate coverage report
dart test --coverage=coverage
genhtml coverage/lcov.info -o coverage/html

# Check coverage percentage
lcov --summary coverage/lcov.info
```

### Quality Metrics
- [ ] **Test Coverage**: ≥ 80%
- [ ] **Test Speed**: All tests < 30 seconds
- [ ] **Test Reliability**: < 1% flaky tests
- [ ] **Test Maintainability**: Low coupling, high cohesion

## ✅ Pre-Commit Testing

### Local Verification
```bash
# Run all tests
dart test

# Run tests with coverage
dart test --coverage=coverage

# Run specific test file
dart test test/specific_test.dart

# Run tests matching pattern
dart test --name="pattern"
```

### Commit Checklist
- [ ] All existing tests pass
- [ ] New functionality has tests
- [ ] Coverage threshold maintained
- [ ] No test warnings/errors
- [ ] Test code formatted and linted

---

**Remember**: Good tests are your safety net. Write them as if your future self depends on them! 🛡️
''';
  }

  String _getPublishChecklistContent(PackageOptions options) {
    final isFlutter = options.type == 'app' || options.type == 'plugin';
    
    return '''
# Publication Checklist - ${Validator.toPascalCase(options.name)}

## 📋 Pre-Publication Checklist

### 📝 Documentation
- [ ] **README.md** completo y actualizado
  - [ ] Descripción clara del proyecto
  - [ ] Instrucciones de instalación
  - [ ] Ejemplos de uso
  - [ ] API documentation links
- [ ] **CHANGELOG.md** actualizado con nueva versión
- [ ] **LICENSE** presente y correcto
- [ ] **pubspec.yaml** metadata completo
  - [ ] description (60-180 caracteres)
  - [ ] homepage URL
  - [ ] repository URL
  - [ ] issue_tracker URL
  - [ ] documentation URL

### 🧪 Quality Assurance
- [ ] **Tests passing**: `dart test` ✅
- [ ] **Analysis clean**: `dart analyze` sin issues
- [ ] **Formatting**: `dart format --set-exit-if-changed .` ✅
- [ ] **Coverage**: ≥ 80% test coverage
- [ ] **pub.dev score**: Verificar con `dart pub publish --dry-run`

### 📦 Package Structure
- [ ] **example/** directory con ejemplos funcionales
- [ ] **lib/** estructura organizada
  - [ ] API pública en `lib/src/`
  - [ ] Export principal en `lib/${options.name}.dart`
- [ ] **.gitignore** apropiado
- [ ] **analysis_options.yaml** configurado

## 🎯 pub.dev Score Optimization

### Convention Score (30 puntos)
- [ ] **Package name**: snake_case, descriptivo
- [ ] **Version**: Semantic versioning (semver)
- [ ] **Description**: Clara y concisa
- [ ] **Homepage**: URL válida
- [ ] **Repository**: GitHub/GitLab URL

### Documentation Score (30 puntos)
- [ ] **README.md**: Completo con ejemplos
- [ ] **API docs**: `/// documentation` en APIs públicas
- [ ] **Example**: Código de ejemplo funcional
- [ ] **CHANGELOG.md**: Historial de cambios

### Platform Score (20 puntos)
${isFlutter ? '''- [ ] **Platforms supported**: Android, iOS, Web, etc.
- [ ] **Platform implementation**: Native code si es plugin
- [ ] **Platform testing**: Verificar en todas las plataformas''' : '''- [ ] **Dart compatibility**: Múltiples versiones Dart
- [ ] **Platform independence**: No dependencias específicas de plataforma'''}

### Analysis Score (30 puntos)
- [ ] **Static analysis**: Sin warnings/errors
- [ ] **Code formatting**: Dart formatter aplicado
- [ ] **Lints**: Seguir recommended lints

### Dependencies Score (20 puntos)
- [ ] **Up-to-date dependencies**: Últimas versiones
- [ ] **Minimal dependencies**: Solo dependencias necesarias
- [ ] **Constraint ranges**: Versioning apropiado

## 🔄 Version Management

### Semantic Versioning
```
MAJOR.MINOR.PATCH
```

- **MAJOR**: Breaking changes (incompatible API changes)
- **MINOR**: New features (backwards compatible)
- **PATCH**: Bug fixes (backwards compatible)

### Pre-release Versions
- `1.0.0-alpha` - Alpha release
- `1.0.0-beta` - Beta release  
- `1.0.0-rc.1` - Release candidate

### Version Update Checklist
- [ ] Version bumped en `pubspec.yaml`
- [ ] CHANGELOG.md actualizado
- [ ] Git tag creado: `git tag v1.0.0`
- [ ] Breaking changes documentados

## 🚀 Publication Process

### 1. Dry Run
```bash
dart pub publish --dry-run
```
- [ ] Score estimado ≥ 120 puntos
- [ ] No errores de validación
- [ ] Archivos incluidos correctos

### 2. Local Testing
```bash
# Create local package
dart pub publish --dry-run

# Test in another project
dart pub add ${options.name} --dev
```

### 3. Publish to pub.dev
```bash
dart pub publish
```

### 4. Post-Publication
- [ ] Verificar package en pub.dev
- [ ] Verificar documentation generada
- [ ] Verificar example funcional
- [ ] Crear GitHub release

## 📊 pub.dev Metrics

### Expected Scores
- **130 puntos**: Excelente (objetivo)
- **120+ puntos**: Muy bueno
- **100+ puntos**: Bueno
- **< 100 puntos**: Necesita mejoras

### Score Breakdown
```
Convention:    30/30  ✅
Documentation: 30/30  ✅  
Platform:      20/20  ✅
Analysis:      30/30  ✅
Dependencies:  20/20  ✅
TOTAL:        130/130 🎯
```

## 🔍 Quality Verification

### Pre-publish Commands
```bash
# 1. Clean analysis
dart analyze --fatal-infos

# 2. Format check
dart format --set-exit-if-changed .

# 3. Test with coverage
dart test --coverage=coverage

# 4. Dry run publish
dart pub publish --dry-run

# 5. Dependency check
dart pub deps
```

### Example Testing
```bash
# Test example works
cd example
dart pub get
${isFlutter ? 'flutter run' : 'dart run'}
```

## 📱 ${isFlutter ? 'Platform Testing' : 'Cross-platform Testing'}

${isFlutter ? '''### Flutter Platforms
```bash
# Android
flutter build apk
flutter test integration_test/

# iOS  
flutter build ios
flutter test integration_test/

# Web
flutter build web
flutter test integration_test/

# Desktop
flutter build windows
flutter build macos
flutter build linux
```''' : '''### Dart Platforms
```bash
# Test on different Dart versions
dart --version
dart test

# Verify compatibility
dart pub deps
dart analyze
```'''}

## 🎯 Publication Strategy

### First Release (v1.0.0)
- [ ] Feature complete
- [ ] Well documented
- [ ] Thoroughly tested
- [ ] Example included
- [ ] API stable

### Maintenance Releases
- [ ] **Patch** (1.0.x): Bug fixes only
- [ ] **Minor** (1.x.0): New features, backwards compatible
- [ ] **Major** (x.0.0): Breaking changes, migration guide

## 📈 Post-Publication

### Monitoring
- [ ] pub.dev analytics review
- [ ] GitHub issues monitoring
- [ ] User feedback collection
- [ ] Performance metrics tracking

### Community
- [ ] Respond to issues/PRs promptly
- [ ] Update documentation based on feedback
- [ ] Consider feature requests
- [ ] Maintain backwards compatibility

### Marketing
- [ ] Social media announcement
- [ ] Blog post (optional)
- [ ] Community forums (Reddit, Discord)
- [ ] Documentation site update

## ⚠️ Common Issues

### Publication Failures
- **Score too low**: Improve documentation/examples
- **Missing files**: Check .gitignore, add to files
- **Analysis errors**: Fix all warnings/errors
- **Version conflicts**: Check dependency constraints

### Post-Publication Issues
- **Documentation not generating**: Check public API docs
- **Example not working**: Verify example dependencies
- **Installation issues**: Check minimum SDK requirements

## ✅ Final Checklist

### Before Publishing
- [ ] ✅ All tests pass
- [ ] ✅ Documentation complete  
- [ ] ✅ Example functional
- [ ] ✅ pub.dev dry-run successful
- [ ] ✅ Version tagged in git
- [ ] ✅ CHANGELOG updated

### After Publishing
- [ ] ✅ Package visible on pub.dev
- [ ] ✅ Documentation generated correctly
- [ ] ✅ Example installable and runnable
- [ ] ✅ GitHub release created
- [ ] ✅ Community notification sent

---

**🎉 Congratulations!** Your package is now available to the Flutter/Dart community!

**Next Steps:**
1. Monitor for issues and feedback
2. Plan next version features
3. Engage with the community
4. Keep dependencies updated

**Remember**: Publishing is just the beginning. Great packages are maintained over time! 🌱
''';
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
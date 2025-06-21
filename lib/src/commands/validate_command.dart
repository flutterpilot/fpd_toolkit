import 'dart:io';
import 'package:args/args.dart';
import 'package:yaml/yaml.dart';
import 'base_command.dart';
import '../utils/logger.dart';

/// Comando para validar paquetes existentes
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
        'help',
        abbr: 'h',
        negatable: false,
        help: 'Muestra ayuda para este comando',
      );
  }

  @override
  String get name => 'validate';

  @override
  String get description => 'Valida un paquete Flutter/Dart existente';

  @override
  ArgParser get argParser => _argParser;

  @override
  Future<void> run(ArgResults argResults) async {
    if (argResults['help'] as bool) {
      showHelp();
      return;
    }

    final args = argResults.rest;
    String packagePath = '.';
    
    if (args.isNotEmpty) {
      packagePath = args[0];
    }

    final packageDir = Directory(packagePath);
    if (!packageDir.existsSync()) {
      Logger.error('❌ Directorio no encontrado: $packagePath');
      return;
    }

    final strict = argResults['strict'] as bool;
    final fix = argResults['fix'] as bool;

    Logger.info('🔍 Validando paquete en: ${packageDir.path}');
    
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
          message: 'Archivo faltante: $fileName',
          file: fileName,
          fixable: fix && fileName != 'pubspec.yaml',
        ));
        
        if (fix && fileName != 'pubspec.yaml') {
          await _createMissingFile(packageDir, fileName);
          Logger.info('🔧 Creado archivo faltante: $fileName');
        }
      } else {
        Logger.success('✅ $fileName encontrado');
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
            message: 'Versión no sigue semantic versioning: $version',
            file: 'pubspec.yaml',
          ));
        }
      }

      // Validar publish_to
      if (!yaml.containsKey('publish_to') || yaml['publish_to'] != 'none') {
        issues.add(ValidationIssue(
          type: IssueType.warning,
          message: 'Considera usar "publish_to: none" para evitar publicación accidental',
          file: 'pubspec.yaml',
        ));
      }

      Logger.success('✅ pubspec.yaml validado');

    } catch (e) {
      issues.add(ValidationIssue(
        type: IssueType.error,
        message: 'Error leyendo pubspec.yaml: $e',
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
        message: 'Directorio faltante: lib/',
        file: 'lib/',
        fixable: fix,
      ));
      
      if (fix) {
        await libDir.create();
        Logger.info('🔧 Creado directorio: lib/');
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
                message: 'Archivo principal faltante: lib/$packageName.dart',
                file: 'lib/$packageName.dart',
                fixable: fix,
              ));
              
              if (fix) {
                await _createMainLibraryFile(packageDir, packageName);
                Logger.info('🔧 Creado archivo principal: lib/$packageName.dart');
              }
            } else {
              Logger.success('✅ Archivo principal encontrado: lib/$packageName.dart');
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
        message: 'Directorio recomendado faltante: test/',
        file: 'test/',
        fixable: fix,
      ));
      
      if (fix) {
        await testDir.create();
        await _createBasicTestFile(packageDir);
        Logger.info('🔧 Creado directorio: test/ con test básico');
      }
    } else {
      Logger.success('✅ Directorio test/ encontrado');
    }

    Logger.success('✅ Estructura de directorios validada');
  }

  Future<void> _validateDocumentation(Directory packageDir, List<ValidationIssue> issues, bool strict, bool fix) async {
    // Validar README.md
    final readmeFile = File('${packageDir.path}/README.md');
    if (readmeFile.existsSync()) {
      final content = await readmeFile.readAsString();
      
      if (content.length < 100) {
        issues.add(ValidationIssue(
          type: IssueType.warning,
          message: 'README.md muy corto, considera añadir más información',
          file: 'README.md',
        ));
      }
      
      if (!content.contains('##') && !content.contains('#')) {
        issues.add(ValidationIssue(
          type: IssueType.warning,
          message: 'README.md sin secciones, considera añadir headers',
          file: 'README.md',
        ));
      }
      
      if (strict && !content.contains('```')) {
        issues.add(ValidationIssue(
          type: IssueType.warning,
          message: 'README.md sin ejemplos de código',
          file: 'README.md',
        ));
      }
    }

    // Validar analysis_options.yaml
    final analysisFile = File('${packageDir.path}/analysis_options.yaml');
    if (!analysisFile.existsSync()) {
      issues.add(ValidationIssue(
        type: IssueType.warning,
        message: 'Archivo recomendado faltante: analysis_options.yaml',
        file: 'analysis_options.yaml',
        fixable: fix,
      ));
      
      if (fix) {
        await _createAnalysisOptionsFile(packageDir);
        Logger.info('🔧 Creado: analysis_options.yaml');
      }
    }
  }

  void _checkPubspecField(Map yaml, String field, List<ValidationIssue> issues, bool required) {
    if (!yaml.containsKey(field)) {
      issues.add(ValidationIssue(
        type: required ? IssueType.error : IssueType.warning,
        message: 'pubspec.yaml: Falta el campo "$field"',
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
      Logger.success('\n✅ Paquete válido! Cumple con las mejores prácticas.');
      Logger.info('\n📋 Recomendaciones adicionales:');
      Logger.info('   - Ejecuta "dart pub deps" para verificar dependencias');
      Logger.info('   - Ejecuta "dart analyze" para análisis estático');
      Logger.info('   - Ejecuta "dart test" para ejecutar pruebas');
      Logger.info('   - Considera usar "pana" para análisis completo de pub.dev');
    } else {
      Logger.error('\n❌ Se encontraron $errors errores y $warnings advertencias:');
      
      for (final issue in issues) {
        final icon = issue.type == IssueType.error ? '❌' : '⚠️';
        final fixableText = issue.fixable ? ' (auto-corregible)' : '';
        Logger.info('   $icon ${issue.message}$fixableText');
      }

      if (issues.any((i) => i.fixable)) {
        Logger.info('\n🔧 Para auto-corregir problemas:');
        Logger.info('   fpd-toolkit validate $packagePath --fix');
      }
    }

    Logger.info('\n📈 Puntuación estimada pub.dev:');
    final score = _calculateScore(errors, warnings);
    final scoreColor = score >= 100 ? '🟢' : score >= 80 ? '🟡' : '🔴';
    Logger.info('   $scoreColor $score/130 puntos');
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

Uso: fpd-toolkit validate [directorio] [opciones]

Argumentos:
  [directorio]         Directorio del paquete a validar (default: directorio actual)

Opciones:
  -s, --strict         Validación estricta (más estricto que pub.dev)
  -f, --fix            Intenta arreglar problemas automáticamente
  -h, --help           Muestra esta ayuda

Ejemplos:
  fpd-toolkit validate
  fpd-toolkit validate ./mi_paquete
  fpd-toolkit validate ./mi_paquete --strict
  fpd-toolkit validate ./mi_paquete --fix

La validación verifica:
  ✅ Archivos requeridos (pubspec.yaml, README.md, etc.)
  ✅ Estructura de directorios
  ✅ Metadatos en pubspec.yaml
  ✅ Documentación básica
  ✅ Configuración de análisis

Puntuación:
  🟢 100+ puntos: Excelente calidad
  🟡 80+ puntos:  Buena calidad  
  🔴 <80 puntos:  Necesita mejoras
''');
  }
}

/// Tipos de problemas de validación
enum IssueType { error, warning }

/// Representa un problema encontrado durante la validación
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
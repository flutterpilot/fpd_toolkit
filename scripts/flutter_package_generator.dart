#!/usr/bin/env dart

import 'dart:io';
import 'dart:math';
import 'dart:async';

/// Generador de paquetes Flutter/Dart que respeta las mejores prácticas
/// de pub.dev y las convenciones de la plataforma
class FlutterPackageGenerator {
  static const String version = '1.0.0';
  
  // Templates de archivos
  static const Map<String, String> templates = {
    'flutter_app': '''
name: {{project_name}}
description: {{description}}
publish_to: none
version: 1.0.0+1

environment:
  sdk: ^3.7.0-0

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.3
{{#additional_dependencies}}
  {{name}}: {{version}}
{{/additional_dependencies}}

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
{{#dev_dependencies}}
  {{name}}: {{version}}
{{/dev_dependencies}}

flutter:
  uses-material-design: true
{{#has_assets}}
  assets:
{{#assets}}
    - {{path}}
{{/assets}}
{{/has_assets}}
{{#has_fonts}}
  fonts:
{{#fonts}}
    - family: {{family}}
      fonts:
        - asset: {{asset}}
{{#weight}}
          weight: {{weight}}
{{/weight}}
{{/fonts}}
{{/has_fonts}}
''',
    
    'flutter_plugin': '''
name: {{project_name}}
description: {{description}}
version: 0.0.1
homepage: {{homepage}}
repository: {{repository}}
issue_tracker: {{issue_tracker}}
documentation: {{documentation}}

environment:
  sdk: ^3.7.0-0
  flutter: ">=3.24.0"

dependencies:
  flutter:
    sdk: flutter
  plugin_platform_interface: ^2.1.8
{{#additional_dependencies}}
  {{name}}: {{version}}
{{/additional_dependencies}}

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  pigeon: ^22.0.0
{{#dev_dependencies}}
  {{name}}: {{version}}
{{/dev_dependencies}}

flutter:
  plugin:
    platforms:
{{#platforms}}
      {{platform}}:
{{#android}}
        package: {{package}}
        pluginClass: {{plugin_class}}
{{/android}}
{{#ios}}
        pluginClass: {{plugin_class}}
{{/ios}}
{{#web}}
        pluginClass: {{plugin_class}}
        fileName: {{file_name}}
{{/web}}
{{#windows}}
        pluginClass: {{plugin_class}}
{{/windows}}
{{#linux}}
        pluginClass: {{plugin_class}}
{{/linux}}
{{#macos}}
        pluginClass: {{plugin_class}}
{{/macos}}
{{/platforms}}
''',

    'dart_package': '''
name: {{project_name}}
description: {{description}}
version: 1.0.0
homepage: {{homepage}}
repository: {{repository}}
issue_tracker: {{issue_tracker}}
documentation: {{documentation}}

environment:
  sdk: ^3.7.0-0

dependencies:
{{#dependencies}}
  {{name}}: {{version}}
{{/dependencies}}

dev_dependencies:
  test: ^1.24.0
  lints: ^5.0.0
{{#dev_dependencies}}
  {{name}}: {{version}}
{{/dev_dependencies}}
''',

    'readme_template': '''
# {{project_name}}

{{description}}

## Features

{{#features}}
- {{feature}}
{{/features}}

## Getting started

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  {{project_name}}: ^{{version}}
```

Then run:

```bash
flutter pub get
```

## Usage

```dart
import 'package:{{project_name}}/{{project_name}}.dart';

{{usage_example}}
```

## API Reference

{{#api_docs}}
### {{class_name}}

{{class_description}}

#### Methods

{{#methods}}
- `{{method_signature}}` - {{method_description}}
{{/methods}}

{{/api_docs}}

## Additional information

{{additional_info}}

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the {{license}} License - see the [LICENSE](LICENSE) file for details.
''',

    'changelog_template': '''
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial release

### Changed

### Deprecated

### Removed

### Fixed

### Security

## [{{version}}] - {{date}}

### Added
- Initial version of {{project_name}}
{{#initial_features}}
- {{feature}}
{{/initial_features}}
''',

    'license_mit': '''
MIT License

Copyright (c) {{year}} {{author}}

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
''',

    'analysis_options': '''
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    # Dart Style
    - prefer_single_quotes
    - avoid_unnecessary_containers
    - prefer_const_constructors
    - prefer_const_literals_to_create_immutables
    - prefer_const_declarations
    - prefer_final_locals
    - unnecessary_const
    - unnecessary_new
    
    # Documentation
    - public_member_api_docs
    - comment_references
    
    # Design
    - prefer_relative_imports
    - avoid_print
    - avoid_web_libraries_in_flutter
    - use_key_in_widget_constructors
    
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
  errors:
    invalid_annotation_target: ignore
    missing_required_param: error
    missing_return: error
''',

    'example_main': '''
import 'package:flutter/material.dart';
{{#additional_imports}}
import '{{import}}';
{{/additional_imports}}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '{{project_name}} Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '{{project_name}} Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  {{example_state}}

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
            {{example_body}}
          ],
        ),
      ),
      {{#has_fab}}
      floatingActionButton: FloatingActionButton(
        onPressed: {{fab_action}},
        tooltip: '{{fab_tooltip}}',
        child: {{fab_child}},
      ),
      {{/has_fab}}
    );
  }
}
''',

    'lib_main': '''
/// {{project_name}} - {{description}}
library {{project_name}};

{{#exports}}
export '{{export}}';
{{/exports}}
''',

    'test_template': '''
import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/{{project_name}}.dart';

void main() {
  group('{{project_name}}', () {
    test('should be tested', () {
      // TODO: Implement tests
      expect(true, isTrue);
    });
  });
}
''',
  };

  /// Configuración del paquete
  static Map<String, dynamic> config = {};

  static Future<void> main(List<String> args) async {
    print('🚀 Flutter Package Generator v$version');
    print('Generador de paquetes Flutter/Dart con mejores prácticas\n');

    if (args.isEmpty || args.contains('--help') || args.contains('-h')) {
      _showHelp();
      return;
    }

    final command = args[0];
    
    try {
      switch (command) {
        case 'create':
          await _createPackage(args.skip(1).toList());
          break;
        case 'validate':
          await _validatePackage(args.skip(1).toList());
          break;
        case 'template':
          await _showTemplates();
          break;
        default:
          print('❌ Comando desconocido: $command');
          _showHelp();
      }
    } catch (e) {
      print('❌ Error: $e');
      exit(1);
    }
  }

  static void _showHelp() {
    print('''
Uso: dart flutter_package_generator.dart <comando> [opciones]

Comandos:
  create <tipo> <nombre>    Crea un nuevo paquete
  validate <directorio>     Valida un paquete existente
  template                  Muestra templates disponibles

Tipos de paquete:
  app                      Aplicación Flutter
  plugin                   Plugin Flutter
  package                  Paquete Dart
  
Opciones:
  --description <desc>     Descripción del paquete
  --author <autor>         Autor del paquete
  --organization <org>     Organización (com.example)
  --platform <platforms>   Plataformas soportadas (android,ios,web,windows,linux,macos)
  --template <template>    Template específico a usar
  --output <directorio>    Directorio de salida (por defecto: nombre del paquete)

Ejemplos:
  dart flutter_package_generator.dart create app mi_app --description "Mi aplicación Flutter"
  dart flutter_package_generator.dart create plugin mi_plugin --platform android,ios
  dart flutter_package_generator.dart validate ./mi_paquete
  dart flutter_package_generator.dart template
''');
  }

  static Future<void> _createPackage(List<String> args) async {
    if (args.length < 2) {
      print('❌ Uso: create <tipo> <nombre> [opciones]');
      return;
    }

    final type = args[0];
    final name = args[1];

    // Validar nombre del paquete
    if (!_isValidPackageName(name)) {
      print('❌ Nombre de paquete inválido: $name');
      print('   Debe usar snake_case y contener solo letras, números y guiones bajos');
      return;
    }

    // Parsear argumentos
    final options = _parseArguments(args.skip(2).toList());
    
    // Configurar valores por defecto
    config = {
      'project_name': name,
      'description': options['description'] ?? 'A new ${type == 'app' ? 'Flutter application' : type == 'plugin' ? 'Flutter plugin' : 'Dart package'}.',
      'author': options['author'] ?? 'Your Name',
      'organization': options['organization'] ?? 'com.example',
      'output': options['output'] ?? name,
      'platforms': _parsePlatforms(options['platform'] ?? 'android,ios'),
      'type': type,
      'version': '1.0.0',
      'year': DateTime.now().year.toString(),
      'date': DateTime.now().toIso8601String().split('T')[0],
    };

    print('📦 Creando paquete tipo "$type" con nombre "$name"...');
    
    try {
      await _generatePackageStructure();
      print('✅ Paquete creado exitosamente en: ${config['output']}');
      print('\n📋 Próximos pasos:');
      print('   1. cd ${config['output']}');
      print('   2. flutter pub get');
      if (type == 'app') {
        print('   3. flutter run');
      } else {
        print('   3. dart test');
      }
      print('   4. Personaliza tu ${type == 'app' ? 'aplicación' : 'paquete'}');
      print('\n🔍 Para validar tu paquete:');
      print('   dart pub global activate pana');
      print('   pana ${config['output']}');
    } catch (e) {
      print('❌ Error creando paquete: $e');
      rethrow;
    }
  }

  static bool _isValidPackageName(String name) {
    final regex = RegExp(r'^[a-z][a-z0-9_]*$');
    return regex.hasMatch(name) && 
           !name.startsWith('_') && 
           !name.endsWith('_') && 
           !name.contains('__');
  }

  static Map<String, String> _parseArguments(List<String> args) {
    final options = <String, String>{};
    
    for (int i = 0; i < args.length; i++) {
      if (args[i].startsWith('--')) {
        final key = args[i].substring(2);
        if (i + 1 < args.length && !args[i + 1].startsWith('--')) {
          options[key] = args[i + 1];
          i++;
        }
      }
    }
    
    return options;
  }

  static List<String> _parsePlatforms(String platformString) {
    return platformString.split(',').map((p) => p.trim()).toList();
  }

  static Future<void> _generatePackageStructure() async {
    final outputDir = Directory(config['output'] as String);
    
    if (outputDir.existsSync()) {
      print('❌ El directorio ${config['output']} ya existe');
      throw Exception('Directory already exists');
    }

    await outputDir.create(recursive: true);

    final type = config['type'] as String;
    
    switch (type) {
      case 'app':
        await _generateFlutterApp(outputDir);
        break;
      case 'plugin':
        await _generateFlutterPlugin(outputDir);
        break;
      case 'package':
        await _generateDartPackage(outputDir);
        break;
      default:
        throw Exception('Unknown package type: $type');
    }
  }

  static Future<void> _generateFlutterApp(Directory outputDir) async {
    // Crear estructura de directorios
    await _createDirectoryStructure(outputDir, [
      'lib',
      'test',
      'android/app',
      'ios/Runner',
      'web',
      'linux',
      'macos/Runner',
      'windows/runner',
      'assets/images',
      'assets/fonts',
    ]);

    // Generar archivos
    await _writeFile(outputDir, 'pubspec.yaml', _processTemplate('flutter_app'));
    await _writeFile(outputDir, 'README.md', _processTemplate('readme_template'));
    await _writeFile(outputDir, 'CHANGELOG.md', _processTemplate('changelog_template'));
    await _writeFile(outputDir, 'LICENSE', _processTemplate('license_mit'));
    await _writeFile(outputDir, 'analysis_options.yaml', _processTemplate('analysis_options'));
    
    // Archivos de código
    await _writeFile(outputDir, 'lib/main.dart', _processTemplate('example_main', {
      'example_state': 'int _counter = 0;\n\n  void _incrementCounter() {\n    setState(() {\n      _counter++;\n    });\n  }',
      'example_body': 'const Text(\n              \'You have pushed the button this many times:\',\n            ),\n            Text(\n              \'\$_counter\',\n              style: Theme.of(context).textTheme.headlineMedium,\n            ),',
      'has_fab': true,
      'fab_action': '_incrementCounter',
      'fab_tooltip': 'Increment',
      'fab_child': 'const Icon(Icons.add)',
    }));
    
    await _writeFile(outputDir, 'test/widget_test.dart', _processTemplate('test_template'));

    // .gitignore
    await _writeFile(outputDir, '.gitignore', _generateGitignore());
  }

  static Future<void> _generateFlutterPlugin(Directory outputDir) async {
    final name = config['project_name'] as String;
    final platforms = config['platforms'] as List<String>;

    // Crear estructura de directorios
    final dirs = ['lib', 'test', 'example'];
    
    if (platforms.contains('android')) dirs.add('android/src/main/java');
    if (platforms.contains('ios')) dirs.add('ios/Classes');
    if (platforms.contains('web')) dirs.add('lib/src');
    if (platforms.contains('windows')) dirs.add('windows');
    if (platforms.contains('linux')) dirs.add('linux');
    if (platforms.contains('macos')) dirs.add('macos/Classes');

    await _createDirectoryStructure(outputDir, dirs);

    // Generar pubspec.yaml con configuración de plataformas
    final platformsConfig = _generatePlatformsConfig(platforms);
    
    await _writeFile(outputDir, 'pubspec.yaml', _processTemplate('flutter_plugin', {
      'platforms': platformsConfig,
      'homepage': 'https://github.com/yourorg/${name}',
      'repository': 'https://github.com/yourorg/${name}',
      'issue_tracker': 'https://github.com/yourorg/${name}/issues',
      'documentation': 'https://pub.dev/documentation/${name}/latest/',
    }));

    await _writeFile(outputDir, 'README.md', _processTemplate('readme_template'));
    await _writeFile(outputDir, 'CHANGELOG.md', _processTemplate('changelog_template'));
    await _writeFile(outputDir, 'LICENSE', _processTemplate('license_mit'));
    await _writeFile(outputDir, 'analysis_options.yaml', _processTemplate('analysis_options'));

    // Archivo principal del plugin
    await _writeFile(outputDir, 'lib/${name}.dart', _processTemplate('lib_main', {
      'exports': ['src/${name}_platform_interface.dart', 'src/${name}_method_channel.dart']
    }));

    // Archivos de implementación
    await _generatePluginImplementation(outputDir, name, platforms);

    await _writeFile(outputDir, 'test/${name}_test.dart', _processTemplate('test_template'));
    await _writeFile(outputDir, '.gitignore', _generateGitignore());
  }

  static Future<void> _generateDartPackage(Directory outputDir) async {
    // Crear estructura básica
    await _createDirectoryStructure(outputDir, [
      'lib/src',
      'test',
      'example',
    ]);

    await _writeFile(outputDir, 'pubspec.yaml', _processTemplate('dart_package', {
      'homepage': 'https://github.com/yourorg/${config['project_name']}',
      'repository': 'https://github.com/yourorg/${config['project_name']}',
      'issue_tracker': 'https://github.com/yourorg/${config['project_name']}/issues',
      'documentation': 'https://pub.dev/documentation/${config['project_name']}/latest/',
    }));

    await _writeFile(outputDir, 'README.md', _processTemplate('readme_template'));
    await _writeFile(outputDir, 'CHANGELOG.md', _processTemplate('changelog_template'));
    await _writeFile(outputDir, 'LICENSE', _processTemplate('license_mit'));
    await _writeFile(outputDir, 'analysis_options.yaml', _processTemplate('analysis_options'));

    final name = config['project_name'] as String;
    await _writeFile(outputDir, 'lib/${name}.dart', _processTemplate('lib_main', {
      'exports': ['src/${name}_base.dart']
    }));

    // Implementación básica
    await _writeFile(outputDir, 'lib/src/${name}_base.dart', '''
/// Base class for ${name}
class ${_toPascalCase(name)} {
  /// Creates a new instance of ${_toPascalCase(name)}
  const ${_toPascalCase(name)}();
  
  /// Example method
  String hello() {
    return 'Hello from ${name}!';
  }
}
''');

    await _writeFile(outputDir, 'test/${name}_test.dart', _processTemplate('test_template'));
    await _writeFile(outputDir, '.gitignore', _generateGitignore());
  }

  static Future<void> _createDirectoryStructure(Directory outputDir, List<String> paths) async {
    for (final path in paths) {
      final dir = Directory('${outputDir.path}/$path');
      await dir.create(recursive: true);
    }
  }

  static Future<void> _writeFile(Directory outputDir, String path, String content) async {
    final file = File('${outputDir.path}/$path');
    await file.parent.create(recursive: true);
    await file.writeAsString(content);
  }

  static String _processTemplate(String templateName, [Map<String, dynamic>? additionalData]) {
    String template = templates[templateName] ?? '';
    final data = {...config, ...?additionalData};
    
    // Simple template engine
    data.forEach((key, value) {
      if (value is String) {
        template = template.replaceAll('{{$key}}', value);
      } else if (value is bool) {
        if (value) {
          template = template.replaceAll('{{#$key}}', '').replaceAll('{{/$key}}', '');
        } else {
          template = _removeSection(template, key);
        }
      } else if (value is List) {
        template = _processListSection(template, key, value);
      }
    });
    
    // Limpiar variables no reemplazadas
    template = template.replaceAll(RegExp(r'\{\{[^}]*\}\}'), '');
    
    return template;
  }

  static String _removeSection(String template, String sectionName) {
    final startPattern = '{{#$sectionName}}';
    final endPattern = '{{/$sectionName}}';
    
    final startIndex = template.indexOf(startPattern);
    if (startIndex == -1) return template;
    
    final endIndex = template.indexOf(endPattern, startIndex);
    if (endIndex == -1) return template;
    
    return template.substring(0, startIndex) + 
           template.substring(endIndex + endPattern.length);
  }

  static String _processListSection(String template, String sectionName, List items) {
    final startPattern = '{{#$sectionName}}';
    final endPattern = '{{/$sectionName}}';
    
    final startIndex = template.indexOf(startPattern);
    if (startIndex == -1) return template;
    
    final endIndex = template.indexOf(endPattern, startIndex);
    if (endIndex == -1) return template;
    
    final sectionTemplate = template.substring(
      startIndex + startPattern.length,
      endIndex
    );
    
    final buffer = StringBuffer();
    for (final item in items) {
      String itemTemplate = sectionTemplate;
      if (item is Map<String, dynamic>) {
        item.forEach((key, value) {
          itemTemplate = itemTemplate.replaceAll('{{$key}}', value.toString());
        });
      }
      buffer.write(itemTemplate);
    }
    
    return template.substring(0, startIndex) + 
           buffer.toString() + 
           template.substring(endIndex + endPattern.length);
  }

  static List<Map<String, dynamic>> _generatePlatformsConfig(List<String> platforms) {
    return platforms.map((platform) {
      final Map<String, dynamic> platformConfig = {'platform': platform};
      
      switch (platform) {
        case 'android':
          platformConfig['android'] = true;
          platformConfig['package'] = '${FlutterPackageGenerator.config['organization']}.${FlutterPackageGenerator.config['project_name']}';
          platformConfig['plugin_class'] = '${_toPascalCase(FlutterPackageGenerator.config['project_name'] as String)}Plugin';
          break;
        case 'ios':
          platformConfig['ios'] = true;
          platformConfig['plugin_class'] = 'Swift${_toPascalCase(FlutterPackageGenerator.config['project_name'] as String)}Plugin';
          break;
        case 'web':
          platformConfig['web'] = true;
          platformConfig['plugin_class'] = '${_toPascalCase(FlutterPackageGenerator.config['project_name'] as String)}Web';
          platformConfig['file_name'] = '${FlutterPackageGenerator.config['project_name']}_web.dart';
          break;
        case 'windows':
          platformConfig['windows'] = true;
          platformConfig['plugin_class'] = '${_toPascalCase(FlutterPackageGenerator.config['project_name'] as String)}PluginCApi';
          break;
        case 'linux':
          platformConfig['linux'] = true;
          platformConfig['plugin_class'] = '${_toPascalCase(FlutterPackageGenerator.config['project_name'] as String)}Plugin';
          break;
        case 'macos':
          platformConfig['macos'] = true;
          platformConfig['plugin_class'] = '${_toPascalCase(FlutterPackageGenerator.config['project_name'] as String)}Plugin';
          break;
      }
      
      return platformConfig;
    }).toList();
  }

  static Future<void> _generatePluginImplementation(Directory outputDir, String name, List<String> platforms) async {
    // Platform interface
    await _writeFile(outputDir, 'lib/src/${name}_platform_interface.dart', '''
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '${name}_method_channel.dart';

abstract class ${_toPascalCase(name)}Platform extends PlatformInterface {
  ${_toPascalCase(name)}Platform() : super(token: _token);

  static final Object _token = Object();

  static ${_toPascalCase(name)}Platform _instance = MethodChannel${_toPascalCase(name)}();

  static ${_toPascalCase(name)}Platform get instance => _instance;

  static set instance(${_toPascalCase(name)}Platform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('getPlatformVersion() has not been implemented.');
  }
}
''');

    // Method channel implementation
    await _writeFile(outputDir, 'lib/src/${name}_method_channel.dart', '''
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '${name}_platform_interface.dart';

class MethodChannel${_toPascalCase(name)} extends ${_toPascalCase(name)}Platform {
  @visibleForTesting
  final methodChannel = const MethodChannel('${name}');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
''');

    // Generate platform-specific code
    if (platforms.contains('android')) {
      await _generateAndroidCode(outputDir, name);
    }
    if (platforms.contains('ios')) {
      await _generateiOSCode(outputDir, name);
    }
  }

  static Future<void> _generateAndroidCode(Directory outputDir, String name) async {
    final packagePath = '${config['organization']}.${name}'.replaceAll('.', '/');
    
    await _writeFile(outputDir, 'android/src/main/java/$packagePath/${_toPascalCase(name)}Plugin.java', '''
package ${config['organization']}.${name};

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class ${_toPascalCase(name)}Plugin implements FlutterPlugin, MethodCallHandler {
  private MethodChannel channel;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "${name}");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
''');
  }

  static Future<void> _generateiOSCode(Directory outputDir, String name) async {
    await _writeFile(outputDir, 'ios/Classes/Swift${_toPascalCase(name)}Plugin.swift', '''
import Flutter
import UIKit

public class Swift${_toPascalCase(name)}Plugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "${name}", binaryMessenger: registrar.messenger())
    let instance = Swift${_toPascalCase(name)}Plugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
''');
  }

  static String _toPascalCase(String input) {
    return input.split('_').map((word) => 
      word[0].toUpperCase() + word.substring(1)).join('');
  }

  static String _generateGitignore() {
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

# The .vscode folder contains launch configuration and tasks you configure in
# VS Code which you may wish to be included in version control, so this line
# is commented out by default.
#.vscode/

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
''';
  }

  static Future<void> _validatePackage(List<String> args) async {
    if (args.isEmpty) {
      print('❌ Uso: validate <directorio>');
      return;
    }

    final packageDir = Directory(args[0]);
    if (!packageDir.existsSync()) {
      print('❌ Directorio no encontrado: ${args[0]}');
      return;
    }

    print('🔍 Validando paquete en: ${packageDir.path}');
    
    final issues = <String>[];
    
    // Validar archivos requeridos
    final requiredFiles = ['pubspec.yaml', 'README.md', 'CHANGELOG.md', 'LICENSE'];
    for (final file in requiredFiles) {
      if (!File('${packageDir.path}/$file').existsSync()) {
        issues.add('❌ Archivo faltante: $file');
      } else {
        print('✅ $file encontrado');
      }
    }

    // Validar pubspec.yaml
    final pubspecFile = File('${packageDir.path}/pubspec.yaml');
    if (pubspecFile.existsSync()) {
      await _validatePubspec(pubspecFile, issues);
    }

    // Validar estructura de directorios
    await _validateDirectoryStructure(packageDir, issues);

    if (issues.isEmpty) {
      print('\n✅ Paquete válido! Cumple con las mejores prácticas.');
      print('\n📋 Recomendaciones adicionales:');
      print('   - Ejecuta "dart pub deps" para verificar dependencias');
      print('   - Ejecuta "dart analyze" para análisis estático');
      print('   - Ejecuta "dart test" para ejecutar pruebas');
      print('   - Considera usar "pana" para análisis completo de pub.dev');
    } else {
      print('\n❌ Se encontraron ${issues.length} problemas:');
      for (final issue in issues) {
        print('   $issue');
      }
    }
  }

  static Future<void> _validatePubspec(File pubspecFile, List<String> issues) async {
    try {
      final content = await pubspecFile.readAsString();
      
      // Validaciones básicas del pubspec.yaml
      if (!content.contains('name:')) {
        issues.add('❌ pubspec.yaml: Falta el campo "name"');
      }
      
      if (!content.contains('description:')) {
        issues.add('❌ pubspec.yaml: Falta el campo "description"');
      }
      
      if (!content.contains('version:')) {
        issues.add('❌ pubspec.yaml: Falta el campo "version"');
      }
      
      if (!content.contains('environment:')) {
        issues.add('❌ pubspec.yaml: Falta el campo "environment"');
      }
      
      if (content.contains('publish_to:') && !content.contains('publish_to: none')) {
        issues.add('⚠️  pubspec.yaml: Considera usar "publish_to: none" para evitar publicación accidental');
      }
      
      print('✅ pubspec.yaml validado');
    } catch (e) {
      issues.add('❌ Error leyendo pubspec.yaml: $e');
    }
  }

  static Future<void> _validateDirectoryStructure(Directory packageDir, List<String> issues) async {
    // Validar estructura de lib/
    final libDir = Directory('${packageDir.path}/lib');
    if (!libDir.existsSync()) {
      issues.add('❌ Directorio faltante: lib/');
    } else {
      // Buscar archivo principal
      final pubspecFile = File('${packageDir.path}/pubspec.yaml');
      if (pubspecFile.existsSync()) {
        final content = await pubspecFile.readAsString();
        final nameMatch = RegExp(r'name:\s*(.+)').firstMatch(content);
        if (nameMatch != null) {
          final packageName = nameMatch.group(1)!.trim();
          final mainFile = File('${packageDir.path}/lib/$packageName.dart');
          if (!mainFile.existsSync()) {
            issues.add('❌ Archivo principal faltante: lib/$packageName.dart');
          } else {
            print('✅ Archivo principal encontrado: lib/$packageName.dart');
          }
        }
      }
    }

    // Validar directorio test/
    final testDir = Directory('${packageDir.path}/test');
    if (!testDir.existsSync()) {
      issues.add('⚠️  Directorio recomendado faltante: test/');
    } else {
      print('✅ Directorio test/ encontrado');
    }

    print('✅ Estructura de directorios validada');
  }

  static Future<void> _showTemplates() async {
    print('📋 Templates disponibles:\n');
    
    print('🏗️  Tipos de paquete:');
    print('   app     - Aplicación Flutter completa');
    print('   plugin  - Plugin Flutter multiplataforma');
    print('   package - Paquete Dart puro');
    
    print('\n📁 Estructura generada:');
    print('''
   app/
   ├── pubspec.yaml
   ├── README.md
   ├── CHANGELOG.md
   ├── LICENSE
   ├── analysis_options.yaml
   ├── lib/
   │   └── main.dart
   ├── test/
   │   └── widget_test.dart
   └── assets/
       ├── images/
       └── fonts/

   plugin/
   ├── pubspec.yaml
   ├── README.md
   ├── CHANGELOG.md
   ├── LICENSE
   ├── analysis_options.yaml
   ├── lib/
   │   ├── plugin_name.dart
   │   └── src/
   ├── test/
   ├── android/
   ├── ios/
   └── example/

   package/
   ├── pubspec.yaml
   ├── README.md
   ├── CHANGELOG.md
   ├── LICENSE
   ├── analysis_options.yaml
   ├── lib/
   │   ├── package_name.dart
   │   └── src/
   └── test/
''');

    print('\n🎯 Mejores prácticas incluidas:');
    print('   ✅ Nombres de paquete válidos (snake_case)');
    print('   ✅ Estructura de archivos estándar');
    print('   ✅ Análisis estático configurado');
    print('   ✅ Documentación básica');
    print('   ✅ Licencia MIT incluida');
    print('   ✅ Configuración de dependencias actualizada');
    print('   ✅ Soporte multiplataforma (plugins)');
    print('   ✅ Ejemplos de uso incluidos');
  }
}

// Punto de entrada principal
void main(List<String> args) async {
  await FlutterPackageGenerator.main(args);
}
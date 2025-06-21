import 'dart:io';
import 'package:args/args.dart';
import 'base_command.dart';
import '../generators/package_generator.dart';
import '../utils/logger.dart';
import '../utils/validator.dart';

/// Comando para crear nuevos paquetes Flutter/Dart
class CreateCommand extends Command {
  late final ArgParser _argParser;

  CreateCommand() {
    _argParser = ArgParser()
      ..addOption(
        'description',
        abbr: 'd',
        help: 'Descripción del paquete',
      )
      ..addOption(
        'author',
        abbr: 'a',
        help: 'Autor del paquete',
        defaultsTo: 'Your Name',
      )
      ..addOption(
        'organization',
        abbr: 'o',
        help: 'Organización (ej: com.example)',
        defaultsTo: 'com.example',
      )
      ..addOption(
        'platforms',
        abbr: 'p',
        help: 'Plataformas soportadas (separadas por coma)',
        defaultsTo: 'android,ios',
      )
      ..addOption(
        'output',
        help: 'Directorio de salida',
      )
      ..addOption(
        'template',
        abbr: 't',
        help: 'Template específico a usar',
      )
      ..addFlag(
        'force',
        abbr: 'f',
        negatable: false,
        help: 'Sobrescribe archivos existentes',
      )
      ..addFlag(
        'help',
        abbr: 'h',
        negatable: false,
        help: 'Muestra ayuda para este comando',
      );
  }

  @override
  String get name => 'create';

  @override
  String get description => 'Crea un nuevo paquete Flutter/Dart con mejores prácticas';

  @override
  ArgParser get argParser => _argParser;

  @override
  Future<void> run(ArgResults argResults) async {
    if (argResults['help'] as bool) {
      showHelp();
      return;
    }

    final args = argResults.rest;
    if (args.length < 2) {
      Logger.error('❌ Uso: fpd-toolkit create <tipo> <nombre> [opciones]');
      Logger.info('Tipos disponibles: app, plugin, package');
      return;
    }

    final type = args[0];
    final name = args[1];

    // Validar nombre del paquete
    if (!Validator.isValidPackageName(name)) {
      Logger.error('❌ Nombre de paquete inválido: $name');
      Logger.info('   El nombre debe usar snake_case y contener solo letras, números y guiones bajos');
      return;
    }

    // Validar tipo
    if (!['app', 'plugin', 'package'].contains(type)) {
      Logger.error('❌ Tipo de paquete inválido: $type');
      Logger.info('   Tipos válidos: app, plugin, package');
      return;
    }

    // Configurar opciones
    final options = PackageOptions(
      name: name,
      type: type,
      description: argResults['description'] as String? ?? 
          _getDefaultDescription(type),
      author: argResults['author'] as String,
      organization: argResults['organization'] as String,
      platforms: _parsePlatforms(argResults['platforms'] as String),
      outputDir: argResults['output'] as String? ?? name,
      template: argResults['template'] as String?,
      force: argResults['force'] as bool,
    );

    // Verificar si el directorio ya existe
    final outputDir = Directory(options.outputDir);
    if (outputDir.existsSync() && !options.force) {
      Logger.error('❌ El directorio ${options.outputDir} ya existe');
      Logger.info('   Usa --force para sobrescribir');
      return;
    }

    try {
      Logger.info('📦 Creando paquete tipo "$type" con nombre "$name"...');
      
      final generator = PackageGenerator();
      await generator.generate(options);
      
      Logger.success('✅ Paquete creado exitosamente en: ${options.outputDir}');
      _showNextSteps(options);
      
    } catch (e) {
      Logger.error('❌ Error creando paquete: $e');
      exit(1);
    }
  }

  String _getDefaultDescription(String type) {
    switch (type) {
      case 'app':
        return 'Una nueva aplicación Flutter';
      case 'plugin':
        return 'Un nuevo plugin Flutter';
      case 'package':
        return 'Un nuevo paquete Dart';
      default:
        return 'Un nuevo proyecto Flutter/Dart';
    }
  }

  List<String> _parsePlatforms(String platformString) {
    return platformString.split(',').map((p) => p.trim()).toList();
  }

  void _showNextSteps(PackageOptions options) {
    Logger.info('\n📋 Próximos pasos:');
    Logger.info('   1. cd ${options.outputDir}');
    
    if (options.type == 'app') {
      Logger.info('   2. flutter pub get');
      Logger.info('   3. flutter run');
    } else {
      Logger.info('   2. dart pub get');
      Logger.info('   3. dart test');
    }
    
    Logger.info('   4. Personaliza tu ${options.type}');
    Logger.info('\n🔍 Para validar tu paquete:');
    Logger.info('   fpd-toolkit validate ${options.outputDir}');
    Logger.info('\n📖 Para ver guías de desarrollo:');
    Logger.info('   fpd-toolkit guide --all');
  }

  @override
  void showHelp() {
    print('''
$description

Uso: fpd-toolkit create <tipo> <nombre> [opciones]

Tipos de paquete:
  app                      Aplicación Flutter
  plugin                   Plugin Flutter
  package                  Paquete Dart

Argumentos:
  <tipo>                   Tipo de paquete a crear
  <nombre>                 Nombre del paquete (snake_case)

Opciones:
  -d, --description        Descripción del paquete
  -a, --author             Autor del paquete
  -o, --organization       Organización (ej: com.example)
  -p, --platforms          Plataformas soportadas (android,ios,web,windows,linux,macos)
      --output             Directorio de salida (por defecto: nombre del paquete)
  -t, --template           Template específico a usar
  -f, --force              Sobrescribe archivos existentes
  -h, --help               Muestra esta ayuda

Ejemplos:
  fpd-toolkit create app mi_app --description "Mi aplicación increíble"
  fpd-toolkit create plugin mi_plugin --platforms android,ios,web
  fpd-toolkit create package mi_paquete --author "Tu Nombre"
''');
  }
}
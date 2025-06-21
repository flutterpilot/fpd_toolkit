import 'dart:io';
import 'package:args/args.dart';
import 'commands/commands.dart';
import 'utils/logger.dart';

/// Runner principal del CLI
class CliRunner {
  late final ArgParser _parser;
  late final Map<String, Command> _commands;

  /// Crea una nueva instancia del CLI runner
  CliRunner() {
    _setupCommands();
    _setupParser();
  }

  void _setupCommands() {
    _commands = {
      'create': CreateCommand(),
      'validate': ValidateCommand(),
      'guide': GuideCommand(),
      'example': ExampleCommand(),
      'template': TemplateCommand(),
      'init': InitCommand(),
    };
  }

  void _setupParser() {
    _parser = ArgParser()
      ..addFlag(
        'help',
        abbr: 'h',
        negatable: false,
        help: 'Muestra ayuda para el comando',
      )
      ..addFlag(
        'version',
        abbr: 'v',
        negatable: false,
        help: 'Muestra la versión del CLI',
      )
      ..addFlag(
        'verbose',
        negatable: false,
        help: 'Habilita logging detallado',
      );

    // Agregar subcomandos
    for (final command in _commands.values) {
      _parser.addCommand(command.name, command.argParser);
    }
  }

  /// Ejecuta el CLI con los argumentos proporcionados
  Future<void> run(List<String> arguments) async {
    try {
      final results = _parser.parse(arguments);

      // Configurar logging
      if (results['verbose'] as bool) {
        Logger.enableVerbose();
      }

      // Mostrar versión
      if (results['version'] as bool) {
        _showVersion();
        return;
      }

      // Mostrar ayuda general
      if (results['help'] as bool || results.command == null) {
        _showHelp();
        return;
      }

      // Ejecutar comando
      final commandName = results.command!.name;
      final command = _commands[commandName];
      
      if (command != null) {
        await command.run(results.command!);
      } else {
        Logger.error('Comando desconocido: $commandName');
        _showHelp();
        exit(1);
      }
    } catch (e) {
      Logger.error('Error ejecutando comando: $e');
      exit(1);
    }
  }

  void _showVersion() {
    Logger.info('🚀 FPD Toolkit v1.0.0');
    Logger.info('Generador de paquetes Flutter/Dart con mejores prácticas');
  }

  void _showHelp() {
    print('🚀 FPD Toolkit - CLI para desarrollo Flutter/Dart profesional');
    print('''
Uso: fpd-toolkit <comando> [argumentos]

Comandos disponibles:
  create      Crea un nuevo paquete Flutter/Dart
  validate    Valida un paquete existente
  guide       Muestra guías de desarrollo
  example     Genera ejemplos de código
  template    Gestiona templates de proyecto
  init        Inicializa un proyecto existente

Opciones globales:
  -h, --help      Muestra esta ayuda
  -v, --version   Muestra la versión
      --verbose   Habilita logging detallado

Ejemplos:
  fpd-toolkit create app mi_app
  fpd-toolkit create plugin mi_plugin --platforms android,ios
  fpd-toolkit validate ./mi_paquete
  fpd-toolkit guide architecture
  fpd-toolkit template list

Para ayuda específica de un comando:
  fpd-toolkit <comando> --help

Documentación completa:
  fpd-toolkit guide --all
''');
  }
}
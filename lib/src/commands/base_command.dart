import 'package:args/args.dart';

/// Clase base abstracta para todos los comandos
abstract class Command {
  /// Nombre del comando
  String get name;

  /// Descripción del comando
  String get description;

  /// Parser de argumentos para este comando
  ArgParser get argParser;

  /// Ejecuta el comando con los argumentos parseados
  Future<void> run(ArgResults argResults);

  /// Muestra ayuda específica del comando
  void showHelp() {
    print('Uso: fpd-toolkit $name [opciones]\n');
    print(argParser.usage);
  }
}
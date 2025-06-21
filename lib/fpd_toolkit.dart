/// fpd_toolkit - CLI toolkit para generar paquetes Flutter/Dart de alta calidad con mejores prácticas
library fpd_toolkit;

export 'src/cli_runner.dart';
export 'src/commands/commands.dart';
export 'src/generators/generators.dart';
export 'src/templates/templates.dart';
export 'src/utils/utils.dart';

import 'src/cli_runner.dart';

/// Clase principal del CLI
class FpdToolkit {
  /// Ejecuta el CLI con los argumentos proporcionados
  static Future<void> run(List<String> arguments) async {
    final runner = CliRunner();
    await runner.run(arguments);
  }
}

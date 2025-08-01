/// fpd_toolkit - Professional CLI toolkit for generating high-quality Flutter/Dart packages following industry best practices
library;

export 'src/cli_runner.dart';
export 'src/commands/commands.dart';
export 'src/generators/generators.dart';
export 'src/templates/templates.dart';
export 'src/utils/utils.dart';

import 'src/cli_runner.dart';

/// Main CLI class for FPD Toolkit
class FpdToolkit {
  /// Runs the CLI with the provided arguments
  static Future<void> run(List<String> arguments) async {
    final runner = CliRunner();
    await runner.run(arguments);
  }
}

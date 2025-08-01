import 'dart:io';
import 'package:args/args.dart';
import 'commands/commands.dart';
import 'utils/logger.dart';

/// Main CLI runner for FPD Toolkit
class CliRunner {
  late final ArgParser _parser;
  late final Map<String, Command> _commands;

  /// Creates a new instance of the CLI runner
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
        help: 'Show help for the command',
      )
      ..addFlag(
        'version',
        abbr: 'v',
        negatable: false,
        help: 'Show CLI version',
      )
      ..addFlag(
        'verbose',
        negatable: false,
        help: 'Enable detailed logging',
      );

    // Add subcommands
    for (final command in _commands.values) {
      _parser.addCommand(command.name, command.argParser);
    }
  }

  /// Runs the CLI with the provided arguments
  Future<void> run(List<String> arguments) async {
    try {
      final results = _parser.parse(arguments);

      // Configure logging
      if (results['verbose'] as bool) {
        Logger.enableVerbose();
      }

      // Show version
      if (results['version'] as bool) {
        _showVersion();
        return;
      }

      // Show general help
      if (results['help'] as bool || results.command == null) {
        _showHelp();
        return;
      }

      // Execute command
      final commandName = results.command!.name;
      final command = _commands[commandName];
      
      if (command != null) {
        await command.run(results.command!);
      } else {
        Logger.error('Unknown command: $commandName');
        _showHelp();
        exit(1);
      }
    } catch (e) {
      Logger.error('Error executing command: $e');
      exit(1);
    }
  }

  void _showVersion() {
    Logger.info('🚀 FPD Toolkit v1.0.0');
    Logger.info('Professional Flutter/Dart package generator with best practices');
  }

  void _showHelp() {
    print('🚀 FPD Toolkit - Professional Flutter/Dart development CLI');
    print('''
Usage: fpd-toolkit <command> [arguments]

Available commands:
  create      Create a new Flutter/Dart package
  validate    Validate an existing package
  guide       Show development guides
  example     Generate code examples
  template    Manage project templates
  init        Initialize an existing project

Global options:
  -h, --help      Show this help
  -v, --version   Show version
      --verbose   Enable detailed logging

Examples:
  fpd-toolkit create app my_app
  fpd-toolkit create plugin my_plugin --platforms android,ios
  fpd-toolkit validate ./my_package
  fpd-toolkit guide --list
  fpd-toolkit template list

For specific command help:
  fpd-toolkit <command> --help

Complete documentation:
  fpd-toolkit guide --list
''');
  }
}
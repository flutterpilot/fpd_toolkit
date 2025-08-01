import 'dart:io';
import 'package:args/args.dart';
import 'base_command.dart';
import '../generators/package_generator.dart';
import '../utils/logger.dart';
import '../utils/validator.dart';
import '../utils/interactive_prompt.dart';

/// Command to create new Flutter/Dart packages with interactive prompts
class CreateCommand extends Command {
  late final ArgParser _argParser;

  CreateCommand() {
    _argParser = ArgParser()
      ..addOption(
        'description',
        abbr: 'd',
        help: 'Package description',
      )
      ..addOption(
        'author',
        abbr: 'a',
        help: 'Package author',
      )
      ..addOption(
        'organization',
        abbr: 'o',
        help: 'Organization (e.g., com.example)',
      )
      ..addOption(
        'platforms',
        abbr: 'p',
        help: 'Supported platforms (comma-separated)',
      )
      ..addOption(
        'output',
        help: 'Output directory',
      )
      ..addOption(
        'template',
        abbr: 't',
        help: 'Specific template to use',
      )
      ..addFlag(
        'force',
        abbr: 'f',
        negatable: false,
        help: 'Overwrite existing files',
      )
      ..addFlag(
        'non-interactive',
        negatable: false,
        help: 'Run in non-interactive mode (use defaults/arguments only)',
      )
      ..addFlag(
        'help',
        abbr: 'h',
        negatable: false,
        help: 'Show help for this command',
      );
  }

  @override
  String get name => 'create';

  @override
  String get description => 'Create a new Flutter/Dart package with best practices';

  @override
  ArgParser get argParser => _argParser;

  @override
  Future<void> run(ArgResults argResults) async {
    if (argResults['help'] as bool) {
      showHelp();
      return;
    }

    final isNonInteractive = argResults['non-interactive'] as bool;
    final args = argResults.rest;

    // Get package information interactively or from arguments
    final packageInfo = await _gatherPackageInformation(argResults, args, isNonInteractive);
    
    if (packageInfo == null) {
      Logger.error('❌ Package creation cancelled');
      return;
    }

    // Verify directory doesn't exist or get confirmation to overwrite
    final outputDir = Directory(packageInfo.outputDir);
    if (outputDir.existsSync() && !packageInfo.force) {
      if (isNonInteractive) {
        Logger.error('❌ Directory ${packageInfo.outputDir} already exists');
        Logger.info('   Use --force to overwrite');
        return;
      }

      InteractivePrompt.showWarning('Directory ${packageInfo.outputDir} already exists');
      final shouldOverwrite = InteractivePrompt.promptConfirm(
        question: 'Do you want to overwrite it?',
        defaultValue: false,
      );

      if (!shouldOverwrite) {
        Logger.info('Package creation cancelled');
        return;
      }
    }

    try {
      Logger.info('📦 Creating ${packageInfo.type} package "${packageInfo.name}"...');
      
      final generator = PackageGenerator();
      await generator.generate(packageInfo);
      
      Logger.success('✅ Package created successfully in: ${packageInfo.outputDir}');
      _showNextSteps(packageInfo);
      
    } catch (e) {
      Logger.error('❌ Error creating package: $e');
      exit(1);
    }
  }

  /// Gather all package information interactively or from arguments
  Future<PackageOptions?> _gatherPackageInformation(
    ArgResults argResults, 
    List<String> args, 
    bool isNonInteractive
  ) async {
    if (!isNonInteractive) {
      InteractivePrompt.showHeader('🚀 FPD Toolkit - Package Creator');
      InteractivePrompt.showInfo('Creating high-quality Flutter/Dart packages with best practices');
      print('');
    }

    // 1. Get package type
    String? type;
    if (args.isNotEmpty) {
      type = args[0];
      if (!['app', 'plugin', 'package'].contains(type)) {
        if (isNonInteractive) {
          Logger.error('❌ Invalid package type: $type');
          Logger.info('   Valid types: app, plugin, package');
          return null;
        }
        type = null; // Will be prompted for
      }
    }

    if (type == null) {
      if (isNonInteractive) {
        Logger.error('❌ Package type is required in non-interactive mode');
        Logger.info('   Usage: fpd-toolkit create <type> [name] [options]');
        return null;
      }

      type = InteractivePrompt.promptSelect(
        question: 'What type of package do you want to create?',
        options: ['app', 'plugin', 'package'],
        defaultValue: 'package',
      );
    }

    // 2. Get package name
    String? name;
    if (args.length > 1) {
      name = args[1];
      if (!Validator.isValidPackageName(name)) {
        if (isNonInteractive) {
          Logger.error('❌ Invalid package name: $name');
          Logger.info('   Package names must use snake_case and contain only letters, numbers, and underscores');
          return null;
        }
        name = null; // Will be prompted for
      }
    }

    if (name == null) {
      if (isNonInteractive) {
        Logger.error('❌ Package name is required in non-interactive mode');
        Logger.info('   Usage: fpd-toolkit create $type <name> [options]');
        return null;
      }

      name = InteractivePrompt.promptPackageName(
        suggestedName: _generateSuggestedName(type),
      );
    }

    if (!isNonInteractive) {
      print(''); // Add spacing
    }

    // 3. Get description
    String? description = argResults['description'] as String?;
    if (description == null && !isNonInteractive) {
      description = InteractivePrompt.promptDescription(
        packageType: type,
        packageName: name,
      );
    }
    description ??= _getDefaultDescription(type, name);

    // 4. Get author
    String? author = argResults['author'] as String?;
    if (author == null && !isNonInteractive) {
      author = InteractivePrompt.promptAuthor();
    }
    author ??= _getDefaultAuthor();

    // 5. Get organization
    String? organization = argResults['organization'] as String?;
    if (organization == null && !isNonInteractive) {
      organization = InteractivePrompt.promptOrganization();
    }
    organization ??= 'com.example';

    // 6. Get platforms (for plugins and apps)
    List<String> platforms = [];
    if (type == 'plugin' || type == 'app') {
      final platformsString = argResults['platforms'] as String?;
      if (platformsString != null) {
        platforms = _parsePlatforms(platformsString);
      } else if (!isNonInteractive) {
        final availablePlatforms = [
          'android', 'ios', 'web', 'windows', 'linux', 'macos'
        ];
        final defaultPlatforms = type == 'plugin' 
          ? ['android', 'ios'] 
          : ['android', 'ios', 'web'];
        
        platforms = InteractivePrompt.promptMultiSelect(
          question: 'Which platforms do you want to support?',
          options: availablePlatforms,
          defaultValues: defaultPlatforms,
        );
      } else {
        platforms = type == 'plugin' 
          ? ['android', 'ios'] 
          : ['android', 'ios', 'web'];
      }
    }

    // 7. Get output directory
    final String outputDir = argResults['output'] as String? ?? name;

    // 8. Get template
    final String? template = argResults['template'] as String?;

    // 9. Get force flag
    final bool force = argResults['force'] as bool;

    // 10. Show summary if interactive
    if (!isNonInteractive) {
      print('');
      InteractivePrompt.showHeader('📋 Package Summary');
      print('  Type: $type');
      print('  Name: $name');
      print('  Description: $description');
      print('  Author: $author');
      print('  Organization: $organization');
      if (platforms.isNotEmpty) {
        print('  Platforms: ${platforms.join(', ')}');
      }
      print('  Output Directory: $outputDir');
      print('');

      final shouldContinue = InteractivePrompt.promptConfirm(
        question: 'Create this package?',
        defaultValue: true,
      );

      if (!shouldContinue) {
        return null;
      }
      print('');
    }

    return PackageOptions(
      name: name,
      type: type,
      description: description,
      author: author,
      organization: organization,
      platforms: platforms,
      outputDir: outputDir,
      template: template,
      force: force,
    );
  }

  String _generateSuggestedName(String type) {
    switch (type) {
      case 'app':
        return 'my_flutter_app';
      case 'plugin':
        return 'my_flutter_plugin';
      case 'package':
        return 'my_dart_package';
      default:
        return 'my_package';
    }
  }

  String _getDefaultDescription(String type, String name) {
    switch (type) {
      case 'app':
        return 'A new Flutter application - $name';
      case 'plugin':
        return 'A new Flutter plugin for $name functionality';
      case 'package':
        return 'A new Dart package for $name utilities';
      default:
        return 'A new Flutter/Dart project';
    }
  }

  String _getDefaultAuthor() {
    final systemUser = Platform.environment['USER'] ?? 
                      Platform.environment['USERNAME'] ?? 
                      'Your Name';
    return systemUser;
  }

  List<String> _parsePlatforms(String platformString) {
    return platformString.split(',').map((p) => p.trim()).toList();
  }

  void _showNextSteps(PackageOptions options) {
    InteractivePrompt.showHeader('🎉 Next Steps');
    print('1. cd ${options.outputDir}');
    
    if (options.type == 'app') {
      print('2. flutter pub get');
      print('3. flutter run');
    } else {
      print('2. dart pub get');
      print('3. dart test');
    }
    
    print('4. Customize your ${options.type}');
    print('');
    print('🔍 To validate your package:');
    print('   fpd-toolkit validate ${options.outputDir}');
    print('');
    print('📖 To view development guides:');
    print('   fpd-toolkit guide --list');
    print('   fpd-toolkit guide best-practices architecture-structure');
    print('');
  }

  @override
  void showHelp() {
    print('''
$description

Usage: fpd-toolkit create [type] [name] [options]

Package Types:
  app                      Flutter application
  plugin                   Flutter plugin
  package                  Dart package

Arguments (all optional in interactive mode):
  [type]                   Package type to create
  [name]                   Package name (snake_case)

Options:
  -d, --description        Package description
  -a, --author             Package author
  -o, --organization       Organization (e.g., com.example)
  -p, --platforms          Supported platforms (android,ios,web,windows,linux,macos)
      --output             Output directory (default: package name)
  -t, --template           Specific template to use
  -f, --force              Overwrite existing files
      --non-interactive    Run in non-interactive mode
  -h, --help               Show this help

Interactive Examples:
  fpd-toolkit create                    # Interactive mode - asks everything
  fpd-toolkit create app                # Interactive mode - asks name and options
  fpd-toolkit create app my_app         # Interactive mode - asks remaining options

Non-Interactive Examples:
  fpd-toolkit create app my_app --description "My awesome app" --non-interactive
  fpd-toolkit create plugin my_plugin --platforms android,ios --author "Your Name"
  fpd-toolkit create package my_package --organization com.yourcompany
''');
  }
}
import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';
import 'base_command.dart';
import '../utils/logger.dart';

/// Information about a guide file
class GuideInfo {
  const GuideInfo({
    required this.title,
    required this.description,
    required this.filePath,
    required this.category,
    required this.content,
  });

  final String title;
  final String description;
  final String filePath;
  final String category;
  final String content;
}

/// Command to show development guides from .fpd directory
class GuideCommand extends Command {
  late final ArgParser _argParser;
  Map<String, GuideInfo>? _cachedGuides;

  GuideCommand() {
    _argParser = ArgParser()
      ..addFlag(
        'list',
        abbr: 'l',
        negatable: false,
        help: 'List all available guides',
      )
      ..addFlag(
        'all',
        negatable: false,
        help: 'Show all guides',
      )
      ..addFlag(
        'copy',
        abbr: 'c',
        negatable: false,
        help: 'Copy guides to current directory',
      )
      ..addOption(
        'output',
        abbr: 'o',
        help: 'Directory where to copy guides',
        defaultsTo: './doc',
      )
      ..addFlag(
        'help',
        abbr: 'h',
        negatable: false,
        help: 'Show help for this command',
      );
  }

  @override
  String get name => 'guide';

  @override
  String get description => 'Show Flutter/Dart development guides from .fpd directory';

  @override
  ArgParser get argParser => _argParser;

  @override
  Future<void> run(ArgResults argResults) async {
    if (argResults['help'] as bool) {
      showHelp();
      return;
    }

    if (argResults['list'] as bool) {
      _listGuides();
      return;
    }

    if (argResults['copy'] as bool) {
      await _copyGuides(argResults['output'] as String);
      return;
    }

    if (argResults['all'] as bool) {
      await _showAllGuides();
      return;
    }

    final args = argResults.rest;
    if (args.isEmpty) {
      _listGuides();
      Logger.info('\nUsage: fpd-toolkit guide <guide-path> to view a specific guide');
      Logger.info('       fpd-toolkit guide --all to view all guides');
      return;
    }

    final guidePath = args.join(' ');
    await _showGuide(guidePath);
  }

  void _listGuides() {
    final guides = _discoverGuides();
    
    if (guides.isEmpty) {
      Logger.warning('No guides found in .fpd directory');
      return;
    }

    Logger.info('📚 Available development guides:\n');
    
    // Group by category
    final categorized = <String, List<MapEntry<String, GuideInfo>>>{};
    for (final entry in guides.entries) {
      final category = entry.value.category;
      categorized.putIfAbsent(category, () => []).add(entry);
    }

    for (final categoryEntry in categorized.entries) {
      Logger.info('  📁 ${categoryEntry.key}:');
      for (final guide in categoryEntry.value) {
        final key = guide.key.replaceFirst('${categoryEntry.key} ', '');
        Logger.info('    ${key.padRight(20)} - ${guide.value.title}');
      }
      Logger.info('');
    }

    Logger.info('Usage examples:');
    Logger.info('  fpd-toolkit guide best-practices architecture-structure');
    Logger.info('  fpd-toolkit guide development-guide fundamentals');
    Logger.info('  fpd-toolkit guide --all');
    Logger.info('  fpd-toolkit guide --copy');
  }

  Future<void> _showGuide(String guidePath) async {
    final guides = _discoverGuides();
    final guideInfo = guides[guidePath];
    
    if (guideInfo == null) {
      Logger.error('❌ Guide not found: $guidePath');
      Logger.info('Available guides:');
      for (final key in guides.keys) {
        Logger.info('  $key');
      }
      return;
    }

    Logger.info('📖 ${guideInfo.title}\n');
    Logger.info('${guideInfo.description}\n');
    
    // Display the guide content
    print(guideInfo.content);

    Logger.info('\n📋 For more information:');
    Logger.info('   fpd-toolkit guide --copy  # Copy all guides');
    Logger.info('   fpd-toolkit guide --all   # View all guides');
  }

  Future<void> _showAllGuides() async {
    final guides = _discoverGuides();
    Logger.info('📚 Complete Flutter/Dart development guides\n');
    
    for (final guidePath in guides.keys) {
      Logger.info('=' * 60);
      await _showGuide(guidePath);
      Logger.info('');
    }
  }

  Future<void> _copyGuides(String outputDir) async {
    try {
      final docsDir = Directory(outputDir);
      await docsDir.create(recursive: true);

      final guides = _discoverGuides();
      if (guides.isEmpty) {
        Logger.warning('No guides found in .fpd directory');
        return;
      }

      int copiedCount = 0;
      for (final guideInfo in guides.values) {
        final sourceFile = File(guideInfo.filePath);
        if (sourceFile.existsSync()) {
          final fileName = path.basename(guideInfo.filePath);
          final targetPath = path.join(outputDir, fileName);
          await sourceFile.copy(targetPath);
          Logger.success('✅ Copied: $fileName');
          copiedCount++;
        }
      }

      // Create quick start guide
      await _createQuickStartGuide(outputDir);

      Logger.success('📚 Guides copied successfully to: $outputDir');
      Logger.info('\n📋 Files created: ${copiedCount + 1}');
      Logger.info('   $outputDir/QUICK_START.md');
      for (final guideInfo in guides.values) {
        final fileName = path.basename(guideInfo.filePath);
        Logger.info('   $outputDir/$fileName');
      }

    } catch (e) {
      Logger.error('❌ Error copying guides: $e');
    }
  }

  Future<void> _createQuickStartGuide(String outputDir) async {
    const quickStartContent = '''
# 🚀 Quick Start Guide - FPD Toolkit

## Installation

### Global Activation
```bash
dart pub global activate fpd_toolkit
```

### Direct Usage
```bash
dart pub global run fpd_toolkit
```

## Create your first project

\\`\\`\\`bash
# Flutter Application
fpd-toolkit create app my_app --description "My awesome application"

# Flutter Plugin
fpd-toolkit create plugin my_plugin --platforms android,ios,web

# Dart Package
fpd-toolkit create package my_package --author "Your Name"
\\`\\`\\`

## Validate quality

\\`\\`\\`bash
# Validate package
fpd-toolkit validate ./my_project

# View development guides
fpd-toolkit guide --list
fpd-toolkit guide best-practices architecture-structure
\\`\\`\\`

## Useful examples

\\`\\`\\`bash
# View available templates
fpd-toolkit template list

# Generate code examples
fpd-toolkit example widget

# Initialize existing project
fpd-toolkit init
\\`\\`\\`

## Next steps

1. Explore all guides: `fpd-toolkit guide --all`
2. Check best practices in copied .fpd files
3. Explore commands: `fpd-toolkit --help`

Happy development! 🎉
''';

    final quickStartFile = File(path.join(outputDir, 'QUICK_START.md'));
    await quickStartFile.writeAsString(quickStartContent);
  }

  /// Discover all guide files from .fpd directory
  Map<String, GuideInfo> _discoverGuides() {
    if (_cachedGuides != null) return _cachedGuides!;
    
    final guides = <String, GuideInfo>{};
    final fpdDir = Directory('.fpd');
    
    if (!fpdDir.existsSync()) {
      Logger.verbose('.fpd directory not found');
      return guides;
    }
    
    try {
      // Recursively find all .md files except INDEX.md files
      final mdFiles = fpdDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.md') && 
                     !f.path.contains('INDEX.md') &&
                     !f.path.contains('README.md'))
        .toList();
        
      for (final file in mdFiles) {
        try {
          final guideInfo = _parseGuideFile(file);
          if (guideInfo != null) {
            final key = _generateGuideKey(file.path);
            guides[key] = guideInfo;
          }
        } catch (e) {
          Logger.verbose('Error parsing guide file ${file.path}: $e');
        }
      }
      
      _cachedGuides = guides;
      Logger.verbose('Discovered ${guides.length} guides');
    } catch (e) {
      Logger.verbose('Error discovering guides: $e');
    }
    
    return guides;
  }

  /// Parse a guide file and extract frontmatter and content
  GuideInfo? _parseGuideFile(File file) {
    try {
      final content = file.readAsStringSync();
      
      // Check for YAML frontmatter
      final frontmatterMatch = RegExp(
        r'^---\s*\n(.*?)\n---\s*\n(.*)$',
        dotAll: true,
      ).firstMatch(content);
      
      if (frontmatterMatch == null) {
        // No frontmatter, use filename as title
        final filename = path.basenameWithoutExtension(file.path);
        return GuideInfo(
          title: _formatTitle(filename),
          description: 'Guide: ${_formatTitle(filename)}',
          filePath: file.path,
          category: _extractCategory(file.path),
          content: content,
        );
      }
      
      final yamlString = frontmatterMatch.group(1)!;
      final guideContent = frontmatterMatch.group(2)!.trim();
      
      final yaml = loadYaml(yamlString);
      
      return GuideInfo(
        title: yaml['title']?.toString() ?? _formatTitle(path.basenameWithoutExtension(file.path)),
        description: yaml['description']?.toString() ?? '',
        filePath: file.path,
        category: _extractCategory(file.path),
        content: guideContent,
      );
    } catch (e) {
      Logger.verbose('Error parsing guide file ${file.path}: $e');
      return null;
    }
  }

  /// Generate a user-friendly key for the guide
  String _generateGuideKey(String filePath) {
    // Remove .fpd/ prefix and .md suffix
    var key = filePath.replaceFirst(RegExp(r'.*\.fpd/'), '');
    key = key.replaceFirst(RegExp(r'\.md$'), '');
    
    // Replace / with space for hierarchical commands
    key = key.replaceAll('/', ' ');
    
    return key;
  }

  /// Extract category from file path
  String _extractCategory(String filePath) {
    final parts = filePath.split('/');
    final fpdIndex = parts.indexWhere((p) => p == '.fpd');
    
    if (fpdIndex != -1 && fpdIndex + 1 < parts.length) {
      return parts[fpdIndex + 1];
    }
    
    return 'general';
  }

  /// Format filename to title case
  String _formatTitle(String filename) {
    return filename
        .replaceAll('-', ' ')
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  @override
  void showHelp() {
    final guides = _discoverGuides();
    
    print('''
$description

Usage: fpd-toolkit guide [guide-path] [options]

Available guides:
''');
    
    if (guides.isEmpty) {
      print('  No guides found in .fpd directory');
    } else {
      // Group by category for better display
      final categorized = <String, List<MapEntry<String, GuideInfo>>>{};
      for (final entry in guides.entries) {
        final category = entry.value.category;
        categorized.putIfAbsent(category, () => []).add(entry);
      }

      for (final categoryEntry in categorized.entries) {
        print('  📁 ${categoryEntry.key}:');
        for (final guide in categoryEntry.value) {
          final key = guide.key.replaceFirst('${categoryEntry.key} ', '');
          print('    ${key.padRight(20)} - ${guide.value.title}');
        }
        print('');
      }
    }

    print('''
Options:
  -l, --list           List all available guides
      --all            Show all guides
  -c, --copy           Copy guides to current directory
  -o, --output         Directory where to copy guides (default: ./doc)
  -h, --help           Show this help

Examples:
  fpd-toolkit guide best-practices architecture-structure
  fpd-toolkit guide development-guide fundamentals
  fpd-toolkit guide --list
  fpd-toolkit guide --all
  fpd-toolkit guide --copy --output ./documentation
''');
  }
}
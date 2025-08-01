import 'dart:io';
import 'logger.dart';
import 'validator.dart';

/// Interactive prompt utilities for CLI user input
class InteractivePrompt {
  /// Prompt for text input with validation
  static String? promptText({
    required String question,
    String? defaultValue,
    bool required = false,
    bool Function(String)? validator,
    String? validationMessage,
  }) {
    while (true) {
      // Display question with default value hint
      String prompt = '🔹 $question';
      if (defaultValue != null) {
        prompt += ' ($defaultValue)';
      }
      prompt += ': ';
      
      stdout.write(prompt);
      final input = stdin.readLineSync()?.trim() ?? '';
      
      // Use default if empty and available
      final value = input.isEmpty ? defaultValue : input;
      
      // Check if required
      if (required && (value == null || value.isEmpty)) {
        Logger.error('❌ This field is required');
        continue;
      }
      
      // Return null for non-required empty inputs
      if (value == null || value.isEmpty) {
        return null;
      }
      
      // Validate if validator provided
      if (validator != null && !validator(value)) {
        Logger.error('❌ ${validationMessage ?? 'Invalid input'}');
        continue;
      }
      
      return value;
    }
  }

  /// Prompt for selection from multiple options
  static String promptSelect({
    required String question,
    required List<String> options,
    String? defaultValue,
    bool required = true,
  }) {
    while (true) {
      print('🔹 $question');
      
      for (int i = 0; i < options.length; i++) {
        final isDefault = defaultValue != null && options[i] == defaultValue;
        final marker = isDefault ? '●' : '○';
        print('  $marker ${i + 1}. ${options[i]}${isDefault ? ' (default)' : ''}');
      }
      
      stdout.write('Select option (1-${options.length}): ');
      final input = stdin.readLineSync()?.trim() ?? '';
      
      // Use default if empty and available
      if (input.isEmpty && defaultValue != null) {
        return defaultValue;
      }
      
      // Parse selection
      final selection = int.tryParse(input);
      if (selection != null && selection >= 1 && selection <= options.length) {
        return options[selection - 1];
      }
      
      Logger.error('❌ Please select a valid option (1-${options.length})');
    }
  }

  /// Prompt for multiple selections (comma-separated)
  static List<String> promptMultiSelect({
    required String question,
    required List<String> options,
    List<String>? defaultValues,
    bool required = true,
  }) {
    while (true) {
      print('🔹 $question');
      print('   Available options: ${options.join(', ')}');
      
      if (defaultValues != null && defaultValues.isNotEmpty) {
        print('   Default: ${defaultValues.join(', ')}');
      }
      
      stdout.write('Enter selections (comma-separated): ');
      final input = stdin.readLineSync()?.trim() ?? '';
      
      // Use default if empty and available
      if (input.isEmpty && defaultValues != null && defaultValues.isNotEmpty) {
        return defaultValues;
      }
      
      if (required && input.isEmpty) {
        Logger.error('❌ At least one selection is required');
        continue;
      }
      
      if (input.isEmpty) {
        return [];
      }
      
      // Parse selections
      final selections = input.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      
      // Validate all selections are valid
      final invalidSelections = selections.where((s) => !options.contains(s)).toList();
      if (invalidSelections.isNotEmpty) {
        Logger.error('❌ Invalid options: ${invalidSelections.join(', ')}');
        Logger.info('   Valid options: ${options.join(', ')}');
        continue;
      }
      
      return selections;
    }
  }

  /// Prompt for yes/no confirmation
  static bool promptConfirm({
    required String question,
    bool defaultValue = false,
  }) {
    final defaultText = defaultValue ? 'Y/n' : 'y/N';
    
    while (true) {
      stdout.write('🔹 $question ($defaultText): ');
      final input = stdin.readLineSync()?.trim().toLowerCase() ?? '';
      
      if (input.isEmpty) {
        return defaultValue;
      }
      
      if (input == 'y' || input == 'yes') {
        return true;
      }
      
      if (input == 'n' || input == 'no') {
        return false;
      }
      
      Logger.error('❌ Please enter y/yes or n/no');
    }
  }

  /// Display a header for a section
  static void showHeader(String title) {
    print('\n${'=' * 60}');
    print('  $title');
    print('=' * 60);
  }

  /// Display information message
  static void showInfo(String message) {
    print('ℹ️  $message');
  }

  /// Display warning message
  static void showWarning(String message) {
    print('⚠️  $message');
  }

  /// Display success message
  static void showSuccess(String message) {
    print('✅ $message');
  }

  /// Validate package name with suggestions
  static String promptPackageName({
    String? defaultValue,
    String? suggestedName,
  }) {
    while (true) {
      const String question = 'Package name (snake_case)';
      final String? effectiveDefault = defaultValue ?? suggestedName;
      
      final input = promptText(
        question: question,
        defaultValue: effectiveDefault,
        required: true,
      );
      
      if (input == null) continue;
      
      if (Validator.isValidPackageName(input)) {
        return input;
      }
      
      Logger.error('❌ Invalid package name: $input');
      Logger.info('   Package names must:');
      Logger.info('   - Use snake_case (lowercase with underscores)');
      Logger.info('   - Start with a letter');
      Logger.info('   - Contain only letters, numbers, and underscores');
      Logger.info('   - Not start or end with underscores');
      Logger.info('   - Not contain consecutive underscores');
      
      // Suggest a corrected version
      final suggestion = Validator.toSnakeCase(input);
      if (suggestion != input && Validator.isValidPackageName(suggestion)) {
        Logger.info('   Suggestion: $suggestion');
      }
    }
  }

  /// Validate organization with common formats
  static String promptOrganization({String? defaultValue}) {
    const examples = [
      'com.example',
      'com.yourcompany',
      'org.yourorg',
      'dev.yourname',
    ];
    
    while (true) {
      final input = promptText(
        question: 'Organization (reverse domain format)',
        defaultValue: defaultValue,
        required: false,
      );
      
      if (input == null || input.isEmpty) {
        return 'com.example';
      }
      
      // Basic validation for reverse domain format
      final parts = input.split('.');
      if (parts.length >= 2 && parts.every((part) => part.isNotEmpty && RegExp(r'^[a-z][a-z0-9]*$').hasMatch(part))) {
        return input;
      }
      
      Logger.error('❌ Invalid organization format: $input');
      Logger.info('   Use reverse domain format (e.g., ${examples.join(', ')})');
    }
  }

  /// Validate author name
  static String promptAuthor({String? defaultValue}) {
    final systemUser = Platform.environment['USER'] ?? Platform.environment['USERNAME'];
    final effectiveDefault = defaultValue ?? systemUser ?? 'Your Name';
    
    final input = promptText(
      question: 'Author name',
      defaultValue: effectiveDefault,
      required: true,
    );
    
    return input ?? effectiveDefault;
  }

  /// Prompt for description with type-specific suggestions
  static String promptDescription({
    required String packageType,
    String? packageName,
    String? defaultValue,
  }) {
    String suggestion = '';
    switch (packageType) {
      case 'app':
        suggestion = 'A new Flutter application';
        if (packageName != null) {
          suggestion = 'A new Flutter application - $packageName';
        }
        break;
      case 'plugin':
        suggestion = 'A new Flutter plugin';
        if (packageName != null) {
          suggestion = 'A new Flutter plugin for $packageName functionality';
        }
        break;
      case 'package':
        suggestion = 'A new Dart package';
        if (packageName != null) {
          suggestion = 'A new Dart package for $packageName utilities';
        }
        break;
    }
    
    final input = promptText(
      question: 'Description',
      defaultValue: defaultValue ?? suggestion,
      required: true,
    );
    
    return input ?? suggestion;
  }
}
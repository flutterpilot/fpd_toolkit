# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

FPD Toolkit is a professional CLI toolkit for generating high-quality Flutter/Dart packages following industry best practices. It's a Dart CLI application that generates Flutter/Dart packages with optimal pub.dev scoring (125+ points), interactive guides, and comprehensive documentation.

## Common Development Commands

### Running the CLI
```bash
# Run directly from source (main command for development)
dart run bin/fpd_toolkit.dart [command] [options]

# Examples
dart run bin/fpd_toolkit.dart create package test_pkg --description "Test package"
dart run bin/fpd_toolkit.dart validate test_pkg
dart run bin/fpd_toolkit.dart --verbose create app debug_app
```

### Development and Testing
```bash
# Install dependencies
dart pub get

# Run tests
dart test

# Run tests with coverage
dart test --coverage=coverage
genhtml -o coverage/html coverage/lcov.info

# Code analysis and linting
dart analyze

# Format code
dart format .

# Fix automatic issues
dart fix --apply
```

### Integration Testing
```bash
# Create test packages to verify generation works
dart run bin/fpd_toolkit.dart create package integration_test
dart run bin/fpd_toolkit.dart create app integration_app  
dart run bin/fpd_toolkit.dart create plugin integration_plugin --platforms android,ios
dart run bin/fpd_toolkit.dart validate integration_test
```

## Architecture and Code Structure

### Core Architecture
This is a modular CLI application following the Command Pattern with clean separation of concerns:

- **CLI Entry Point**: `bin/fpd_toolkit.dart` - Main executable
- **CLI Runner**: `lib/src/cli_runner.dart` - Argument parsing and command orchestration
- **Commands**: `lib/src/commands/` - Individual command implementations (create, validate, guide, etc.)
- **Generators**: `lib/src/generators/` - Code generation logic for different project types
- **Utils**: `lib/src/utils/` - Shared utilities (logging, validation, file operations)
- **Templates**: `lib/src/templates/` - Template definitions and management

### Command System
All commands extend `BaseCommand` from `lib/src/commands/base_command.dart`. Commands are registered in `cli_runner.dart` and follow a consistent pattern for argument parsing and execution.

### Package Generation Flow
1. User runs create command with project type (app/package/plugin)
2. `CreateCommand` processes arguments and creates `PackageOptions`
3. `PackageGenerator` handles the generation logic based on project type
4. Files are created using templates with variable substitution
5. Generated project is validated and optimized for pub.dev scoring

### Key Features
- **Multi-type Generation**: Supports Flutter apps, plugins, and Dart packages
- **pub.dev Optimization**: Generated packages achieve 125+ pub.dev points
- **Interactive Guides**: Built-in development guides and examples
- **Template System**: Flexible template management for different project types
- **Validation System**: Comprehensive package validation against pub.dev criteria

## Development Notes

### Adding New Commands
1. Create command class extending `BaseCommand` in `lib/src/commands/`
2. Register in `_setupCommands()` method in `cli_runner.dart`
3. Export in `lib/src/commands/commands.dart`

### Adding New Project Types
1. Add generation logic in `PackageGenerator.generate()` method
2. Create specific generation method (e.g., `_generateNewType()`)
3. Add to the type switch statement in the generator

### Code Style and Standards
- Uses `package:lints/recommended.yaml` for linting
- Prefers single quotes, const constructors, and final declarations
- Public API documentation is disabled for CLI tools
- Print statements are allowed (CLI context)
- Relative imports preferred within lib/

### Testing Strategy
- Unit tests for individual commands and utilities
- Integration tests by generating actual packages and validating them
- Golden tests for template output validation
- Manual testing by running generated packages through pub.dev validation

The project emphasizes clean architecture, extensibility, and following Dart/Flutter best practices to generate high-quality packages that meet professional standards.

## .fpd Directory - Essential Development Resources

**IMPORTANT**: The `.fpd/` directory contains comprehensive Flutter development guidelines, best practices, and standards that MUST be consulted regularly during development. This directory serves as the authoritative source for:

### Directory Structure
- **`.fpd/agents/`** - AI agent configuration and guidelines
- **`.fpd/best-practices/`** - Comprehensive Flutter best practices
- **`.fpd/development-guide/`** - Step-by-step development instructions

### Key Files to Reference
- **`.fpd/agents/agents-base.md`** - Core rule: ALL code and documentation must be in English, regardless of user prompt language
- **`.fpd/best-practices/INDEX.md`** - Complete index of best practices covering architecture, security, testing, performance
- **`.fpd/development-guide/INDEX.md`** - Development lifecycle guidance from setup to publishing

### How to Use .fpd During Development

1. **Before starting any task**: Read relevant files from `.fpd/best-practices/` based on the work type (architecture, testing, security, etc.)

2. **During code generation**: Always apply the English-only rule from `.fpd/agents/agents-base.md` - translate any non-English user requirements to English code/comments

3. **For project structure decisions**: Consult `.fpd/development-guide/project-structure.md`

4. **For quality assurance**: Use `.fpd/best-practices/quality-checklist.md` and `.fpd/development-guide/final-checklist.md`

5. **For specific domains**: Reference appropriate files like:
   - Security: `.fpd/best-practices/security-and-privacy.md`
   - Testing: `.fpd/best-practices/strategic-testing.md`
   - Performance: `.fpd/best-practices/performance-and-optimization.md`
   - UI/UX: `.fpd/best-practices/ui-ux-widgets.md`

### Regular Workflow
```bash
# Before implementing features, search and read relevant .fpd content
find .fpd -name "*.md" -exec grep -l "relevant_topic" {} \;

# For comprehensive guidance, read entire sections
cat .fpd/best-practices/architecture-structure.md
cat .fpd/development-guide/testing-and-quality-assurance.md
```

**Always prioritize the standards and guidelines in .fpd over general assumptions when developing Flutter/Dart projects.**
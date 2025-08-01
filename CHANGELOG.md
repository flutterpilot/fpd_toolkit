# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Example directory with comprehensive usage examples
- English documentation and comments throughout codebase
- Improved pub.dev scoring optimization

### Changed
- Updated library documentation to English
- Enhanced package description for better pub.dev compliance

### Fixed
- Fixed YAML frontmatter corruption in guides
- Updated hardcoded guide references to use dynamic placeholders

## [1.0.0] - 2025-08-01

### Added
- Professional CLI toolkit for generating high-quality Flutter/Dart packages
- Support for creating Flutter applications, plugins, and Dart packages
- Interactive guide system powered by comprehensive `.fpd` directory
- Package validation with pub.dev scoring (125+ points)
- Template management system with customizable templates
- Cross-platform plugin support (Android, iOS, Web, Desktop)
- Comprehensive development guides covering:
  - Architecture patterns (Clean Architecture, MVVM, BLoC)
  - Best practices for security, testing, and performance
  - Complete development lifecycle from setup to publishing
- Code examples for widgets, state management, and testing
- CLI commands: create, validate, guide, example, template, init
- Integration with pub.dev standards for optimal package scoring
- Support for multiple project types with optimized configurations
- Automatic generation of README, CHANGELOG, LICENSE, and analysis_options.yaml
- Interactive development tutorials and step-by-step guides
- Quality assurance tools and validation systems

### Features
- **Multi-type Generation**: Flutter apps, plugins, and Dart packages
- **pub.dev Optimization**: Generated packages achieve 125+ pub.dev points
- **Interactive Guides**: Built-in development guides and examples from `.fpd` directory
- **Template System**: Flexible template management for different project types
- **Validation System**: Comprehensive package validation against pub.dev criteria
- **Cross-platform Support**: Android, iOS, Web, Windows, macOS, Linux
- **Best Practices Integration**: Follows industry standards and Flutter guidelines

### Technical Details
- Dart SDK compatibility: >=3.0.0 <4.0.0
- Dependencies: args, io, path, yaml
- Development dependencies: test, lints
- Executable: fpd-toolkit
- License: MIT


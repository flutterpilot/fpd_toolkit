# 🚀 FPD Toolkit

**Professional CLI toolkit for generating high-quality Flutter/Dart packages following industry best practices.**

FPD Toolkit is a comprehensive tool that enables you to create Flutter/Dart packages that meet all pub.dev standards and development best practices. It includes automatic generation, validation, interactive documentation, and practical examples.

## ✨ Key Features

### 🚀 Automatic Generation
- **Flutter Applications** - Complete apps with Material Design structure
- **Flutter Plugins** - Cross-platform plugins with native interfaces
- **Dart Packages** - Pure libraries optimized for pub.dev

### 🎯 Advanced Validation
- **pub.dev Scoring** - Automatic evaluation achieving 125+ points
- **Code Analysis** - Problem detection and improvements
- **Structure Verification** - Required file validation

### 📚 Interactive Documentation
- **Step-by-step Guides** - Interactive development tutorials from comprehensive `.fpd` directory
- **Practical Examples** - Example code with best practices
- **Architecture Patterns** - Clean Architecture, MVVM, BLoC

### 🛠️ Template Management
- **Custom Templates** - Create and reuse templates
- **Flexible Configuration** - Adapt generation to your needs
- **Multiple Platforms** - Support for Android, iOS, Web, Desktop

## 🚀 Installation

### Global Activation
```bash
dart pub global activate fpd_toolkit
```

### Direct Usage
```bash
dart pub global run fpd_toolkit
```

## 📖 Usage Guide

### Create a New Package
```bash
# Create Dart package
fpd-toolkit create package my_package --description "My awesome package"

# Create Flutter application
fpd-toolkit create app my_app --description "My Flutter application"

# Create Flutter plugin
fpd-toolkit create plugin my_plugin --platforms android,ios --description "My native plugin"
```

### Validate a Package
```bash
fpd-toolkit validate my_package
# Result: 125/130 pub.dev points
```

### Access Interactive Guides

The toolkit now features a dynamic guide system powered by the comprehensive `.fpd` directory:

```bash
# List all available guides organized by category
fpd-toolkit guide --list

# Access specific guides using hierarchical paths
fpd-toolkit guide best-practices architecture-structure
fpd-toolkit guide development-guide fundamentals
fpd-toolkit guide development-guide testing-and-quality-assurance
fpd-toolkit guide best-practices performance-and-optimization
fpd-toolkit guide agents agents-base

# View all guides
fpd-toolkit guide --all

# Copy guides to local directory for offline access
fpd-toolkit guide --copy --output ./documentation
```

### View Code Examples
```bash
fpd-toolkit example widget       # Widget examples
fpd-toolkit example state        # State management
fpd-toolkit example animation    # Animations
fpd-toolkit example testing      # Advanced testing
```

## 🎯 Available Commands

| Command | Description | Example |
|---------|-------------|---------|
| `create` | Generate new package/app/plugin | `fpd-toolkit create package my_lib` |
| `validate` | Validate package for pub.dev | `fpd-toolkit validate my_lib` |
| `guide` | Interactive development guides from .fpd | `fpd-toolkit guide best-practices architecture-structure` |
| `example` | Code examples and patterns | `fpd-toolkit example widget` |
| `template` | Manage custom templates | `fpd-toolkit template list` |
| `init` | Initialize existing project | `fpd-toolkit init` |

## 📁 Generated Project Structure

```
my_package/
├── lib/
│   ├── my_package.dart          # Entry point
│   └── src/
│       └── my_package_base.dart # Main logic
├── test/
│   └── my_package_test.dart     # Tests
├── example/                     # Usage examples
├── pubspec.yaml                 # Optimized configuration
├── README.md                    # Complete documentation
├── CHANGELOG.md                 # Change history
├── LICENSE                      # MIT License
└── analysis_options.yaml       # Code analysis
```

## 🏆 pub.dev Scoring

Generated packages achieve **125+ points** on pub.dev:

- ✅ **Conventions** (30/30) - Naming and structure
- ✅ **Documentation** (30/30) - README, API docs, examples
- ✅ **Platforms** (20/20) - Cross-platform support
- ✅ **Analysis** (30/30) - Clean code analysis
- ✅ **Dependencies** (15/20) - Updated dependencies

## 📚 Comprehensive Documentation

### 🔍 The .fpd Directory - Your Development Knowledge Base

FPD Toolkit includes a comprehensive `.fpd` directory containing professional Flutter/Dart development guidelines:

- **📁 agents/** - AI agent configuration and development rules
- **📁 best-practices/** - Architecture, security, testing, performance optimization
- **📁 development-guide/** - Complete development lifecycle from setup to publishing

#### Available Guides by Category:

**🤖 Agents (1 guide):**
- `agents-base` - Core development rules including English-only code standards

**🏗️ Best Practices (8 guides):**
- `architecture-structure` - Clean Architecture and project organization
- `code-maintenance` - Long-term code maintenance strategies
- `multiplatform-development` - Cross-platform development best practices
- `performance-and-optimization` - Performance optimization techniques
- `quality-checklist` - Quality assurance standards
- `security-and-privacy` - Security and privacy best practices
- `state-management` - State management patterns (BLoC, Provider, Riverpod)
- `strategic-testing` - Comprehensive testing strategies
- `ui-ux-widgets` - UI/UX design and widget guidelines

**📖 Development Guide (10 guides):**
- `additional-resources` - Curated resources and tools
- `best-practices` - Development best practices overview
- `environment-setup` - Development environment configuration
- `final-checklist` - Pre-release quality checklist
- `fundamentals` - Core Flutter/Dart principles
- `maintenance-and-versioning` - Project maintenance and versioning
- `project-structure` - Recommended project organization
- `publishing-on-pub-dev` - Complete pub.dev publishing guide
- `testing-and-quality-assurance` - Testing methodologies
- `tools-and-scripts` - Development automation tools

### Topics Covered
- 🏗️ **Architecture** - Clean Architecture, MVVM, BLoC
- 🎨 **UI/UX** - Material Design, Cupertino, Responsive
- 🔧 **State** - Provider, Riverpod, BLoC, GetX
- 🧪 **Testing** - Unit, Widget, Integration, Golden
- ⚡ **Performance** - Optimization, Profiling, Memory
- 🔒 **Security** - Encryption, Authentication, Permissions
- 🌐 **Internationalization** - i18n, l10n, Localization
- 📱 **Platforms** - Android, iOS, Web, Desktop

## 🔧 Advanced Configuration

### Environment Variables
```bash
export FLUTTER_DEV_AUTHOR="Your Name"
export FLUTTER_DEV_ORG="com.yourorg"
export FLUTTER_DEV_TEMPLATE_DIR="$HOME/flutter_templates"
```

### Configuration File
```yaml
# ~/.flutter_dev_config.yaml
default_author: "Your Name"
default_organization: "com.yourorg"
default_license: "MIT"
templates_dir: "~/flutter_templates"
```

## 🤝 Usage Examples

### Case 1: Rapid Startup
```bash
# Create complete MVP
fpd-toolkit create app startup_mvp --description "MVP for startup"
cd startup_mvp
fpd-toolkit guide best-practices architecture-structure
flutter run
```

### Case 2: Enterprise Library
```bash
# Create corporate package
fpd-toolkit create package company_utils --description "Corporate utilities"
fpd-toolkit validate company_utils
dart pub publish --dry-run
```

### Case 3: Cross-Platform Plugin
```bash
# Plugin for all platforms
fpd-toolkit create plugin super_plugin \
  --platforms android,ios,web,windows,macos,linux \
  --description "Universal awesome plugin"
```

## 🎯 Use Cases

### 👨‍💻 Developers
- Generate packages with professional structure
- Validate before publishing to pub.dev
- Learn best practices interactively

### 🏢 Companies
- Standardize project structure
- Accelerate MVP development
- Maintain consistent code quality

### 🎓 Education
- Teach Flutter/Dart best practices
- Ready-to-use practical examples
- Interactive step-by-step guides

## 🔄 Recommended Workflow

1. **Planning**
   ```bash
   fpd-toolkit guide best-practices architecture-structure
   ```

2. **Generation**
   ```bash
   fpd-toolkit create package my_lib --description "My library"
   ```

3. **Validation**
   ```bash
   fpd-toolkit validate my_lib
   ```

4. **Development**
   ```bash
   cd my_lib
   fpd-toolkit guide development-guide testing-and-quality-assurance
   fpd-toolkit example widget
   ```

5. **Publishing**
   ```bash
   dart pub publish --dry-run
   dart pub publish
   ```

## 🚀 Local Development

### Clone and Run
```bash
git clone https://github.com/flutterpilot/fpd_toolkit.git
cd fpd_toolkit
dart pub get
dart run bin/fpd_toolkit.dart --help
```

### Execute Commands
```bash
dart run bin/fpd_toolkit.dart create package test_pkg --description "Test package"
dart run bin/fpd_toolkit.dart validate test_pkg
dart run bin/fpd_toolkit.dart guide --help
```

### Verbose Mode
```bash
dart run bin/fpd_toolkit.dart --verbose create package debug_pkg
```

## 🧪 Testing

### Run Tests
```bash
dart test
```

### Testing with Coverage
```bash
dart test --coverage=coverage
genhtml coverage/lcov.info -o coverage/html
```

### Command Testing
```bash
dart run bin/fpd_toolkit.dart --verbose [command]
```

## 📊 Metrics and Performance

### Benchmarks
```bash
# Measure generation time
time dart run bin/fpd_toolkit.dart create package perf_test
```

### Memory Profiling
```bash
dart run --observe bin/fpd_toolkit.dart create package perf_test
```

### Validation Scoring
```bash
dart run bin/fpd_toolkit.dart validate generated_package
```

## 🔄 CI/CD Integration

### GitHub Actions
```yaml
name: Validate Package
on: [push, pull_request]
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: dart-lang/setup-dart@v1
      - run: dart pub global activate fpd_toolkit
      - run: fpd-toolkit validate .
```

### Cross-Platform Testing
```bash
dart run bin/fpd_toolkit.dart create package cross_platform_test
cd cross_platform_test
flutter test
dart test
```

## 🤝 Contributing

### Development Setup
```bash
git clone https://github.com/flutterpilot/fpd_toolkit.git
cd fpd_toolkit
dart pub get
```

### Run Integration Tests
```bash
dart run "$OLDPWD/bin/fpd_toolkit.dart" create package integration_package
dart run "$OLDPWD/bin/fpd_toolkit.dart" create app integration_app
dart run "$OLDPWD/bin/fpd_toolkit.dart" create plugin integration_plugin --platforms android,ios
dart run "$OLDPWD/bin/fpd_toolkit.dart" validate integration_package
```

### Verify Generation
```bash
# Create test package
dart run bin/fpd_toolkit.dart create package test_package --description "Test package"

# Validate structure
dart run bin/fpd_toolkit.dart validate test_package

# Verify generated files
ls -la test_package/
cat test_package/pubspec.yaml
cat test_package/README.md
```

### Template Testing
```bash
# Test different types
dart run bin/fpd_toolkit.dart create app test_app --description "Test app"
dart run bin/fpd_toolkit.dart create plugin test_plugin --platforms android,ios --description "Test plugin"
dart run bin/fpd_toolkit.dart create package test_package --description "Test package"

# Validate all
dart run bin/fpd_toolkit.dart validate test_app
dart run bin/fpd_toolkit.dart validate test_plugin
dart run bin/fpd_toolkit.dart validate test_package
```

### Performance Testing
```bash
# Measure generation time
time dart run bin/fpd_toolkit.dart create package perf_test
time dart run bin/fpd_toolkit.dart create app perf_app
time dart run bin/fpd_toolkit.dart create plugin perf_plugin --platforms android,ios

# Memory profiling
dart run --observe bin/fpd_toolkit.dart create package memory_test
```

### Cross-Platform Validation
```bash
# Create cross-platform package
dart run bin/fpd_toolkit.dart create plugin cross_platform_plugin \
  --platforms android,ios,web,windows,linux,macos \
  --description "Cross-platform plugin"

# Validate structure
dart run bin/fpd_toolkit.dart validate cross_platform_plugin

# Verify platform files
ls -la cross_platform_plugin/android/
ls -la cross_platform_plugin/ios/
ls -la cross_platform_plugin/lib/src/
```

### Documentation Testing
```bash
# Verify README generation
dart run bin/fpd_toolkit.dart create package doc_test --description "Documentation test"
cat doc_test/README.md

# Verify CHANGELOG generation
cat doc_test/CHANGELOG.md

# Verify LICENSE generation
cat doc_test/LICENSE
```

### Error Handling Testing
```bash
# Test invalid names
dart run bin/fpd_toolkit.dart create package invalid-name
dart run bin/fpd_toolkit.dart create package 123package
dart run bin/fpd_toolkit.dart create package package@test

# Test existing directories
mkdir existing_dir
dart run bin/fpd_toolkit.dart create package existing_dir
dart run bin/fpd_toolkit.dart create package existing_dir --force
```

### Template Customization Testing
```bash
# Create custom template
mkdir -p ~/custom_templates/package_template
cp -r test_package/* ~/custom_templates/package_template/

# Use custom template
dart run bin/fpd_toolkit.dart create package custom_test --template ~/custom_templates/package_template
```

## 📈 Roadmap

### Upcoming Features
- [ ] **Advanced Templates** - Templates with complex configuration
- [ ] **Automatic Validation** - Automatic CI/CD integration
- [ ] **Plugin Marketplace** - Community template repository
- [ ] **IDE Integration** - VS Code, Android Studio extensions
- [ ] **Performance Profiling** - Automatic performance analysis
- [ ] **Security Scanning** - Automatic vulnerability detection

### Planned Improvements
- [ ] **Multi-language Support** - Support for multiple languages
- [ ] **Custom Validators** - Customizable validators
- [ ] **Template Inheritance** - Template inheritance system
- [ ] **Plugin Architecture** - Extensible plugin system
- [ ] **Cloud Integration** - Cloud-based templates
- [ ] **Collaboration Features** - Collaborative template work

## 🐛 Troubleshooting

### Common Issues

#### Error: "Command not found"
```bash
# Verify installation
dart pub global list | grep fpd_toolkit

# Reinstall
dart pub global deactivate fpd_toolkit
dart pub global activate fpd_toolkit
```

#### Error: "Permission denied"
```bash
# Check permissions
ls -la ~/.pub-cache/bin/

# Fix permissions
chmod +x ~/.pub-cache/bin/fpd-toolkit
```

#### Error: "Template not found"
```bash
# Check available templates
fpd-toolkit template list

# Use default template
fpd-toolkit create package my_package --template default
```

#### Error: "Invalid package name"
```bash
# Use snake_case
fpd-toolkit create package my_valid_package

# Avoid special characters
# ❌ my-package, my_package@test, 123package
# ✅ my_package, my_valid_package, package_test
```

## 📞 Support

### Help Resources
- **Documentation**: [docs/](docs/)
- **Issues**: [GitHub Issues](https://github.com/flutterpilot/fpd_toolkit/issues)
- **Discussions**: [GitHub Discussions](https://github.com/flutterpilot/fpd_toolkit/discussions)

### Community
- **Discord**: [FlutterPilot Community](https://discord.gg/flutterpilot)
- **Twitter**: [@flutterpilot](https://twitter.com/flutterpilot)
- **Blog**: [flutterpilot.dev](https://flutterpilot.dev)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Sebastián Larrauri** - [dash@flutterpilot.dev](mailto:dash@flutterpilot.dev)

---

⭐ If FPD Toolkit has been useful to you, consider giving it a star on GitHub!

## 🚀 Quick Start

```bash
# Install
dart pub global activate fpd_toolkit

# Create your first package
fpd-toolkit create package my_package --description "My first package"

# Validate
fpd-toolkit validate my_package

# Ready to publish!
cd my_package
dart pub publish --dry-run
```

Start creating high-quality packages today! 🎉
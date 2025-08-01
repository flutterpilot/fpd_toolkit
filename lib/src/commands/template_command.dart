import 'package:args/args.dart';
import 'base_command.dart';
import '../utils/logger.dart';
import '../utils/interactive_prompt.dart';

/// Command to manage project templates
class TemplateCommand extends Command {
  late final ArgParser _argParser;

  TemplateCommand() {
    _argParser = ArgParser()
      ..addFlag(
        'non-interactive',
        negatable: false,
        help: 'Run in non-interactive mode',
      )
      ..addFlag(
        'help',
        abbr: 'h',
        negatable: false,
        help: 'Show help for this command',
      );
  }

  @override
  String get name => 'template';

  @override
  String get description => 'Manage project templates';

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
    
    String? subcommand;
    
    if (args.isNotEmpty) {
      subcommand = args[0];
    } else if (!isNonInteractive) {
      subcommand = InteractivePrompt.promptSelect(
        question: 'What would you like to do with templates?',
        options: ['list', 'show'],
        defaultValue: 'list',
      );
    } else {
      showHelp();
      return;
    }
    
    switch (subcommand) {
      case 'list':
        _listTemplates();
        break;
      case 'show':
        String? templateName;
        if (args.length >= 2) {
          templateName = args[1];
        } else if (!isNonInteractive) {
          templateName = _promptForTemplate();
        } else {
          Logger.error('❌ Usage: fpd-toolkit template show <name>');
          return;
        }
        
        if (templateName != null) {
          _showTemplate(templateName);
        }
        break;
      default:
        Logger.error('❌ Unknown subcommand: $subcommand');
        showHelp();
    }
  }

  String? _promptForTemplate() {
    final allTemplates = [
      'clean', 'mvvm', 'simple', 'ecommerce', 'social', 'productivity', 'finance',
      'platform', 'federated', 'ffi', 'utils', 'ui', 'data'
    ];
    
    return InteractivePrompt.promptSelect(
      question: 'Which template would you like to see details for?',
      options: allTemplates,
      defaultValue: 'clean',
    );
  }

  void _listTemplates() {
    Logger.info('📋 Available templates:\n');
    
    Logger.info('🏗️ Architectures:');
    Logger.info('  clean           - Clean Architecture with BLoC');
    Logger.info('  mvvm            - MVVM with Provider');
    Logger.info('  simple          - Simple architecture for small apps');
    
    Logger.info('\n📱 Application types:');
    Logger.info('  ecommerce       - Complete e-commerce app');
    Logger.info('  social          - Social media app');
    Logger.info('  productivity    - Productivity app');
    Logger.info('  finance         - Financial app');
    
    Logger.info('\n🔌 Plugins:');
    Logger.info('  platform        - Multi-platform plugin');
    Logger.info('  federated       - Federated plugin');
    Logger.info('  ffi             - Plugin with FFI');
    
    Logger.info('\n📦 Packages:');
    Logger.info('  utils           - Utilities package');
    Logger.info('  ui              - UI components package');
    Logger.info('  data            - Data models package');

    Logger.info('\nUsage:');
    Logger.info('  fpd-toolkit template show <name>');
    Logger.info('  fpd-toolkit create <type> <name> --template <template>');
  }

  void _showTemplate(String templateName) {
    Logger.info('📄 Template: $templateName\n');

    switch (templateName) {
      case 'clean':
        _showCleanArchitectureTemplate();
        break;
      case 'mvvm':
        _showMVVMTemplate();
        break;
      case 'simple':
        _showSimpleTemplate();
        break;
      case 'ecommerce':
        _showEcommerceTemplate();
        break;
      case 'social':
        _showSocialTemplate();
        break;
      case 'platform':
        _showPlatformPluginTemplate();
        break;
      case 'federated':
        _showFederatedPluginTemplate();
        break;
      case 'utils':
        _showUtilsPackageTemplate();
        break;
      default:
        Logger.error('❌ Template not found: $templateName');
        Logger.info('Use "fpd-toolkit template list" to see available templates');
    }
  }

  void _showCleanArchitectureTemplate() {
    print('''
🏗️ CLEAN ARCHITECTURE TEMPLATE

Estructura de directorios:
```
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── usecases/
│   └── utils/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/
│   ├── blocs/
│   ├── pages/
│   └── widgets/
└── injection_container.dart
```

Dependencias incluidas:
- flutter_bloc: ^8.1.3
- get_it: ^7.6.4
- dartz: ^0.10.1
- equatable: ^2.0.5

Características:
✅ Separación clara de responsabilidades
✅ Inversión de dependencias
✅ Testabilidad máxima
✅ Escalabilidad para equipos grandes

Ideal para:
- Aplicaciones complejas
- Equipos grandes
- Proyectos a largo plazo
- Apps empresariales
''');
  }

  void _showMVVMTemplate() {
    print('''
🎯 MVVM TEMPLATE

Estructura de directorios:
```
lib/
├── models/
├── views/
│   ├── pages/
│   └── widgets/
├── viewmodels/
├── services/
├── utils/
└── main.dart
```

Dependencias incluidas:
- provider: ^6.1.1
- stacked: ^3.4.1
- stacked_services: ^1.2.0

Características:
✅ Arquitectura intermedia
✅ Fácil de entender
✅ Buen balance complejidad/beneficios
✅ Excelente para equipos medianos

Ideal para:
- Apps de tamaño mediano
- Equipos de 2-5 desarrolladores
- Desarrollo rápido
- Prototipado avanzado
''');
  }

  void _showSimpleTemplate() {
    print('''
🚀 SIMPLE TEMPLATE

Estructura de directorios:
```
lib/
├── screens/
├── widgets/
├── models/
├── services/
├── utils/
└── main.dart
```

Dependencias incluidas:
- provider: ^6.1.1
- http: ^1.1.0

Características:
✅ Minimalista y directo
✅ Fácil de entender
✅ Desarrollo rápido
✅ ✅ Ideal para principiantes

Ideal para:
- Apps pequeñas
- Prototipos
- Developers junior
- MVPs rápidos
''');
  }

  void _showEcommerceTemplate() {
    print('''
🛒 ECOMMERCE TEMPLATE

Funcionalidades incluidas:
- Catálogo de productos
- Carrito de compras
- Autenticación de usuarios
- Procesamiento de pagos
- Gestión de pedidos
- Sistema de reviews

Estructura:
```
lib/
├── features/
│   ├── auth/
│   ├── catalog/
│   ├── cart/
│   ├── orders/
│   └── profile/
├── shared/
│   ├── widgets/
│   ├── models/
│   └── services/
└── core/
```

Dependencias incluidas:
- flutter_bloc: ^8.1.3
- cached_network_image: ^3.3.0
- shared_preferences: ^2.2.2
- stripe_payment: ^1.1.4

Páginas generadas:
✅ Splash Screen
✅ Login/Register
✅ Product Catalog
✅ Product Details
✅ Shopping Cart
✅ Checkout
✅ Order History
✅ User Profile
''');
  }

  void _showSocialTemplate() {
    print('''
👥 SOCIAL TEMPLATE

Funcionalidades incluidas:
- Feed de posts
- Sistema de likes/comentarios
- Mensajería privada
- Perfiles de usuario
- Seguir/no seguir usuarios
- Notificaciones push

Estructura:
```
lib/
├── features/
│   ├── auth/
│   ├── feed/
│   ├── profile/
│   ├── chat/
│   └── notifications/
├── shared/
└── core/
```

Dependencias incluidas:
- flutter_bloc: ^8.1.3
- firebase_core: ^2.24.2
- firebase_auth: ^4.15.3
- cloud_firestore: ^4.13.6
- firebase_messaging: ^14.7.10

Características especiales:
✅ Real-time updates
✅ Image uploading
✅ Push notifications
✅ Offline support
✅ Social interactions
''');
  }

  void _showPlatformPluginTemplate() {
    print('''
🔌 PLATFORM PLUGIN TEMPLATE

Plataformas soportadas:
- Android (Kotlin)
- iOS (Swift)
- Web (Dart)
- Windows (C++)
- Linux (C++)
- macOS (Swift)

Estructura:
```
my_plugin/
├── lib/
│   ├── my_plugin.dart
│   └── src/
├── android/
├── ios/
├── web/
├── windows/
├── linux/
├── macos/
├── example/
└── test/
```

Características:
✅ Method channels configurados
✅ Platform interfaces
✅ Ejemplo funcional
✅ Tests unitarios
✅ Documentación completa

Archivos generados:
- Platform interface
- Method channel implementation
- Native code para cada plataforma
- Tests unitarios
- Ejemplo de uso
''');
  }

  void _showFederatedPluginTemplate() {
    print('''
🌐 FEDERATED PLUGIN TEMPLATE

Estructura federada:
```
my_plugin/
├── my_plugin/              # Plugin principal
├── my_plugin_platform_interface/  # Interface común
├── my_plugin_android/       # Implementación Android
├── my_plugin_ios/          # Implementación iOS
├── my_plugin_web/          # Implementación Web
└── example/                # Ejemplo de uso
```

Ventajas:
✅ Separación por plataforma
✅ Mantenimiento independiente
✅ Equipos especializados
✅ Actualizaciones granulares

Ideal para:
- Plugins complejos
- Equipos especializados por plataforma
- Funcionalidades platform-specific
- Proyectos grandes
''');
  }

  void _showUtilsPackageTemplate() {
    print('''
🛠️ UTILS PACKAGE TEMPLATE

Categorías de utilidades:
- Validadores de entrada
- Formatters de datos
- Helpers de fecha/hora
- Extensiones de tipos
- Constantes comunes

Estructura:
```
lib/
├── src/
│   ├── validators/
│   ├── formatters/
│   ├── extensions/
│   ├── helpers/
│   └── constants/
├── utils.dart
└── all.dart
```

Utilidades incluidas:
✅ Email/Phone validators
✅ Date/Time formatters
✅ String extensions
✅ Number helpers
✅ Color utilities
✅ Platform helpers

Características:
✅ Tree-shaking friendly
✅ Well documented
✅ Comprehensive tests
✅ Zero dependencies
''');
  }

  @override
  void showHelp() {
    print('''
$description

Usage: fpd-toolkit template [subcommand] [arguments]

Subcommands (optional in interactive mode):
  list                 List all available templates
  show <name>          Show details of a specific template

Interactive Examples:
  fpd-toolkit template                    # Interactive mode - asks what to do
  fpd-toolkit template show               # Interactive mode - asks which template
  fpd-toolkit template list               # Lists all templates

Non-Interactive Examples:
  fpd-toolkit template list --non-interactive
  fpd-toolkit template show clean --non-interactive
  fpd-toolkit template show ecommerce --non-interactive

To use a template:
  fpd-toolkit create app my_app --template clean
  fpd-toolkit create plugin my_plugin --template platform

Available templates:
  📱 Apps: clean, mvvm, simple, ecommerce, social, productivity, finance
  🔌 Plugins: platform, federated, ffi
  📦 Packages: utils, ui, data
''');
  }
}
import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as path;
import 'base_command.dart';
import '../utils/logger.dart';

/// Comando para mostrar guías de desarrollo
class GuideCommand extends Command {
  late final ArgParser _argParser;

  static const Map<String, String> _guides = {
    'architecture': 'Arquitectura y estructura de proyectos',
    'state': 'Gestión de estado (BLoC, Provider, Riverpod)',
    'testing': 'Testing estratégico y mejores prácticas',
    'performance': 'Optimización de performance',
    'security': 'Seguridad y privacidad',
    'ui': 'UI/UX y Material Design',
    'platform': 'Desarrollo multiplataforma',
    'publishing': 'Publicación en pub.dev',
    'maintenance': 'Mantenimiento y versionado',
  };

  GuideCommand() {
    _argParser = ArgParser()
      ..addFlag(
        'list',
        abbr: 'l',
        negatable: false,
        help: 'Lista todas las guías disponibles',
      )
      ..addFlag(
        'all',
        negatable: false,
        help: 'Muestra todas las guías',
      )
      ..addFlag(
        'copy',
        abbr: 'c',
        negatable: false,
        help: 'Copia las guías al directorio actual',
      )
      ..addOption(
        'output',
        abbr: 'o',
        help: 'Directorio donde copiar las guías',
        defaultsTo: './doc',
      )
      ..addFlag(
        'help',
        abbr: 'h',
        negatable: false,
        help: 'Muestra ayuda para este comando',
      );
  }

  @override
  String get name => 'guide';

  @override
  String get description => 'Muestra guías de desarrollo Flutter/Dart';

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
      Logger.info('\nUsa: fpd-toolkit guide <tema> para ver una guía específica');
      Logger.info('     fpd-toolkit guide --all para ver todas las guías');
      return;
    }

    final topic = args[0];
    await _showGuide(topic);
  }

  void _listGuides() {
    Logger.info('📚 Guías de desarrollo disponibles:\n');
    
    for (final entry in _guides.entries) {
      Logger.info('  ${entry.key.padRight(12)} - ${entry.value}');
    }

    Logger.info('\nEjemplos de uso:');
    Logger.info('  fpd-toolkit guide architecture');
    Logger.info('  fpd-toolkit guide testing');
    Logger.info('  fpd-toolkit guide --all');
    Logger.info('  fpd-toolkit guide --copy');
  }

  Future<void> _showGuide(String topic) async {
    if (!_guides.containsKey(topic)) {
      Logger.error('❌ Guía no encontrada: $topic');
      Logger.info('Guías disponibles: ${_guides.keys.join(', ')}');
      return;
    }

    Logger.info('📖 Mostrando guía: ${_guides[topic]}\n');

    switch (topic) {
      case 'architecture':
        _showArchitectureGuide();
        break;
      case 'state':
        _showStateManagementGuide();
        break;
      case 'testing':
        _showTestingGuide();
        break;
      case 'performance':
        _showPerformanceGuide();
        break;
      case 'security':
        _showSecurityGuide();
        break;
      case 'ui':
        _showUIGuide();
        break;
      case 'platform':
        _showPlatformGuide();
        break;
      case 'publishing':
        _showPublishingGuide();
        break;
      case 'maintenance':
        _showMaintenanceGuide();
        break;
    }

    Logger.info('\n📋 Para más información:');
    Logger.info('   fpd-toolkit guide --copy  # Copia todas las guías');
    Logger.info('   fpd-toolkit guide --all   # Ver todas las guías');
  }

  Future<void> _showAllGuides() async {
    Logger.info('📚 Guías completas de desarrollo Flutter/Dart\n');
    
    for (final topic in _guides.keys) {
      Logger.info('=' * 60);
      await _showGuide(topic);
      Logger.info('');
    }
  }

  Future<void> _copyGuides(String outputDir) async {
    try {
      final docsDir = Directory(outputDir);
      await docsDir.create(recursive: true);

      // Buscar las guías en el directorio padre del CLI
      final cliDir = Directory(Platform.script.path).parent.parent.parent;
      final guidesSource = [
        path.join(cliDir.path, 'GUIA_DESARROLLO_FLUTTER_DART.md'),
        path.join(cliDir.path, 'MEJORES_PRACTICAS_FLUTTER.md'),
      ];

      for (final sourcePath in guidesSource) {
        final sourceFile = File(sourcePath);
        if (sourceFile.existsSync()) {
          final fileName = path.basename(sourcePath);
          final targetPath = path.join(outputDir, fileName);
          await sourceFile.copy(targetPath);
          Logger.success('✅ Copiado: $fileName');
        }
      }

      // Crear guía de inicio rápido
      await _createQuickStartGuide(outputDir);

      Logger.success('📚 Guías copiadas exitosamente a: $outputDir');
      Logger.info('\n📋 Archivos creados:');
      Logger.info('   $outputDir/GUIA_DESARROLLO_FLUTTER_DART.md');
      Logger.info('   $outputDir/MEJORES_PRACTICAS_FLUTTER.md');
      Logger.info('   $outputDir/QUICK_START.md');

    } catch (e) {
      Logger.error('❌ Error copiando guías: $e');
    }
  }

  Future<void> _createQuickStartGuide(String outputDir) async {
    final quickStartContent = '''
# 🚀 Guía de Inicio Rápido - Flutter Pilot Kit

## Instalación

### Activación Global
```bash
dart pub global activate fpd_toolkit
```

### Uso Directo
```bash
dart pub global run fpd_toolkit
```

## Crear tu primer proyecto

\`\`\`bash
# Aplicación Flutter
fpd-toolkit create app mi_app --description "Mi aplicación increíble"

# Plugin Flutter
fpd-toolkit create plugin mi_plugin --platforms android,ios,web

# Paquete Dart
fpd-toolkit create package mi_paquete --author "Tu Nombre"
\`\`\`

## Validar calidad

\`\`\`bash
# Validar paquete
fpd-toolkit validate ./mi_proyecto

# Ver guías de desarrollo
fpd-toolkit guide --list
fpd-toolkit guide architecture
\`\`\`

## Ejemplos útiles

\`\`\`bash
# Ver templates disponibles
fpd-toolkit template list

# Generar ejemplos de código
fpd-toolkit example widget

# Inicializar proyecto existente
fpd-toolkit init
\`\`\`

## Próximos pasos

1. Lee la guía completa: `GUIA_DESARROLLO_FLUTTER_DART.md`
2. Revisa las mejores prácticas: `MEJORES_PRACTICAS_FLUTTER.md`
3. Explora los comandos: `fpd-toolkit --help`

¡Feliz desarrollo! 🎉
''';

    final quickStartFile = File(path.join(outputDir, 'QUICK_START.md'));
    await quickStartFile.writeAsString(quickStartContent);
  }

  void _showArchitectureGuide() {
    print('''
🏗️ ARQUITECTURA Y ESTRUCTURA DE PROYECTOS

## Clean Architecture Pattern

\`\`\`
lib/
├── core/           # Funcionalidades compartidas
├── data/           # Capa de datos
├── domain/         # Lógica de negocio
├── presentation/   # UI y estado
└── services/       # Servicios externos
\`\`\`

## Separación de Responsabilidades

- **Domain**: Entidades, casos de uso, interfaces
- **Data**: Modelos, repositorios, fuentes de datos
- **Presentation**: Páginas, widgets, estado UI
- **Core**: Utilidades, constantes, extensiones

## Ejemplo de Estructura

\`\`\`dart
// domain/entities/user.dart
class User extends Equatable {
  const User({required this.id, required this.name});
  final String id;
  final String name;
  @override
  List<Object> get props => [id, name];
}

// data/models/user_model.dart
class UserModel extends User {
  const UserModel({required super.id, required super.name});
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}
\`\`\`
''');
  }

  void _showStateManagementGuide() {
    print('''
🔄 GESTIÓN DE ESTADO

## Opciones Recomendadas

1. **BLoC Pattern** (Complejo)
2. **Provider** (Intermedio)  
3. **Riverpod** (Moderno)

## BLoC Example

\`\`\`dart
// Events
abstract class UserEvent extends Equatable {}
class GetUserEvent extends UserEvent {
  const GetUserEvent(this.userId);
  final String userId;
}

// States  
abstract class UserState extends Equatable {}
class UserLoading extends UserState {}
class UserLoaded extends UserState {
  const UserLoaded(this.user);
  final User user;
}

// BLoC
class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserInitial()) {
    on<GetUserEvent>(_onGetUser);
  }
  
  Future<void> _onGetUser(GetUserEvent event, Emitter emit) async {
    emit(UserLoading());
    final user = await userRepository.getUser(event.userId);
    emit(UserLoaded(user));
  }
}
\`\`\`

## Cuándo usar cada uno

- **BLoC**: Apps complejas, equipos grandes
- **Provider**: Apps medianas, equipos pequeños
- **Riverpod**: Proyectos nuevos, mejor DX
''');
  }

  void _showTestingGuide() {
    print('''
🧪 TESTING ESTRATÉGICO

## Pirámide de Testing

\`\`\`
     /\\
    /  \\     E2E Tests (10%)
   /____\\    Widget Tests (20%)
  /      \\   Unit Tests (70%)
 /__________\\
\`\`\`

## Unit Tests

\`\`\`dart
void main() {
  group('UserService', () {
    late UserService userService;
    late MockRepository mockRepo;

    setUp(() {
      mockRepo = MockRepository();
      userService = UserService(mockRepo);
    });

    test('should return user when call is successful', () async {
      // arrange
      when(() => mockRepo.getUser('1'))
          .thenAnswer((_) async => testUser);

      // act
      final result = await userService.getUser('1');

      // assert
      expect(result, equals(testUser));
      verify(() => mockRepo.getUser('1')).called(1);
    });
  });
}
\`\`\`

## Widget Tests

\`\`\`dart
testWidgets('should display user name', (tester) async {
  await tester.pumpWidget(
    MaterialApp(home: UserCard(user: testUser)),
  );

  expect(find.text('John Doe'), findsOneWidget);
  expect(find.byType(CircleAvatar), findsOneWidget);
});
\`\`\`

## Coverage Goals

- **Objetivo**: >80% coverage
- **Crítico**: >90% para lógica de negocio
- **UI**: Golden tests para consistency
''');
  }

  void _showPerformanceGuide() {
    print('''
⚡ OPTIMIZACIÓN DE PERFORMANCE

## Widgets Optimization

\`\`\`dart
// ✅ Correcto - Const constructors
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Card(  // const
      child: Padding(
        padding: EdgeInsets.all(16), // const
        child: Text('Hello World'),
      ),
    );
  }
}

// ❌ Incorrecto - No const
Widget build(BuildContext context) {
  return Card(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Text('Hello World'),
    ),
  );
}
\`\`\`

## Lista Performance

\`\`\`dart
// ✅ Para listas grandes
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ItemWidget(items[index]);
  },
)

// ❌ Para listas grandes
ListView(
  children: items.map((item) => ItemWidget(item)).toList(),
)
\`\`\`

## Memory Management

- Use `dispose()` para controllers
- Cancela subscriptions en `dispose()`
- Optimiza imágenes con `cacheWidth/Height`
- Evita crear objetos en `build()`

## Herramientas

\`\`\`bash
# Performance profiling
flutter run --profile
flutter drive --profile test_driver/app.dart

# Memory usage
flutter run --enable-dart-vm-service
\`\`\`
''');
  }

  void _showSecurityGuide() {
    print('''
🔐 SEGURIDAD Y PRIVACIDAD

## Almacenamiento Seguro

\`\`\`dart
// Datos sensibles
const storage = FlutterSecureStorage();
await storage.write(key: 'token', value: authToken);
final token = await storage.read(key: 'token');

// Datos normales
final prefs = await SharedPreferences.getInstance();
await prefs.setString('theme', 'dark');
\`\`\`

## Validación de Entrada

\`\`\`dart
String? validateEmail(String? email) {
  if (email == null || email.isEmpty) {
    return 'Email requerido';
  }
  final regex = RegExp(r'^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}\$');
  if (!regex.hasMatch(email)) {
    return 'Email inválido';
  }
  return null;
}
\`\`\`

## Network Security

\`\`\`dart
// Certificate pinning
(_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
  final client = HttpClient();
  client.badCertificateCallback = (cert, host, port) {
    return _verifyCertificate(cert, host);
  };
  return client;
};
\`\`\`

## Best Practices

- Nunca hardcodear secrets
- Usar HTTPS siempre
- Validar todas las entradas
- Implementar certificate pinning
- Limpiar logs en producción
''');
  }

  void _showUIGuide() {
    print('''
🎨 UI/UX Y MATERIAL DESIGN

## Material 3 Design System

\`\`\`dart
ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.deepPurple,
  ),
)
\`\`\`

## Responsive Design

\`\`\`dart
class ResponsiveWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return MobileLayout();
        } else if (constraints.maxWidth < 1200) {
          return TabletLayout();
        } else {
          return DesktopLayout();
        }
      },
    );
  }
}
\`\`\`

## Animaciones Suaves

\`\`\`dart
class AnimatedCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
\`\`\`

## Accessibility

\`\`\`dart
Semantics(
  label: 'Usuario: John Doe',
  hint: 'Toca para ver detalles',
  child: UserCard(user: user),
)
\`\`\`
''');
  }

  void _showPlatformGuide() {
    print('''
🌐 DESARROLLO MULTIPLATAFORMA

## Platform Detection

\`\`\`dart
import 'dart:io' show Platform;

class PlatformUtils {
  static bool get isAndroid => Platform.isAndroid;
  static bool get isIOS => Platform.isIOS;
  static bool get isWeb => kIsWeb;
  
  static bool get isMobile => isAndroid || isIOS;
  static bool get isDesktop => 
      Platform.isWindows || Platform.isLinux || Platform.isMacOS;
}
\`\`\`

## Adaptive Widgets

\`\`\`dart
class PlatformButton extends StatelessWidget {
  const PlatformButton({required this.onPressed, required this.child});
  
  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoButton(onPressed: onPressed, child: child);
    }
    return ElevatedButton(onPressed: onPressed, child: child);
  }
}
\`\`\`

## Platform-Specific Code

\`\`\`dart
// lib/src/platform_interface.dart
abstract class PlatformInterface {
  Future<String> getPlatformVersion();
}

// lib/src/platform_android.dart
class AndroidPlatform extends PlatformInterface {
  @override
  Future<String> getPlatformVersion() async {
    return 'Android \${Platform.operatingSystemVersion}';
  }
}

// lib/src/platform_ios.dart  
class IOSPlatform extends PlatformInterface {
  @override
  Future<String> getPlatformVersion() async {
    return 'iOS \${Platform.operatingSystemVersion}';
  }
}
\`\`\`

## Navigation 2.0

\`\`\`dart
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
      routes: [
        GoRoute(
          path: '/details/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return DetailsPage(id: id);
          },
        ),
      ],
    ),
  ],
);
\`\`\`
''');
  }

  void _showPublishingGuide() {
    print('''
📦 PUBLICACIÓN EN PUB.DEV

## Preparación

\`\`\`yaml
# pubspec.yaml
name: mi_paquete
description: Descripción clara y concisa
version: 1.0.0
homepage: https://github.com/usuario/mi_paquete
repository: https://github.com/usuario/mi_paquete
issue_tracker: https://github.com/usuario/mi_paquete/issues

environment:
  sdk: ^3.7.0-0
\`\`\`

## Archivos Requeridos

- `README.md` - Con ejemplos claros
- `CHANGELOG.md` - Historial de versiones
- `LICENSE` - Licencia OSI
- `pubspec.yaml` - Metadatos completos

## Validación Pre-publicación

\`\`\`bash
# Análisis con pana (objetivo: 130+ puntos)
dart pub global activate pana
pana .

# Formato y análisis
dart format --set-exit-if-changed .
dart analyze

# Tests
flutter test --coverage

# Dry run
dart pub publish --dry-run
\`\`\`

## Criterios de Calidad

- ✅ Sin errores de análisis
- ✅ >20% APIs documentadas  
- ✅ Ejemplos funcionales
- ✅ Tests unitarios
- ✅ Soporte multiplataforma
- ✅ Dependencias actualizadas

## Publicación

\`\`\`bash
# Publicar
dart pub publish

# Verificar
open https://pub.dev/packages/mi_paquete
\`\`\`
''');
  }

  void _showMaintenanceGuide() {
    print('''
🔄 MANTENIMIENTO Y VERSIONADO

## Semantic Versioning

- **MAJOR** (1.0.0): Breaking changes
- **MINOR** (0.1.0): New features (backward compatible)
- **PATCH** (0.0.1): Bug fixes

## CHANGELOG.md Format

\`\`\`markdown
# Changelog

## [1.2.0] - 2024-01-15

### Added
- Nueva funcionalidad X
- Soporte para Y

### Changed  
- Mejorado rendimiento de Z

### Fixed
- Corregido bug en A
- Solucionado problema B

### Security
- Actualización de dependencia vulnerable
\`\`\`

## Continuous Integration

\`\`\`yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - uses: subosito/flutter-action@v2
    - run: flutter pub get
    - run: flutter analyze
    - run: flutter test --coverage
\`\`\`

## Dependency Management

\`\`\`bash
# Actualizar dependencias
flutter pub upgrade

# Verificar dependencias obsoletas
flutter pub outdated

# Actualizar constraints
flutter pub deps
\`\`\`

## Release Checklist

- [ ] Tests passing
- [ ] Documentación actualizada
- [ ] CHANGELOG.md actualizado
- [ ] Version bumped
- [ ] Tag creado
- [ ] Released on pub.dev
''');
  }

  @override
  void showHelp() {
    print('''
$description

Uso: fpd-toolkit guide [tema] [opciones]

Temas disponibles:
''');
    
    for (final entry in _guides.entries) {
      print('  ${entry.key.padRight(12)} - ${entry.value}');
    }

    print('''

Opciones:
  -l, --list           Lista todas las guías disponibles
      --all            Muestra todas las guías
  -c, --copy           Copia las guías al directorio actual
  -o, --output         Directorio donde copiar las guías (default: ./doc)
  -h, --help           Muestra esta ayuda

Ejemplos:
  fpd-toolkit guide architecture
  fpd-toolkit guide testing
  fpd-toolkit guide --list
  fpd-toolkit guide --all
  fpd-toolkit guide --copy --output ./documentation
''');
  }
}
# 🚀 Guía Completa de Desarrollo Flutter/Dart - Aplicaciones de Alta Calidad

Esta guía te ayudará a crear aplicaciones Flutter y paquetes Dart que cumplan con las mejores prácticas y estén listos para publicación en pub.dev.

## 📋 Tabla de Contenidos

1. [Fundamentos](#fundamentos)
2. [Configuración del Entorno](#configuración-del-entorno)
3. [Estructura de Proyectos](#estructura-de-proyectos)
4. [Mejores Prácticas](#mejores-prácticas)
5. [Publicación en pub.dev](#publicación-en-pubdev)
6. [Testing y Quality Assurance](#testing-y-quality-assurance)
7. [Mantenimiento y Versionado](#mantenimiento-y-versionado)
8. [Herramientas y Scripts](#herramientas-y-scripts)

---

## 🎯 Fundamentos

### Principios de Diseño

1. **Simplicidad**: El código debe ser claro y fácil de entender
2. **Reutilización**: Crear componentes reutilizables
3. **Performance**: Optimizar para rendimiento desde el inicio
4. **Mantenibilidad**: Escribir código que sea fácil de mantener
5. **Testabilidad**: Diseñar con testing en mente

### Convenciones de Nomenclatura

#### Paquetes y Archivos
```dart
// ✅ Correcto - snake_case
my_awesome_package
user_profile_widget.dart
authentication_service.dart

// ❌ Incorrecto
MyAwesomePackage
userProfileWidget.dart
AuthenticationService.dart
```

#### Clases y Tipos
```dart
// ✅ Correcto - PascalCase
class UserProfileWidget extends StatelessWidget {}
abstract class DatabaseService {}
enum ConnectionStatus { connected, disconnected }

// ❌ Incorrecto
class userProfileWidget {}
class database_service {}
```

#### Variables y Métodos
```dart
// ✅ Correcto - camelCase
String userName = 'John';
void fetchUserData() {}
final int maxRetries = 3;

// ❌ Incorrecto
String user_name = 'John';
void FetchUserData() {}
final int MAX_RETRIES = 3;
```

#### Constantes
```dart
// ✅ Correcto - lowerCamelCase para constantes locales
const int defaultTimeout = 30;
const String apiBaseUrl = 'https://api.example.com';

// ✅ Correcto - SCREAMING_SNAKE_CASE para constantes globales
static const int MAX_RETRY_ATTEMPTS = 3;
static const String DEFAULT_USER_AGENT = 'MyApp/1.0';
```

---

## 🛠️ Configuración del Entorno

### SDK y Herramientas Requeridas

```bash
# Verificar instalación
flutter doctor -v
dart --version

# Herramientas globales recomendadas
dart pub global activate pana          # Análisis de paquetes
dart pub global activate dart_code_metrics  # Métricas de código
dart pub global activate very_good_cli       # CLI para proyectos
```

### Configuración del Editor

#### VS Code Extensions
- Dart
- Flutter
- Bracket Pair Colorizer
- GitLens
- Error Lens
- Flutter Tree
- Pubspec Assist

#### Configuración VS Code (`settings.json`)
```json
{
  "dart.previewFlutterUiGuides": true,
  "dart.previewFlutterUiGuidesCustomTracking": true,
  "dart.closingLabels": true,
  "dart.showMainCodeLens": false,
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true,
    "source.organizeImports": true
  },
  "dart.lineLength": 80
}
```

---

## 📁 Estructura de Proyectos

### Aplicación Flutter Estándar

```
my_flutter_app/
├── 📄 pubspec.yaml
├── 📄 README.md
├── 📄 CHANGELOG.md
├── 📄 LICENSE
├── 📄 analysis_options.yaml
├── 📄 .gitignore
├── 📁 lib/
│   ├── 📄 main.dart
│   ├── 📁 core/
│   │   ├── 📁 constants/
│   │   ├── 📁 exceptions/
│   │   ├── 📁 extensions/
│   │   └── 📁 utils/
│   ├── 📁 data/
│   │   ├── 📁 datasources/
│   │   ├── 📁 models/
│   │   └── 📁 repositories/
│   ├── 📁 domain/
│   │   ├── 📁 entities/
│   │   ├── 📁 repositories/
│   │   └── 📁 usecases/
│   ├── 📁 presentation/
│   │   ├── 📁 pages/
│   │   ├── 📁 widgets/
│   │   └── 📁 providers/
│   └── 📁 services/
├── 📁 test/
│   ├── 📁 unit/
│   ├── 📁 widget/
│   └── 📁 integration/
├── 📁 assets/
│   ├── 📁 images/
│   ├── 📁 icons/
│   └── 📁 fonts/
└── 📁 docs/
    ├── 📄 api.md
    └── 📄 architecture.md
```

### Plugin Flutter

```
my_flutter_plugin/
├── 📄 pubspec.yaml
├── 📄 README.md
├── 📄 CHANGELOG.md
├── 📄 LICENSE
├── 📄 analysis_options.yaml
├── 📁 lib/
│   ├── 📄 my_plugin.dart
│   └── 📁 src/
│       ├── 📄 my_plugin_platform_interface.dart
│       ├── 📄 my_plugin_method_channel.dart
│       └── 📄 my_plugin_web.dart
├── 📁 android/
│   └── 📁 src/main/java/
├── 📁 ios/
│   └── 📁 Classes/
├── 📁 web/
├── 📁 example/
│   ├── 📄 pubspec.yaml
│   └── 📁 lib/
├── 📁 test/
└── 📁 pigeons/
    └── 📄 messages.dart
```

### Paquete Dart

```
my_dart_package/
├── 📄 pubspec.yaml
├── 📄 README.md
├── 📄 CHANGELOG.md
├── 📄 LICENSE
├── 📄 analysis_options.yaml
├── 📁 lib/
│   ├── 📄 my_package.dart
│   └── 📁 src/
│       ├── 📄 models/
│       ├── 📄 services/
│       └── 📄 utils/
├── 📁 test/
├── 📁 example/
└── 📁 tool/
```

---

## ✨ Mejores Prácticas

### 1. Configuración de pubspec.yaml

#### Template Básico
```yaml
name: my_awesome_app
description: Una aplicación Flutter increíble que sigue las mejores prácticas
publish_to: none
version: 1.0.0+1

environment:
  sdk: ^3.7.0-0
  flutter: ">=3.24.0"

dependencies:
  flutter:
    sdk: flutter
  
  # UI Components
  cupertino_icons: ^1.0.3
  
  # State Management
  flutter_bloc: ^8.1.3
  provider: ^6.1.1
  
  # Navigation
  go_router: ^15.0.0
  
  # Network
  dio: ^5.4.0
  
  # Storage
  shared_preferences: ^2.2.2
  
  # Utils
  equatable: ^2.0.5

dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # Linting
  flutter_lints: ^5.0.0
  
  # Testing
  bloc_test: ^9.1.5
  mocktail: ^1.0.1
  
  # Code Generation
  build_runner: ^2.4.7
  
  # Integration Testing
  integration_test:
    sdk: flutter

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/icons/
  
  fonts:
    - family: CustomFont
      fonts:
        - asset: assets/fonts/CustomFont-Regular.ttf
        - asset: assets/fonts/CustomFont-Bold.ttf
          weight: 700
```

### 2. Configuración de analysis_options.yaml

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "**/*.gr.dart"
    - build/**
  errors:
    invalid_annotation_target: ignore
    missing_required_param: error
    missing_return: error
    todo: ignore

linter:
  rules:
    # Dart Style
    - prefer_single_quotes
    - avoid_unnecessary_containers
    - prefer_const_constructors
    - prefer_const_literals_to_create_immutables
    - prefer_const_declarations
    - prefer_final_locals
    - unnecessary_const
    - unnecessary_new
    - sort_child_properties_last
    
    # Documentation
    - public_member_api_docs
    - comment_references
    
    # Design
    - prefer_relative_imports
    - avoid_print
    - avoid_web_libraries_in_flutter
    - use_key_in_widget_constructors
    - sized_box_for_whitespace
    - use_full_hex_values_for_flutter_colors
    
    # Errors
    - avoid_returning_null_for_future
    - avoid_slow_async_io
    - cancel_subscriptions
    - close_sinks
    - literal_only_boolean_expressions
    - test_types_in_equals
    - throw_in_finally
    - unnecessary_statements
    - unrelated_type_equality_checks
    - use_rethrow_when_possible
    - valid_regexps
    
    # Performance
    - avoid_function_literals_in_foreach_calls
    - prefer_for_elements_to_map_fromIterable
    - prefer_if_elements_to_conditional_expressions
    - prefer_spread_collections
```

### 3. Estructura de Código

#### Widget Básico
```dart
import 'package:flutter/material.dart';

/// Widget que muestra el perfil del usuario
class UserProfileWidget extends StatelessWidget {
  /// Crea una nueva instancia de [UserProfileWidget]
  const UserProfileWidget({
    required this.user,
    this.onTap,
    super.key,
  });

  /// Usuario a mostrar
  final User user;

  /// Callback ejecutado al tocar el widget
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(user.avatarUrl),
        ),
        title: Text(user.name),
        subtitle: Text(user.email),
        onTap: onTap,
      ),
    );
  }
}
```

#### Modelo de Datos
```dart
import 'package:equatable/equatable.dart';

/// Representa un usuario en el sistema
class User extends Equatable {
  /// Crea una nueva instancia de [User]
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    this.isActive = true,
  });

  /// Identificador único del usuario
  final String id;

  /// Nombre completo del usuario
  final String name;

  /// Dirección de email del usuario
  final String email;

  /// URL del avatar del usuario
  final String avatarUrl;

  /// Indica si el usuario está activo
  final bool isActive;

  /// Crea una copia del usuario con campos actualizados
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Convierte el usuario a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'is_active': isActive,
    };
  }

  /// Crea un usuario desde JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [id, name, email, avatarUrl, isActive];

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, '
        'avatarUrl: $avatarUrl, isActive: $isActive)';
  }
}
```

#### Servicio con Manejo de Errores
```dart
import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';

/// Excepción personalizada para errores de API
class ApiException implements Exception {
  /// Crea una nueva instancia de [ApiException]
  const ApiException(this.message, [this.statusCode]);

  /// Mensaje de error
  final String message;

  /// Código de estado HTTP (opcional)
  final int? statusCode;

  @override
  String toString() => 'ApiException: $message';
}

/// Servicio para manejar operaciones de usuario
class UserService {
  /// Crea una nueva instancia de [UserService]
  UserService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  /// Obtiene todos los usuarios
  Future<List<User>> getUsers() async {
    try {
      final response = await _dio.get('/users');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((json) => User.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw ApiException(
          'Failed to fetch users',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ApiException(_handleDioError(e));
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  /// Obtiene un usuario por ID
  Future<User> getUserById(String id) async {
    try {
      final response = await _dio.get('/users/$id');
      
      if (response.statusCode == 200) {
        return User.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ApiException(
          'User not found',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ApiException(_handleDioError(e));
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  /// Crea un nuevo usuario
  Future<User> createUser(User user) async {
    try {
      final response = await _dio.post(
        '/users',
        data: user.toJson(),
      );
      
      if (response.statusCode == 201) {
        return User.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ApiException(
          'Failed to create user',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ApiException(_handleDioError(e));
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout';
      case DioExceptionType.sendTimeout:
        return 'Send timeout';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout';
      case DioExceptionType.badResponse:
        return 'Server error: ${e.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      case DioExceptionType.connectionError:
        return 'Connection error';
      case DioExceptionType.unknown:
        return 'Unknown error: ${e.message}';
      default:
        return 'Network error';
    }
  }
}
```

### 4. Testing

#### Test Unitario
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';

import '../lib/models/user.dart';
import '../lib/services/user_service.dart';

class MockDio extends Mock implements Dio {}

void main() {
  group('UserService', () {
    late UserService userService;
    late MockDio mockDio;

    setUp(() {
      mockDio = MockDio();
      userService = UserService(dio: mockDio);
    });

    group('getUsers', () {
      test('should return list of users when API call is successful', () async {
        // Arrange
        const mockUsers = [
          {
            'id': '1',
            'name': 'John Doe',
            'email': 'john@example.com',
            'avatar_url': 'https://example.com/avatar.jpg',
            'is_active': true,
          }
        ];

        when(() => mockDio.get('/users')).thenAnswer(
          (_) async => Response(
            data: mockUsers,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/users'),
          ),
        );

        // Act
        final result = await userService.getUsers();

        // Assert
        expect(result, isA<List<User>>());
        expect(result, hasLength(1));
        expect(result.first.id, equals('1'));
        expect(result.first.name, equals('John Doe'));
        verify(() => mockDio.get('/users')).called(1);
      });

      test('should throw ApiException when API call fails', () async {
        // Arrange
        when(() => mockDio.get('/users')).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/users'),
            type: DioExceptionType.connectionTimeout,
          ),
        );

        // Act & Assert
        expect(
          () => userService.getUsers(),
          throwsA(isA<ApiException>()),
        );
      });
    });
  });
}
```

#### Test de Widget
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/models/user.dart';
import '../lib/widgets/user_profile_widget.dart';

void main() {
  group('UserProfileWidget', () {
    const testUser = User(
      id: '1',
      name: 'John Doe',
      email: 'john@example.com',
      avatarUrl: 'https://example.com/avatar.jpg',
    );

    testWidgets('should display user information', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserProfileWidget(user: testUser),
          ),
        ),
      );

      // Assert
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('john@example.com'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (tester) async {
      // Arrange
      bool wasTapped = false;
      void handleTap() {
        wasTapped = true;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserProfileWidget(
              user: testUser,
              onTap: handleTap,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(ListTile));
      await tester.pump();

      // Assert
      expect(wasTapped, isTrue);
    });
  });
}
```

---

## 📦 Publicación en pub.dev

### Preparación para Publicación

#### 1. Completar metadatos en pubspec.yaml
```yaml
name: my_awesome_package
description: Un paquete increíble que hace cosas increíbles de manera increíble
version: 1.0.0
homepage: https://github.com/usuario/my_awesome_package
repository: https://github.com/usuario/my_awesome_package
issue_tracker: https://github.com/usuario/my_awesome_package/issues
documentation: https://pub.dev/documentation/my_awesome_package/latest/

environment:
  sdk: ^3.7.0-0
  flutter: ">=3.24.0"

# Remover publish_to: none cuando esté listo para publicar
# publish_to: none
```

#### 2. Crear documentación completa

**README.md Template:**
```markdown
# 📦 My Awesome Package

[![pub package](https://img.shields.io/pub/v/my_awesome_package.svg)](https://pub.dev/packages/my_awesome_package)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Una descripción concisa y clara de qué hace tu paquete.

## ✨ Características

- 🚀 Rápido y eficiente
- 📱 Soporte multiplataforma
- 🎨 Altamente personalizable
- 🧪 Completamente testeado

## 📥 Instalación

Agrega esto a tu `pubspec.yaml`:

```yaml
dependencies:
  my_awesome_package: ^1.0.0
```

Luego ejecuta:

```bash
flutter pub get
```

## 🚀 Uso Básico

```dart
import 'package:my_awesome_package/my_awesome_package.dart';

void main() {
  final awesome = AwesomeClass();
  awesome.doSomethingAwesome();
}
```

## 📖 Documentación

### API Reference

Consulta la [documentación completa](https://pub.dev/documentation/my_awesome_package/latest/) para detalles de la API.

### Ejemplos

Mira la carpeta [example/](example/) para ejemplos completos.

## 🤝 Contribuir

Las contribuciones son bienvenidas! Por favor:

1. Fork el proyecto
2. Crea tu rama de funcionalidad (`git checkout -b feature/amazing-feature`)
3. Commit tus cambios (`git commit -m 'Add amazing feature'`)
4. Push a la rama (`git push origin feature/amazing-feature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está licenciado bajo la Licencia MIT - mira el archivo [LICENSE](LICENSE) para detalles.

## 🙋‍♂️ Soporte

Si tienes preguntas o problemas:

- 📧 Email: tu-email@example.com
- 🐛 Issues: [GitHub Issues](https://github.com/usuario/my_awesome_package/issues)
- 💬 Discusiones: [GitHub Discussions](https://github.com/usuario/my_awesome_package/discussions)
```

#### 3. Validación Pre-publicación

```bash
# Analizar el paquete
dart pub global run pana .

# Verificar formato
dart format --set-exit-if-changed .

# Ejecutar análisis estático
dart analyze

# Ejecutar tests
flutter test

# Validar pubspec
dart pub publish --dry-run
```

#### 4. Publicar

```bash
# Publicar a pub.dev
dart pub publish
```

### Criterios de Calidad pub.dev

Para obtener la máxima puntuación en pub.dev, asegúrate de:

#### ✅ Archivos Requeridos
- [x] `pubspec.yaml` completo y válido
- [x] `README.md` descriptivo con ejemplos
- [x] `CHANGELOG.md` con historial de versiones
- [x] `LICENSE` con licencia OSI
- [x] `analysis_options.yaml` configurado

#### ✅ Documentación (20+ puntos)
- [x] Al menos 20% de APIs públicas documentadas
- [x] Ejemplos de código en README
- [x] Carpeta `example/` con proyecto funcional

#### ✅ Soporte de Plataformas (10+ puntos)
- [x] Soporte multiplataforma cuando sea aplicable
- [x] Declaración correcta de plataformas en pubspec.yaml

#### ✅ Análisis Estático (30+ puntos)
- [x] Sin errores de análisis
- [x] Uso de lints estándar
- [x] Código que sigue las convenciones de Dart

#### ✅ Dependencias Actualizadas (10+ puntos)
- [x] SDK constraints actualizados
- [x] Dependencias en versiones recientes
- [x] Sin dependencias obsoletas

---

## 🧪 Testing y Quality Assurance

### Estrategia de Testing

#### 1. Pirámide de Testing
```
    /\
   /  \      E2E Tests (Integration)
  /____\     Widget Tests
 /      \    Unit Tests
/__________\
```

#### 2. Configuración de Testing

**test/test_utils.dart:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Utilidades para testing
class TestUtils {
  /// Crea un MaterialApp para testing de widgets
  static Widget createTestApp(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  /// Pump widget con MaterialApp wrapper
  static Future<void> pumpWithMaterial(
    WidgetTester tester,
    Widget widget,
  ) async {
    await tester.pumpWidget(createTestApp(widget));
  }

  /// Espera a que se complete una animación
  static Future<void> pumpAndSettle(WidgetTester tester) async {
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
  }
}

/// Matcher personalizado para verificar tipos
Matcher isInstanceOf<T>() => TypeMatcher<T>();
```

#### 3. Tests de Integración

**integration_test/app_test.dart:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:my_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('complete user flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verificar pantalla inicial
      expect(find.text('Welcome'), findsOneWidget);

      // Navegar a lista de usuarios
      await tester.tap(find.byKey(const Key('users_button')));
      await tester.pumpAndSettle();

      // Verificar lista de usuarios
      expect(find.byType(ListView), findsOneWidget);

      // Tocar primer usuario
      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();

      // Verificar detalles del usuario
      expect(find.text('User Details'), findsOneWidget);
    });
  });
}
```

### Coverage Reports

```bash
# Instalar lcov (macOS)
brew install lcov

# Ejecutar tests con coverage
flutter test --coverage

# Generar reporte HTML
genhtml coverage/lcov.info -o coverage/html

# Abrir reporte
open coverage/html/index.html
```

### Continuous Integration

**.github/workflows/ci.yml:**
```yaml
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.24.0'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Analyze code
      run: flutter analyze
    
    - name: Check formatting
      run: dart format --set-exit-if-changed .
    
    - name: Run tests
      run: flutter test --coverage
    
    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        file: coverage/lcov.info

  build:
    runs-on: ubuntu-latest
    needs: test

    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.24.0'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Build APK
      run: flutter build apk --debug
    
    - name: Build iOS (no signing)
      run: flutter build ios --no-codesign
      if: runner.os == 'macOS'
```

---

## 🔄 Mantenimiento y Versionado

### Semantic Versioning

Sigue [Semantic Versioning](https://semver.org/):

- **MAJOR** (1.0.0): Cambios incompatibles en la API
- **MINOR** (0.1.0): Nueva funcionalidad compatible hacia atrás
- **PATCH** (0.0.1): Bug fixes compatibles hacia atrás

#### Ejemplos:
- `1.0.0` → `1.0.1`: Bug fix
- `1.0.0` → `1.1.0`: Nueva funcionalidad
- `1.0.0` → `2.0.0`: Breaking change

### CHANGELOG.md Template

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Nueva funcionalidad pendiente de release

### Changed
- Cambios en funcionalidad existente

### Deprecated
- Funcionalidad que será removida

### Removed
- Funcionalidad removida

### Fixed
- Bug fixes

### Security
- Actualizaciones de seguridad

## [1.2.0] - 2024-01-15

### Added
- Soporte para modo oscuro
- Nueva API para configuración avanzada
- Documentación de ejemplos adicionales

### Changed
- Mejorado rendimiento de la cache
- Actualizada UI de configuración

### Fixed
- Corregido crash al cerrar la aplicación
- Solucionado problema de memoria en iOS

## [1.1.0] - 2023-12-10

### Added
- Soporte para autenticación OAuth
- Nuevos temas personalizables

### Fixed
- Corregido problema de sincronización
- Mejorada estabilidad en Android

## [1.0.0] - 2023-11-01

### Added
- Release inicial
- Funcionalidad core completa
- Documentación básica
- Tests unitarios y de integración

[Unreleased]: https://github.com/usuario/proyecto/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/usuario/proyecto/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/usuario/proyecto/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/usuario/proyecto/releases/tag/v1.0.0
```

### Scripts de Automatización

**tool/version_bump.dart:**
```dart
#!/usr/bin/env dart

import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart tool/version_bump.dart <major|minor|patch>');
    exit(1);
  }

  final type = args[0];
  final pubspecFile = File('pubspec.yaml');
  
  if (!pubspecFile.existsSync()) {
    print('pubspec.yaml not found');
    exit(1);
  }

  final content = pubspecFile.readAsStringSync();
  final versionRegex = RegExp(r'version:\s*(\d+)\.(\d+)\.(\d+)(\+\d+)?');
  final match = versionRegex.firstMatch(content);
  
  if (match == null) {
    print('Version not found in pubspec.yaml');
    exit(1);
  }

  var major = int.parse(match.group(1)!);
  var minor = int.parse(match.group(2)!);
  var patch = int.parse(match.group(3)!);
  final buildNumber = match.group(4) ?? '+1';

  switch (type) {
    case 'major':
      major++;
      minor = 0;
      patch = 0;
      break;
    case 'minor':
      minor++;
      patch = 0;
      break;
    case 'patch':
      patch++;
      break;
    default:
      print('Invalid version type: $type');
      exit(1);
  }

  final newVersion = '$major.$minor.$patch$buildNumber';
  final newContent = content.replaceFirst(versionRegex, 'version: $newVersion');
  
  pubspecFile.writeAsStringSync(newContent);
  print('Version updated to: $newVersion');
}
```

---

## 🛠️ Herramientas y Scripts

### Script de Configuración Inicial

**tool/setup.dart:**
```dart
#!/usr/bin/env dart

import 'dart:io';

Future<void> main() async {
  print('🚀 Configurando proyecto Flutter...\n');
  
  // Instalar herramientas globales
  await _runCommand('dart pub global activate pana');
  await _runCommand('dart pub global activate dart_code_metrics');
  await _runCommand('dart pub global activate very_good_cli');
  
  // Instalar dependencias
  await _runCommand('flutter pub get');
  
  // Generar código si es necesario
  if (File('build.yaml').existsSync()) {
    await _runCommand('dart run build_runner build --delete-conflicting-outputs');
  }
  
  // Ejecutar análisis inicial
  await _runCommand('flutter analyze');
  
  // Ejecutar tests
  await _runCommand('flutter test');
  
  print('\n✅ Proyecto configurado exitosamente!');
  print('📋 Próximos pasos:');
  print('   - Revisa analysis_options.yaml');
  print('   - Configura tu IDE');
  print('   - Comienza a desarrollar! 🎉');
}

Future<void> _runCommand(String command) async {
  print('Ejecutando: $command');
  
  final parts = command.split(' ');
  final result = await Process.run(
    parts.first,
    parts.skip(1).toList(),
    runInShell: true,
  );
  
  if (result.exitCode != 0) {
    print('❌ Error ejecutando: $command');
    print(result.stderr);
  } else {
    print('✅ Completado: $command\n');
  }
}
```

### Makefile para Comandos Comunes

**Makefile:**
```makefile
.PHONY: help setup clean build test analyze format coverage doctor

help: ## Muestra ayuda
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

setup: ## Configura el proyecto inicial
	@dart tool/setup.dart

clean: ## Limpia archivos generados
	@flutter clean
	@dart run build_runner clean

build: ## Construye la aplicación
	@flutter build apk
	@flutter build ios --no-codesign

test: ## Ejecuta todos los tests
	@flutter test --coverage

analyze: ## Ejecuta análisis estático
	@flutter analyze
	@dart run dart_code_metrics:metrics analyze lib

format: ## Formatea el código
	@dart format --set-exit-if-changed .

coverage: ## Genera reporte de coverage
	@flutter test --coverage
	@genhtml coverage/lcov.info -o coverage/html
	@open coverage/html/index.html

doctor: ## Verifica configuración de Flutter
	@flutter doctor -v

deps: ## Actualiza dependencias
	@flutter pub upgrade
	@flutter pub get

generate: ## Genera código
	@dart run build_runner build --delete-conflicting-outputs

publish-dry: ## Simula publicación
	@dart pub publish --dry-run

publish: ## Publica a pub.dev
	@dart pub publish

version-patch: ## Incrementa version patch
	@dart tool/version_bump.dart patch

version-minor: ## Incrementa version minor
	@dart tool/version_bump.dart minor

version-major: ## Incrementa version major
	@dart tool/version_bump.dart major
```

### Script de Pre-commit

**.git/hooks/pre-commit:**
```bash
#!/bin/sh

echo "🔍 Ejecutando pre-commit hooks..."

# Formatear código
echo "📝 Formateando código..."
dart format --set-exit-if-changed .
if [ $? -ne 0 ]; then
  echo "❌ Formato de código fallido"
  exit 1
fi

# Análisis estático
echo "🔬 Ejecutando análisis estático..."
flutter analyze
if [ $? -ne 0 ]; then
  echo "❌ Análisis estático fallido"
  exit 1
fi

# Tests
echo "🧪 Ejecutando tests..."
flutter test
if [ $? -ne 0 ]; then
  echo "❌ Tests fallidos"
  exit 1
fi

echo "✅ Pre-commit hooks completados exitosamente!"
```

---

## 📚 Recursos Adicionales

### Documentación Oficial
- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [pub.dev Package Publishing](https://dart.dev/tools/pub/publishing)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)

### Herramientas Recomendadas
- [Pana](https://pub.dev/packages/pana) - Análisis de paquetes
- [Very Good CLI](https://pub.dev/packages/very_good_cli) - Templates y herramientas
- [Dart Code Metrics](https://pub.dev/packages/dart_code_metrics) - Métricas de código
- [Flutter Inspector](https://docs.flutter.dev/development/tools/devtools/inspector) - Debugging UI

### Packages Esenciales
- **State Management**: flutter_bloc, provider, riverpod
- **Navigation**: go_router, auto_route
- **Network**: dio, chopper
- **Storage**: shared_preferences, hive, sqflite
- **Testing**: mocktail, bloc_test, golden_toolkit
- **Utils**: equatable, freezed, json_annotation

---

## 🎯 Checklist Final

Antes de publicar tu paquete, verifica:

### 📋 Preparación
- [ ] Nombre de paquete único y descriptivo
- [ ] Descripción clara y concisa
- [ ] Versión semántica correcta
- [ ] Licencia OSI apropiada

### 📄 Documentación
- [ ] README.md completo con ejemplos
- [ ] CHANGELOG.md actualizado
- [ ] Documentación de API (dartdoc)
- [ ] Carpeta example/ funcional

### 🧪 Calidad
- [ ] Tests unitarios (>80% coverage)
- [ ] Tests de widgets
- [ ] Tests de integración
- [ ] Análisis estático sin errores
- [ ] Formato de código consistente

### 🚀 Publicación
- [ ] `dart pub publish --dry-run` exitoso
- [ ] Verificación con pana (130+ puntos)
- [ ] CI/CD configurado
- [ ] Repositorio Git público

### 🔄 Mantenimiento
- [ ] Plan de actualizaciones
- [ ] Monitoreo de issues
- [ ] Documentación de contribución
- [ ] Roadmap futuro

---

¡Felicidades! 🎉 Ahora tienes todo lo necesario para crear aplicaciones Flutter y paquetes Dart de calidad profesional que cumplan con las mejores prácticas y estén listos para pub.dev.

**¿Tienes preguntas?** Revisa la documentación oficial o abre un issue en el repositorio del proyecto.
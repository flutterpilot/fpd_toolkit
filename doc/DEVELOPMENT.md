# Guía de Desarrollo - FPD Toolkit

Esta guía está dirigida a desarrolladores que quieren contribuir al proyecto FPD Toolkit o ejecutarlo en modo desarrollo.

## 🛠️ Configuración del Entorno de Desarrollo

### Prerrequisitos

- **Dart SDK**: ^3.7.0-0 o superior
- **Flutter SDK**: ^3.24.0 o superior (opcional, solo si trabajas con ejemplos Flutter)
- **Git**: Para clonar y contribuir al proyecto
- **Editor**: VS Code, IntelliJ IDEA, o cualquier editor con soporte Dart

### Instalación para Desarrollo

1. **Clonar el repositorio**:
```bash
git clone https://github.com/fpd-toolkit/fpd_toolkit.git
cd fpd_toolkit
```

2. **Instalar dependencias**:
```bash
dart pub get
```

3. **Verificar instalación**:
```bash
dart run bin/fpd_toolkit.dart --help
```

## 🚀 Ejecutar en Modo Desarrollo

### Comando Principal
```bash
# Ejecutar directamente desde el código fuente
dart run bin/fpd_toolkit.dart [comando] [opciones]
```

### Ejemplos de Desarrollo
```bash
# Crear paquete en modo desarrollo
dart run bin/fpd_toolkit.dart create package test_pkg --description "Test package"

# Validar paquete
dart run bin/fpd_toolkit.dart validate test_pkg

# Ver guías disponibles
dart run bin/fpd_toolkit.dart guide --help

# Ejecutar con logs verbose
dart run bin/fpd_toolkit.dart --verbose create package debug_pkg
```

### Modo Debug con Verbose
```bash
# Activar logs detallados para debugging
export FLUTTER_PILOT_DEBUG=true
dart run bin/fpd_toolkit.dart --verbose [comando]
```

## 🧪 Testing y Desarrollo

### Ejecutar Tests
```bash
# Todos los tests
dart test

# Tests específicos
dart test test/specific_test.dart

# Tests con cobertura
dart test --coverage=coverage
genhtml -o coverage/html coverage/lcov.info
```

### Análisis de Código
```bash
# Análisis estático
dart analyze

# Formateo de código
dart format .

# Fix automático de issues
dart fix --apply
```

### Testing Manual
```bash
# Crear directorio temporal para tests
mkdir -p /tmp/flutter_pilot_test
cd /tmp/flutter_pilot_test

# Probar generación de diferentes tipos
dart run [ruta_al_proyecto]/bin/fpd_toolkit.dart create package test_package
dart run [ruta_al_proyecto]/bin/fpd_toolkit.dart create app test_app
dart run [ruta_al_proyecto]/bin/fpd_toolkit.dart create plugin test_plugin --platforms android,ios
```

## 📁 Estructura del Código

### Arquitectura de Carpetas
```
lib/src/
├── cli_runner.dart              # Punto de entrada principal
├── commands/                    # Comandos individuales
│   ├── base_command.dart        # Clase base para comandos
│   ├── create_command.dart      # Comando de creación
│   ├── validate_command.dart    # Comando de validación
│   ├── guide_command.dart       # Comando de guías
│   ├── example_command.dart     # Comando de ejemplos
│   ├── template_command.dart    # Gestión de templates
│   └── init_command.dart        # Inicialización de proyectos
├── generators/                  # Generadores de código
│   └── package_generator.dart   # Generador principal
├── utils/                       # Utilidades compartidas
│   ├── logger.dart             # Sistema de logging
│   ├── validator.dart          # Validaciones
│   └── file_utils.dart         # Operaciones de archivos
└── templates/                   # Templates y plantillas
```

### Flujo de Comandos
1. **CLI Entry Point** (`bin/fpd_toolkit.dart`)
2. **CLI Runner** (`cli_runner.dart`) - Parsea argumentos
3. **Command Selection** - Selecciona comando específico
4. **Command Execution** - Ejecuta lógica del comando
5. **Generator/Utils** - Operaciones de generación/validación
6. **File Output** - Creación de archivos/directorios

## 🔧 Desarrollo de Nuevas Características

### Agregar Nuevo Comando

1. **Crear clase de comando**:
```dart
// lib/src/commands/new_command.dart
import 'base_command.dart';

class NewCommand extends BaseCommand {
  @override
  String get description => 'Descripción del nuevo comando';
  
  @override
  String get name => 'new-cmd';
  
  NewCommand() {
    argParser.addOption(
      'option',
      help: 'Descripción de la opción',
      defaultsTo: 'default-value',
    );
  }
  
  @override
  Future<void> execute() async {
    final option = argResults!['option'] as String;
    Logger.info('Ejecutando nuevo comando with option: $option');
    
    // Lógica del comando aquí
  }
}
```

2. **Registrar en CLI Runner**:
```dart
// lib/src/cli_runner.dart
void _setupCommands() {
  addCommand(CreateCommand());
  addCommand(ValidateCommand());
  addCommand(GuideCommand());
  addCommand(ExampleCommand());
  addCommand(TemplateCommand());
  addCommand(InitCommand());
  addCommand(NewCommand()); // ← Agregar aquí
}
```

3. **Exportar en commands.dart**:
```dart
// lib/src/commands/commands.dart
export 'new_command.dart';
```

### Agregar Nuevo Template

1. **Extender PackageGenerator**:
```dart
// En lib/src/generators/package_generator.dart
Future<void> _generateNewType(Directory outputDir, PackageOptions options) async {
  Logger.verbose('Generando nuevo tipo de proyecto');
  
  // Crear estructura de directorios
  await _createDirectoryStructure(outputDir, [
    'lib/src',
    'test',
    'custom_dir',
  ]);
  
  // Generar archivos específicos
  await _generateCustomFiles(outputDir, options);
}

String _getCustomTemplateContent(PackageOptions options) {
  return '''
// Template personalizado aquí
''';
}
```

2. **Agregar al switch statement**:
```dart
switch (options.type) {
  case 'app':
    await _generateFlutterApp(outputDir, options);
    break;
  case 'plugin':
    await _generateFlutterPlugin(outputDir, options);
    break;
  case 'package':
    await _generateDartPackage(outputDir, options);
    break;
  case 'new-type': // ← Nuevo tipo
    await _generateNewType(outputDir, options);
    break;
  default:
    throw ArgumentError('Tipo de paquete no soportado: ${options.type}');
}
```

## 🧩 Debugging y Troubleshooting

### Variables de Entorno para Debug
```bash
# Activar modo debug
export FLUTTER_PILOT_DEBUG=true

# Directorio temporal para tests
export FLUTTER_PILOT_TEMP_DIR=/tmp/flutter_pilot_debug

# Nivel de logging detallado
export FLUTTER_PILOT_LOG_LEVEL=verbose
```

### Debugging con VS Code

Crear `.vscode/launch.json`:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "FPD Toolkit",
      "request": "launch",
      "type": "dart",
      "program": "bin/fpd_toolkit.dart",
      "args": ["create", "package", "debug_pkg", "--description", "Debug package"],
      "cwd": "${workspaceFolder}",
      "console": "terminal"
    },
    {
      "name": "FPD Toolkit - Tests",
      "request": "launch",
      "type": "dart",
      "program": "test/",
      "cwd": "${workspaceFolder}"
    }
  ]
}
```

### Logging y Diagnósticos
```dart
// En tu código
Logger.verbose('Información detallada de debugging');
Logger.info('Información general');
Logger.warning('Advertencia importante');
Logger.error('Error crítico');

// Para debugging de operaciones de archivos
Logger.verbose('Creando archivo: ${filePath}');
Logger.verbose('Contenido: ${content.length} caracteres');
```

## 🔍 Profiling y Performance

### Análizar Performance
```bash
# Ejecutar con profiling
dart run --observe bin/fpd_toolkit.dart create package perf_test

# Medir tiempo de ejecución
time dart run bin/fpd_toolkit.dart create package timing_test
```

### Memory Profiling
```bash
# Usar dartanalyzer para detectar memory leaks
dart analyze --fatal-infos

# Validar que no hay recursos sin cerrar
dart run bin/fpd_toolkit.dart validate generated_package
```

## 📦 Build y Release

### Preparar Release
```bash
# Validar todo el código
dart analyze
dart test
dart format --set-exit-if-changed .

# Verificar que funciona en diferentes plataformas
dart run bin/fpd_toolkit.dart create package cross_platform_test
```

### Testing de Integración
```bash
# Test completo de flujo
./scripts/integration_test.sh
```

Crear `scripts/integration_test.sh`:
```bash
#!/bin/bash
set -e

echo "🧪 Ejecutando tests de integración..."

# Crear directorio temporal
TEST_DIR=$(mktemp -d)
cd "$TEST_DIR"

# Test diferentes tipos de proyectos
echo "📦 Testing package generation..."
dart run "$OLDPWD/bin/fpd_toolkit.dart" create package integration_package

echo "📱 Testing app generation..."
dart run "$OLDPWD/bin/fpd_toolkit.dart" create app integration_app

echo "🔌 Testing plugin generation..."
dart run "$OLDPWD/bin/fpd_toolkit.dart" create plugin integration_plugin --platforms android,ios

echo "✅ Testing validation..."
dart run "$OLDPWD/bin/fpd_toolkit.dart" validate integration_package

echo "🎉 Integration tests passed!"

# Cleanup
cd "$OLDPWD"
rm -rf "$TEST_DIR"
```

## 🤝 Contribución y Pull Requests

### Proceso de Desarrollo

1. **Fork del repositorio**
2. **Crear feature branch**:
   ```bash
   git checkout -b feature/nueva-caracteristica
   ```

3. **Desarrollar con tests**:
   ```bash
   # Escribir tests primero (TDD)
   dart test test/nueva_caracteristica_test.dart
   
   # Implementar funcionalidad
   # Validar que tests pasan
   dart test
   ```

4. **Validar calidad**:
   ```bash
   dart analyze
   dart format .
   dart test --coverage=coverage
   ```

5. **Commit y push**:
   ```bash
   git add .
   git commit -m "feat: agregar nueva característica"
   git push origin feature/nueva-caracteristica
   ```

6. **Crear Pull Request**

### Estándares de Código

- **Documentar APIs públicas** con doc comments
- **Seguir naming conventions** de Dart
- **Escribir tests** para nueva funcionalidad
- **Mantener cobertura > 80%**
- **Usar lints** configurados en `analysis_options.yaml`

### Review Checklist

- [ ] Tests pasan (`dart test`)
- [ ] Análisis limpio (`dart analyze`)
- [ ] Formato correcto (`dart format --set-exit-if-changed .`)
- [ ] Documentación actualizada
- [ ] Backwards compatibility mantenida
- [ ] Performance no degradada

## 📚 Recursos Adicionales

### Links Útiles
- **[Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)**
- **[Package Development](https://dart.dev/guides/libraries/create-library-packages)**
- **[pub.dev Publishing](https://dart.dev/tools/pub/publishing)**

### Herramientas Recomendadas
- **[Dart Code (VS Code)](https://marketplace.visualstudio.com/items?itemName=Dart-Code.dart-code)**
- **[Flutter Inspector](https://docs.flutter.dev/development/tools/devtools/inspector)**
- **[Dart DevTools](https://dart.dev/tools/dart-devtools)**

### Scripts de Utilidad

Crear `scripts/dev_setup.sh`:
```bash
#!/bin/bash
echo "🛠️ Configurando entorno de desarrollo..."

# Verificar Dart SDK
if ! command -v dart &> /dev/null; then
    echo "❌ Dart SDK no encontrado. Instala desde https://dart.dev/get-dart"
    exit 1
fi

# Instalar dependencias
echo "📦 Instalando dependencias..."
dart pub get

# Ejecutar análisis inicial
echo "🔍 Ejecutando análisis de código..."
dart analyze

# Ejecutar tests
echo "🧪 Ejecutando tests..."
dart test

echo "✅ Entorno configurado correctamente!"
echo "🚀 Ejecuta: dart run bin/fpd_toolkit.dart --help"
```

¡Con esta configuración tienes todo lo necesario para desarrollar y contribuir al FPD Toolkit! 🚀
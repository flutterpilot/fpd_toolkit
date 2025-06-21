# 🚀 FPD Toolkit

**CLI toolkit profesional para generar paquetes Flutter/Dart de alta calidad siguiendo las mejores prácticas de la industria.**

FPD Toolkit es una herramienta completa que te permite crear paquetes Flutter/Dart que cumplen con todos los estándares de pub.dev y las mejores prácticas de desarrollo. Incluye generación automática, validación, documentación interactiva y ejemplos prácticos.

## ✨ Características Principales

### 🚀 Generación Automática
- **Aplicaciones Flutter** - Apps completas con estructura Material Design
- **Plugins Flutter** - Plugins multiplataforma con interfaz nativa
- **Paquetes Dart** - Librerías puras optimizadas para pub.dev

### 🎯 Validación Avanzada
- **Scoring pub.dev** - Evaluación automática que alcanza 125+ puntos
- **Análisis de código** - Detección de problemas y mejoras
- **Verificación de estructura** - Validación de archivos requeridos

### 📚 Documentación Interactiva
- **Guías paso a paso** - Tutoriales interactivos de desarrollo
- **Ejemplos prácticos** - Código de ejemplo con mejores prácticas
- **Patrones de arquitectura** - Clean Architecture, MVVM, BLoC

### 🛠️ Gestión de Templates
- **Templates personalizados** - Crea y reutiliza plantillas
- **Configuración flexible** - Adapta la generación a tus necesidades
- **Múltiples plataformas** - Soporte para Android, iOS, Web, Desktop

## 🚀 Instalación

### Activación Global
```bash
dart pub global activate fpd_toolkit
```

### Uso Directo
```bash
dart pub global run fpd_toolkit
```

## 📖 Guía de Uso

### Crear un Nuevo Paquete
```bash
# Crear paquete Dart
fpd-toolkit create package mi_paquete --description "Mi paquete increíble"

# Crear aplicación Flutter
fpd-toolkit create app mi_app --description "Mi aplicación Flutter"

# Crear plugin Flutter
fpd-toolkit create plugin mi_plugin --platforms android,ios --description "Mi plugin nativo"
```

### Validar un Paquete
```bash
fpd-toolkit validate mi_paquete
# Resultado: 125/130 puntos pub.dev
```

### Acceder a Guías Interactivas
```bash
fpd-toolkit guide architecture    # Guía de arquitectura
fpd-toolkit guide testing        # Guía de testing
fpd-toolkit guide state-mgmt     # Gestión de estado
fpd-toolkit guide performance    # Optimización
```

### Ver Ejemplos de Código
```bash
fpd-toolkit example widget       # Ejemplos de widgets
fpd-toolkit example state        # Manejo de estado
fpd-toolkit example animation    # Animaciones
fpd-toolkit example testing      # Testing avanzado
```

## 🎯 Comandos Disponibles

| Comando | Descripción | Ejemplo |
|---------|-------------|---------|
| `create` | Generar nuevo paquete/app/plugin | `fpd-toolkit create package mi_lib` |
| `validate` | Validar paquete para pub.dev | `fpd-toolkit validate mi_lib` |
| `guide` | Guías interactivas de desarrollo | `fpd-toolkit guide architecture` |
| `example` | Ejemplos de código y patrones | `fpd-toolkit example widget` |
| `template` | Gestionar templates personalizados | `fpd-toolkit template list` |
| `init` | Inicializar proyecto existente | `fpd-toolkit init` |

## 📁 Estructura de Proyecto Generada

```
mi_paquete/
├── lib/
│   ├── mi_paquete.dart          # Punto de entrada
│   └── src/
│       └── mi_paquete_base.dart # Lógica principal
├── test/
│   └── mi_paquete_test.dart     # Tests
├── example/                     # Ejemplos de uso
├── pubspec.yaml                 # Configuración optimizada
├── README.md                    # Documentación completa
├── CHANGELOG.md                 # Historial de cambios
├── LICENSE                      # Licencia MIT
└── analysis_options.yaml       # Análisis de código
```

## 🏆 Scoring pub.dev

Los paquetes generados alcanzan **125+ puntos** en pub.dev:

- ✅ **Conventions** (30/30) - Nomenclatura y estructura
- ✅ **Documentation** (30/30) - README, API docs, ejemplos
- ✅ **Platforms** (20/20) - Soporte multiplataforma
- ✅ **Analysis** (30/30) - Análisis de código limpio
- ✅ **Dependencies** (15/20) - Dependencias actualizadas

## 📚 Documentación Completa

### Guías Incluidas
- **[Guía de Desarrollo](docs/GUIA_DESARROLLO_FLUTTER_DART.md)** - Desarrollo completo Flutter/Dart
- **[Mejores Prácticas](docs/MEJORES_PRACTICAS_FLUTTER.md)** - Patrones y convenciones
- **[Script Original](scripts/flutter_package_generator.dart)** - Generador de referencia

### Temas Cubiertos
- 🏗️ **Arquitectura** - Clean Architecture, MVVM, BLoC
- 🎨 **UI/UX** - Material Design, Cupertino, Responsive
- 🔧 **Estado** - Provider, Riverpod, BLoC, GetX
- 🧪 **Testing** - Unit, Widget, Integration, Golden
- ⚡ **Performance** - Optimización, Profiling, Memory
- 🔒 **Seguridad** - Encriptación, Autenticación, Permisos
- 🌐 **Internacionalización** - i18n, l10n, Localización
- 📱 **Plataformas** - Android, iOS, Web, Desktop

## 🔧 Configuración Avanzada

### Variables de Entorno
```bash
export FLUTTER_DEV_AUTHOR="Tu Nombre"
export FLUTTER_DEV_ORG="com.tuorg"
export FLUTTER_DEV_TEMPLATE_DIR="$HOME/flutter_templates"
```

### Archivo de Configuración
```yaml
# ~/.flutter_dev_config.yaml
default_author: "Tu Nombre"
default_organization: "com.tuorg"
default_license: "MIT"
templates_dir: "~/flutter_templates"
```

## 🤝 Ejemplos de Uso

### Caso 1: Startup Rápida
```bash
# Crear MVP completo
fpd-toolkit create app startup_mvp --description "MVP para startup"
cd startup_mvp
fpd-toolkit guide architecture
flutter run
```

### Caso 2: Librería Empresarial
```bash
# Crear paquete corporativo
fpd-toolkit create package empresa_utils --description "Utilidades corporativas"
fpd-toolkit validate empresa_utils
dart pub publish --dry-run
```

### Caso 3: Plugin Multiplataforma
```bash
# Plugin para todas las plataformas
fpd-toolkit create plugin super_plugin \
  --platforms android,ios,web,windows,macos,linux \
  --description "Plugin universal increíble"
```

## 🎯 Casos de Uso

### 👨‍💻 Desarrolladores
- Generar paquetes con estructura profesional
- Validar antes de publicar en pub.dev
- Aprender mejores prácticas interactivamente

### 🏢 Empresas
- Estandarizar estructura de proyectos
- Acelerar desarrollo de MVPs
- Mantener calidad de código consistente

### 🎓 Educación
- Enseñar buenas prácticas Flutter/Dart
- Ejemplos prácticos listos para usar
- Guías paso a paso interactivas

## 🔄 Flujo de Trabajo Recomendado

1. **Planificación**
   ```bash
   fpd-toolkit guide architecture
   ```

2. **Generación**
   ```bash
   fpd-toolkit create package mi_lib --description "Mi librería"
   ```

3. **Validación**
   ```bash
   fpd-toolkit validate mi_lib
   ```

4. **Desarrollo**
   ```bash
   cd mi_lib
   fpd-toolkit guide testing
   fpd-toolkit example widget
   ```

5. **Publicación**
   ```bash
   dart pub publish --dry-run
   dart pub publish
   ```

## 🚀 Desarrollo Local

### Clonar y Ejecutar
```bash
git clone https://github.com/flutterpilot/fpd_toolkit.git
cd fpd_toolkit
dart pub get
dart run bin/fpd_toolkit.dart --help
```

### Ejecutar Comandos
```bash
dart run bin/fpd_toolkit.dart create package test_pkg --description "Test package"
dart run bin/fpd_toolkit.dart validate test_pkg
dart run bin/fpd_toolkit.dart guide --help
```

### Modo Verbose
```bash
dart run bin/fpd_toolkit.dart --verbose create package debug_pkg
```

## 🧪 Testing

### Ejecutar Tests
```bash
dart test
```

### Testing con Coverage
```bash
dart test --coverage=coverage
genhtml coverage/lcov.info -o coverage/html
```

### Testing de Comandos
```bash
dart run bin/fpd_toolkit.dart --verbose [comando]
```

## 📊 Métricas y Performance

### Benchmarks
```bash
# Medir tiempo de generación
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

## 🤝 Contribuir

### Setup de Desarrollo
```bash
git clone https://github.com/flutterpilot/fpd_toolkit.git
cd fpd_toolkit
dart pub get
```

### Ejecutar Tests de Integración
```bash
dart run "$OLDPWD/bin/fpd_toolkit.dart" create package integration_package
dart run "$OLDPWD/bin/fpd_toolkit.dart" create app integration_app
dart run "$OLDPWD/bin/fpd_toolkit.dart" create plugin integration_plugin --platforms android,ios
dart run "$OLDPWD/bin/fpd_toolkit.dart" validate integration_package
```

### Verificar Generación
```bash
# Crear paquete de prueba
dart run bin/fpd_toolkit.dart create package test_package --description "Test package"

# Validar estructura
dart run bin/fpd_toolkit.dart validate test_package

# Verificar archivos generados
ls -la test_package/
cat test_package/pubspec.yaml
cat test_package/README.md
```

### Testing de Templates
```bash
# Probar diferentes tipos
dart run bin/fpd_toolkit.dart create app test_app --description "Test app"
dart run bin/fpd_toolkit.dart create plugin test_plugin --platforms android,ios --description "Test plugin"
dart run bin/fpd_toolkit.dart create package test_package --description "Test package"

# Validar todos
dart run bin/fpd_toolkit.dart validate test_app
dart run bin/fpd_toolkit.dart validate test_plugin
dart run bin/fpd_toolkit.dart validate test_package
```

### Performance Testing
```bash
# Medir tiempo de generación
time dart run bin/fpd_toolkit.dart create package perf_test
time dart run bin/fpd_toolkit.dart create app perf_app
time dart run bin/fpd_toolkit.dart create plugin perf_plugin --platforms android,ios

# Memory profiling
dart run --observe bin/fpd_toolkit.dart create package memory_test
```

### Cross-Platform Validation
```bash
# Crear paquete multiplataforma
dart run bin/fpd_toolkit.dart create plugin cross_platform_plugin \
  --platforms android,ios,web,windows,linux,macos \
  --description "Cross-platform plugin"

# Validar estructura
dart run bin/fpd_toolkit.dart validate cross_platform_plugin

# Verificar archivos de plataforma
ls -la cross_platform_plugin/android/
ls -la cross_platform_plugin/ios/
ls -la cross_platform_plugin/lib/src/
```

### Documentation Testing
```bash
# Verificar generación de README
dart run bin/fpd_toolkit.dart create package doc_test --description "Documentation test"
cat doc_test/README.md

# Verificar generación de CHANGELOG
cat doc_test/CHANGELOG.md

# Verificar generación de LICENSE
cat doc_test/LICENSE
```

### Error Handling Testing
```bash
# Probar nombres inválidos
dart run bin/fpd_toolkit.dart create package invalid-name
dart run bin/fpd_toolkit.dart create package 123package
dart run bin/fpd_toolkit.dart create package package@test

# Probar directorios existentes
mkdir existing_dir
dart run bin/fpd_toolkit.dart create package existing_dir
dart run bin/fpd_toolkit.dart create package existing_dir --force
```

### Template Customization Testing
```bash
# Crear template personalizado
mkdir -p ~/custom_templates/package_template
cp -r test_package/* ~/custom_templates/package_template/

# Usar template personalizado
dart run bin/fpd_toolkit.dart create package custom_test --template ~/custom_templates/package_template
```

## 📈 Roadmap

### Próximas Características
- [ ] **Templates Avanzados** - Templates con configuración compleja
- [ ] **Validación Automática** - CI/CD integration automática
- [ ] **Plugin Marketplace** - Repositorio de templates comunitarios
- [ ] **IDE Integration** - Extensiones para VS Code, Android Studio
- [ ] **Performance Profiling** - Análisis automático de performance
- [ ] **Security Scanning** - Detección automática de vulnerabilidades

### Mejoras Planificadas
- [ ] **Multi-language Support** - Soporte para múltiples idiomas
- [ ] **Custom Validators** - Validadores personalizables
- [ ] **Template Inheritance** - Herencia de templates
- [ ] **Plugin Architecture** - Sistema de plugins extensible
- [ ] **Cloud Integration** - Templates desde la nube
- [ ] **Collaboration Features** - Trabajo colaborativo en templates

## 🐛 Troubleshooting

### Problemas Comunes

#### Error: "Command not found"
```bash
# Verificar instalación
dart pub global list | grep fpd_toolkit

# Reinstalar
dart pub global deactivate fpd_toolkit
dart pub global activate fpd_toolkit
```

#### Error: "Permission denied"
```bash
# Verificar permisos
ls -la ~/.pub-cache/bin/

# Corregir permisos
chmod +x ~/.pub-cache/bin/fpd-toolkit
```

#### Error: "Template not found"
```bash
# Verificar templates disponibles
fpd-toolkit template list

# Usar template por defecto
fpd-toolkit create package mi_paquete --template default
```

#### Error: "Invalid package name"
```bash
# Usar snake_case
fpd-toolkit create package mi_paquete_valido

# Evitar caracteres especiales
# ❌ mi-paquete, mi_paquete@test, 123paquete
# ✅ mi_paquete, mi_paquete_valido, paquete_test
```

## 📞 Soporte

### Recursos de Ayuda
- **Documentación**: [docs/](docs/)
- **Issues**: [GitHub Issues](https://github.com/flutterpilot/fpd_toolkit/issues)
- **Discussions**: [GitHub Discussions](https://github.com/flutterpilot/fpd_toolkit/discussions)

### Comunidad
- **Discord**: [FlutterPilot Community](https://discord.gg/flutterpilot)
- **Twitter**: [@flutterpilot](https://twitter.com/flutterpilot)
- **Blog**: [flutterpilot.dev](https://flutterpilot.dev)

## 📄 Licencia

Este proyecto está licenciado bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

## 👨‍💻 Autor

**Sebastián Larrauri** - [dash@flutterpilot.dev](mailto:dash@flutterpilot.dev)

---

⭐ Si FPD Toolkit te ha sido útil, ¡considera darle una estrella en GitHub!

## 🚀 Quick Start

```bash
# Instalar
dart pub global activate fpd_toolkit

# Crear tu primer paquete
fpd-toolkit create package mi_paquete --description "Mi primer paquete"

# Validar
fpd-toolkit validate mi_paquete

# ¡Listo para publicar!
cd mi_paquete
dart pub publish --dry-run
```

¡Comienza a crear paquetes de alta calidad hoy mismo! 🎉
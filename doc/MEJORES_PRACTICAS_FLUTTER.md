# 🏆 Mejores Prácticas Flutter/Dart - Basado en Ejemplos Oficiales

Esta guía se basa en el análisis exhaustivo de los repositorios oficiales de Flutter, incluyendo muestras, pub.dev, y el SDK principal. Implementa estas prácticas para crear código de calidad profesional.

## 📋 Índice

1. [Arquitectura y Estructura](#arquitectura-y-estructura)
2. [Gestión de Estado](#gestión-de-estado)
3. [UI/UX y Widgets](#uiux-y-widgets)
4. [Performance y Optimización](#performance-y-optimización)
5. [Testing Estratégico](#testing-estratégico)
6. [Seguridad y Privacidad](#seguridad-y-privacidad)
7. [Desarrollo Multiplataforma](#desarrollo-multiplataforma)
8. [Mantenimiento de Código](#mantenimiento-de-código)

---

## 🏗️ Arquitectura y Estructura

### Clean Architecture Pattern

Basado en el ejemplo `compass_app`, implementa una arquitectura limpia y escalable:

```
lib/
├── core/                     # Funcionalidades compartidas
│   ├── constants/
│   ├── errors/
│   ├── utils/
│   └── extensions/
├── data/                     # Capa de datos
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/                   # Lógica de negocio
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/             # UI y estado
│   ├── pages/
│   ├── widgets/
│   ├── providers/
│   └── theme/
└── services/                 # Servicios externos
```

### Separación de Responsabilidades

#### ✅ Correcto - Separación Clara
```dart
// data/models/user_model.dart
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}

// domain/entities/user.dart
class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    required this.email,
  });

  final String id;
  final String name;
  final String email;

  @override
  List<Object> get props => [id, name, email];
}

// domain/usecases/get_user.dart
class GetUser {
  const GetUser(this._repository);
  
  final UserRepository _repository;

  Future<Either<Failure, User>> call(String userId) {
    return _repository.getUser(userId);
  }
}
```

### Inyección de Dependencias

#### Pattern Provider con GetIt (basado en ejemplos oficiales)
```dart
// core/injection_container.dart
final sl = GetIt.instance;

Future<void> init() async {
  // External
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => SharedPreferences.getInstance());

  // Data sources
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(client: sl()),
  );

  // Repositories
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetUser(sl()));

  // BLoCs
  sl.registerFactory(() => UserBloc(getUser: sl()));
}
```

---

## 🔄 Gestión de Estado

### BLoC Pattern (Recomendado por Flutter Team)

#### Implementación basada en ejemplos oficiales:
```dart
// Eventos
abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class GetUserEvent extends UserEvent {
  const GetUserEvent(this.userId);
  
  final String userId;

  @override
  List<Object> get props => [userId];
}

// Estados
abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  const UserLoaded(this.user);
  
  final User user;

  @override
  List<Object> get props => [user];
}

class UserError extends UserState {
  const UserError(this.message);
  
  final String message;

  @override
  List<Object> get props => [message];
}

// BLoC
class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc({required GetUser getUser})
      : _getUser = getUser,
        super(UserInitial()) {
    on<GetUserEvent>(_onGetUser);
  }

  final GetUser _getUser;

  Future<void> _onGetUser(
    GetUserEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    
    final result = await _getUser(event.userId);
    
    result.fold(
      (failure) => emit(UserError(_mapFailureToMessage(failure))),
      (user) => emit(UserLoaded(user)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Error del servidor';
      case NetworkFailure:
        return 'Error de conexión';
      default:
        return 'Error inesperado';
    }
  }
}
```

### Provider Pattern (Para casos simples)

```dart
// providers/theme_provider.dart
class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = ThemeData.light();
  
  ThemeData get themeData => _themeData;
  
  bool get isDarkMode => _themeData.brightness == Brightness.dark;

  void toggleTheme() {
    _themeData = isDarkMode ? ThemeData.light() : ThemeData.dark();
    notifyListeners();
  }

  void setTheme(ThemeData theme) {
    _themeData = theme;
    notifyListeners();
  }
}

// Uso en widget
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            theme: themeProvider.themeData,
            home: const HomePage(),
          );
        },
      ),
    );
  }
}
```

---

## 🎨 UI/UX y Widgets

### Material 3 Design System

#### Implementación de temas consistentes:
```dart
// theme/app_theme.dart
class AppTheme {
  static const _primaryColor = Color(0xFF6750A4);
  static const _secondaryColor = Color(0xFF625B71);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
  );
}
```

### Widgets Reutilizables

#### Patrón de Widget Builder
```dart
// widgets/custom_card.dart
class CustomCard extends StatelessWidget {
  const CustomCard({
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.onTap,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.all(8),
      child: Card(
        elevation: elevation ?? 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

// Uso
CustomCard(
  onTap: () => Navigator.pushNamed(context, '/details'),
  child: Column(
    children: [
      Text('Título', style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 8),
      Text('Descripción', style: Theme.of(context).textTheme.bodyMedium),
    ],
  ),
)
```

### Responsive Design

#### Breakpoints y layouts adaptativos:
```dart
// utils/responsive.dart
class Responsive {
  static const double mobileBreakpoint = 768;
  static const double tabletBreakpoint = 1024;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
      MediaQuery.of(context).size.width < tabletBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint;

  static double getResponsiveValue({
    required BuildContext context,
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }
}

// widgets/responsive_layout.dart
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    required this.mobile,
    required this.tablet,
    required this.desktop,
    super.key,
  });

  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 768) return mobile;
        if (constraints.maxWidth < 1024) return tablet;
        return desktop;
      },
    );
  }
}
```

### Animaciones Suaves

#### Implementación de animaciones performantes:
```dart
// widgets/animated_list_item.dart
class AnimatedListItem extends StatefulWidget {
  const AnimatedListItem({
    required this.child,
    required this.index,
    super.key,
  });

  final Widget child;
  final int index;

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300 + (widget.index * 100)),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: widget.child,
          ),
        );
      },
    );
  }
}
```

---

## ⚡ Performance y Optimización

### Manejo de Listas Grandes

#### ListView.builder con optimizaciones:
```dart
// widgets/optimized_list_view.dart
class OptimizedListView<T> extends StatefulWidget {
  const OptimizedListView({
    required this.items,
    required this.itemBuilder,
    this.separatorBuilder,
    this.onRefresh,
    this.onLoadMore,
    this.hasMoreData = false,
    super.key,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final Future<void> Function()? onRefresh;
  final Future<void> Function()? onLoadMore;
  final bool hasMoreData;

  @override
  State<OptimizedListView<T>> createState() => _OptimizedListViewState<T>();
}

class _OptimizedListViewState<T> extends State<OptimizedListView<T>> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        widget.hasMoreData &&
        !_isLoadingMore &&
        widget.onLoadMore != null) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    
    setState(() => _isLoadingMore = true);
    await widget.onLoadMore!();
    setState(() => _isLoadingMore = false);
  }

  @override
  Widget build(BuildContext context) {
    Widget listView = ListView.separated(
      controller: _scrollController,
      itemCount: widget.items.length + (widget.hasMoreData ? 1 : 0),
      separatorBuilder: widget.separatorBuilder ?? 
          (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (index >= widget.items.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        return widget.itemBuilder(context, widget.items[index], index);
      },
    );

    if (widget.onRefresh != null) {
      listView = RefreshIndicator(
        onRefresh: widget.onRefresh!,
        child: listView,
      );
    }

    return listView;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
```

### Gestión de Memoria

#### Image caching y optimization:
```dart
// utils/image_cache_manager.dart
class ImageCacheManager {
  static const int _maxCacheSize = 100;
  static final Map<String, ui.Image> _cache = <String, ui.Image>{};
  static final List<String> _cacheOrder = <String>[];

  static Future<ImageProvider> getOptimizedImage(String url) async {
    // Para URLs remotas, usar CachedNetworkImage
    if (url.startsWith('http')) {
      return CachedNetworkImageProvider(
        url,
        cacheManager: DefaultCacheManager(),
        maxWidth: 800, // Limitar resolución
        maxHeight: 600,
      );
    }

    // Para assets locales
    return AssetImage(url);
  }

  static void _addToCache(String key, ui.Image image) {
    if (_cache.length >= _maxCacheSize) {
      final oldestKey = _cacheOrder.removeAt(0);
      _cache.remove(oldestKey);
    }

    _cache[key] = image;
    _cacheOrder.add(key);
  }

  static void clearCache() {
    _cache.clear();
    _cacheOrder.clear();
  }
}

// widgets/optimized_image.dart
class OptimizedImage extends StatelessWidget {
  const OptimizedImage({
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    super.key,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => 
          placeholder ?? const CircularProgressIndicator(),
        errorWidget: (context, url, error) => 
          errorWidget ?? const Icon(Icons.error),
        memCacheWidth: width?.toInt(),
        memCacheHeight: height?.toInt(),
      );
    }

    return Image.asset(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: width?.toInt(),
      cacheHeight: height?.toInt(),
    );
  }
}
```

### Build Optimization

#### Const constructors y widget separation:
```dart
// ✅ Correcto - Uso de const y separación
class UserCard extends StatelessWidget {
  const UserCard({
    required this.user,
    required this.onTap,
    super.key,
  });

  final User user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16), // const
          child: Row(
            children: [
              UserAvatar(user: user), // Widget separado
              const SizedBox(width: 16), // const
              Expanded(
                child: UserInfo(user: user), // Widget separado
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserAvatar extends StatelessWidget {
  const UserAvatar({required this.user, super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 24,
      backgroundImage: NetworkImage(user.avatarUrl),
    );
  }
}

class UserInfo extends StatelessWidget {
  const UserInfo({required this.user, super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user.name,
          style: Theme.of(context).textTheme.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: Theme.of(context).textTheme.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
```

---

## 🧪 Testing Estratégico

### Pirámide de Testing Completa

#### Test Unitario Exhaustivo:
```dart
// test/domain/usecases/get_user_test.dart
void main() {
  late GetUser usecase;
  late MockUserRepository mockRepository;

  setUp(() {
    mockRepository = MockUserRepository();
    usecase = GetUser(mockRepository);
  });

  group('GetUser', () {
    const testUser = User(
      id: '1',
      name: 'Test User',
      email: 'test@example.com',
    );

    test('should get user from repository when call is successful', () async {
      // arrange
      when(() => mockRepository.getUser(any()))
          .thenAnswer((_) async => const Right(testUser));

      // act
      final result = await usecase('1');

      // assert
      expect(result, const Right(testUser));
      verify(() => mockRepository.getUser('1')).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when repository throws exception', () async {
      // arrange
      when(() => mockRepository.getUser(any()))
          .thenAnswer((_) async => const Left(ServerFailure('Server error')));

      // act
      final result = await usecase('1');

      // assert
      expect(result, const Left(ServerFailure('Server error')));
      verify(() => mockRepository.getUser('1')).called(1);
    });
  });
}
```

#### Test de Widget con Golden Tests:
```dart
// test/widgets/user_card_test.dart
void main() {
  group('UserCard', () {
    const testUser = User(
      id: '1',
      name: 'John Doe',
      email: 'john@example.com',
      avatarUrl: 'https://example.com/avatar.jpg',
    );

    testWidgets('should display user information correctly', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserCard(
              user: testUser,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('john@example.com'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);

      await tester.tap(find.byType(UserCard));
      expect(tapped, isTrue);
    });

    testWidgets('should render correctly in different themes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: UserCard(user: testUser, onTap: () {}),
          ),
        ),
      );

      await expectLater(
        find.byType(UserCard),
        matchesGoldenFile('user_card_light.png'),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: UserCard(user: testUser, onTap: () {}),
          ),
        ),
      );

      await expectLater(
        find.byType(UserCard),
        matchesGoldenFile('user_card_dark.png'),
      );
    });
  });
}
```

#### Test de Integración End-to-End:
```dart
// integration_test/user_flow_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('User Flow Integration Tests', () {
    testWidgets('complete user management flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verificar pantalla inicial
      expect(find.text('Users'), findsOneWidget);

      // Navegar a crear usuario
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Completar formulario
      await tester.enterText(
        find.byKey(const Key('name_field')),
        'John Doe',
      );
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'john@example.com',
      );

      // Guardar usuario
      await tester.tap(find.byKey(const Key('save_button')));
      await tester.pumpAndSettle();

      // Verificar que el usuario fue creado
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('john@example.com'), findsOneWidget);

      // Editar usuario
      await tester.tap(find.byKey(const Key('edit_button')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('name_field')),
        'Jane Doe',
      );

      await tester.tap(find.byKey(const Key('save_button')));
      await tester.pumpAndSettle();

      // Verificar cambios
      expect(find.text('Jane Doe'), findsOneWidget);
    });
  });
}
```

### Mocking y Datos de Prueba

```dart
// test/helpers/test_data.dart
class TestData {
  static const user1 = User(
    id: '1',
    name: 'John Doe',
    email: 'john@example.com',
    avatarUrl: 'https://example.com/john.jpg',
  );

  static const user2 = User(
    id: '2',
    name: 'Jane Smith',
    email: 'jane@example.com',
    avatarUrl: 'https://example.com/jane.jpg',
  );

  static const users = [user1, user2];

  static List<User> generateUsers(int count) {
    return List.generate(count, (index) => User(
      id: '$index',
      name: 'User $index',
      email: 'user$index@example.com',
      avatarUrl: 'https://example.com/user$index.jpg',
    ));
  }
}

// test/helpers/mock_dependencies.dart
class MockDependencies {
  static void setupMocks() {
    GetIt.instance.reset();
    
    GetIt.instance.registerLazySingleton<UserRepository>(
      () => MockUserRepository(),
    );
    
    GetIt.instance.registerLazySingleton(
      () => GetUser(GetIt.instance()),
    );
  }
}
```

---

## 🔐 Seguridad y Privacidad

### Gestión Segura de Datos

#### Almacenamiento seguro:
```dart
// services/secure_storage_service.dart
class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: IOSAccessibility.first_unlock_this_device,
    ),
  );

  static Future<void> storeToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }

  static Future<void> storeUserData(User user) async {
    final userData = jsonEncode(user.toJson());
    await _storage.write(key: 'user_data', value: userData);
  }

  static Future<User?> getUserData() async {
    final userData = await _storage.read(key: 'user_data');
    if (userData != null) {
      final Map<String, dynamic> json = jsonDecode(userData);
      return User.fromJson(json);
    }
    return null;
  }

  static Future<void> clearAllData() async {
    await _storage.deleteAll();
  }
}
```

#### Validación de entrada:
```dart
// utils/input_validator.dart
class InputValidator {
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'El email es requerido';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(email)) {
      return 'Ingresa un email válido';
    }
    
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'La contraseña es requerida';
    }
    
    if (password.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'La contraseña debe contener al menos una mayúscula';
    }
    
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'La contraseña debe contener al menos una minúscula';
    }
    
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'La contraseña debe contener al menos un número';
    }
    
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'La contraseña debe contener al menos un carácter especial';
    }
    
    return null;
  }

  static String? validatePhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) {
      return 'El número de teléfono es requerido';
    }
    
    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    
    if (!phoneRegex.hasMatch(phone.replaceAll(RegExp(r'[^\d+]'), ''))) {
      return 'Ingresa un número de teléfono válido';
    }
    
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }
    return null;
  }

  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.length < minLength) {
      return '$fieldName debe tener al menos $minLength caracteres';
    }
    return null;
  }
}
```

### Network Security

```dart
// services/api_service.dart
class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://api.example.com',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _setupInterceptors();
  }

  void _setupInterceptors() {
    // Logging interceptor (solo en debug)
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: false,
        responseHeader: false,
      ));
    }

    // Auth interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await SecureStorageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await _handleUnauthorized();
        }
        handler.next(error);
      },
    ));

    // Certificate pinning (recomendado para producción)
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) {
        // Implementar certificate pinning aquí
        return _verifyCertificate(cert, host);
      };
      return client;
    };
  }

  bool _verifyCertificate(X509Certificate cert, String host) {
    // Implementar verificación de certificado
    // Por ejemplo, verificar el SHA-256 fingerprint
    const expectedFingerprint = 'YOUR_EXPECTED_FINGERPRINT';
    return cert.sha256 == expectedFingerprint;
  }

  Future<void> _handleUnauthorized() async {
    await SecureStorageService.deleteToken();
    // Navegar a login
    // GetIt.instance<NavigationService>().navigateToLogin();
  }
}
```

---

## 🌐 Desarrollo Multiplataforma

### Platform-Specific Code

```dart
// utils/platform_utils.dart
class PlatformUtils {
  static bool get isAndroid => Platform.isAndroid;
  static bool get isIOS => Platform.isIOS;
  static bool get isWeb => kIsWeb;
  static bool get isMobile => isAndroid || isIOS;
  static bool get isDesktop => Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  static String get platformName {
    if (isAndroid) return 'Android';
    if (isIOS) return 'iOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isLinux) return 'Linux';
    if (Platform.isMacOS) return 'macOS';
    if (kIsWeb) return 'Web';
    return 'Unknown';
  }

  static Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  static Future<void> shareText(String text) async {
    if (isMobile) {
      await Share.share(text);
    } else {
      // Fallback para desktop/web
      await Clipboard.setData(ClipboardData(text: text));
    }
  }
}

// widgets/platform_adaptive_widget.dart
class PlatformAdaptiveButton extends StatelessWidget {
  const PlatformAdaptiveButton({
    required this.onPressed,
    required this.child,
    super.key,
  });

  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoButton(
        onPressed: onPressed,
        child: child,
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      child: child,
    );
  }
}

class PlatformAdaptiveDialog extends StatelessWidget {
  const PlatformAdaptiveDialog({
    required this.title,
    required this.content,
    required this.actions,
    super.key,
  });

  final String title;
  final String content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: actions,
      );
    }

    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: actions,
    );
  }

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => PlatformAdaptiveDialog(
        title: title,
        content: content,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}
```

### Navigation 2.0 Implementation

```dart
// navigation/app_router.dart
class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: kDebugMode,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
        routes: [
          GoRoute(
            path: 'profile',
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/users/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return UserDetailPage(userId: id);
        },
      ),
    ],
    redirect: (context, state) {
      final isLoggedIn = context.read<AuthBloc>().state is AuthAuthenticated;
      final isLoginRoute = state.matchedLocation == '/login';
      
      if (!isLoggedIn && !isLoginRoute) {
        return '/login';
      }
      
      if (isLoggedIn && isLoginRoute) {
        return '/home';
      }
      
      return null;
    },
  );

  static GoRouter get router => _router;
}

// navigation/navigation_service.dart
class NavigationService {
  static void goTo(String path) {
    AppRouter.router.go(path);
  }

  static void push(String path) {
    AppRouter.router.push(path);
  }

  static void pop() {
    AppRouter.router.pop();
  }

  static void pushReplacement(String path) {
    AppRouter.router.pushReplacement(path);
  }
}
```

---

## 🛠️ Mantenimiento de Código

### Code Generation

#### Build Runner Setup:
```yaml
# pubspec.yaml
dev_dependencies:
  build_runner: ^2.4.7
  json_serializable: ^6.7.1
  freezed: ^2.4.6
  json_annotation: ^4.8.1
```

```dart
// models/user.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String name,
    required String email,
    @Default(true) bool isActive,
    DateTime? createdAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

### Documentation Standards

```dart
/// Servicio para manejar operaciones de usuario
/// 
/// Este servicio proporciona métodos para:
/// - Obtener usuarios del servidor
/// - Crear nuevos usuarios
/// - Actualizar información de usuarios existentes
/// - Eliminar usuarios
/// 
/// Ejemplo de uso:
/// ```dart
/// final userService = UserService();
/// final users = await userService.getUsers();
/// ```
class UserService {
  /// Crea una nueva instancia de [UserService]
  /// 
  /// [dio] Cliente HTTP personalizado (opcional)
  UserService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  /// Obtiene todos los usuarios del servidor
  /// 
  /// Retorna una lista de [User] o lanza [ApiException] en caso de error.
  /// 
  /// Throws:
  /// - [ApiException] cuando hay errores de red o del servidor
  /// - [FormatException] cuando la respuesta no es válida
  Future<List<User>> getUsers() async {
    // Implementation...
  }

  /// Obtiene un usuario específico por su ID
  /// 
  /// [userId] ID único del usuario a obtener
  /// 
  /// Retorna el [User] encontrado o lanza [ApiException] si no existe.
  /// 
  /// Example:
  /// ```dart
  /// final user = await userService.getUserById('123');
  /// print(user.name);
  /// ```
  Future<User> getUserById(String userId) async {
    // Implementation...
  }
}
```

### Error Handling Patterns

```dart
// core/error/failures.dart
abstract class Failure extends Equatable {
  const Failure(this.message);
  
  final String message;

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

// core/error/exceptions.dart
class ServerException implements Exception {
  const ServerException(this.message);
  final String message;
}

class NetworkException implements Exception {
  const NetworkException(this.message);
  final String message;
}

class CacheException implements Exception {
  const CacheException(this.message);
  final String message;
}

// utils/result.dart
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

class Error<T> extends Result<T> {
  const Error(this.failure);
  final Failure failure;
}

// Extension methods para Result
extension ResultExtension<T> on Result<T> {
  bool get isSuccess => this is Success<T>;
  bool get isError => this is Error<T>;
  
  T? get data => isSuccess ? (this as Success<T>).data : null;
  Failure? get failure => isError ? (this as Error<T>).failure : null;
  
  R fold<R>(R Function(Failure) onError, R Function(T) onSuccess) {
    return switch (this) {
      Success<T>() => onSuccess((this as Success<T>).data),
      Error<T>() => onError((this as Error<T>).failure),
    };
  }
}
```

### Logging System

```dart
// utils/logger.dart
class Logger {
  static const String _logTag = 'MyApp';
  
  static void debug(String message, [String? tag]) {
    if (kDebugMode) {
      developer.log(
        message,
        name: tag ?? _logTag,
        level: 500,
      );
    }
  }

  static void info(String message, [String? tag]) {
    developer.log(
      message,
      name: tag ?? _logTag,
      level: 800,
    );
  }

  static void warning(String message, [String? tag]) {
    developer.log(
      message,
      name: tag ?? _logTag,
      level: 900,
    );
  }

  static void error(String message, [Object? error, StackTrace? stackTrace, String? tag]) {
    developer.log(
      message,
      name: tag ?? _logTag,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void logApiRequest(String method, String url, Map<String, dynamic>? data) {
    if (kDebugMode) {
      debug('API Request: $method $url ${data != null ? '\nData: $data' : ''}');
    }
  }

  static void logApiResponse(String url, int statusCode, dynamic data) {
    if (kDebugMode) {
      debug('API Response: $url - Status: $statusCode\nData: $data');
    }
  }
}
```

---

## 🎯 Checklist de Calidad Final

### ✅ Arquitectura
- [ ] Clean Architecture implementada
- [ ] Separación clara de responsabilidades
- [ ] Inyección de dependencias configurada
- [ ] Patrones de diseño apropiados

### ✅ Código
- [ ] Convenciones de nomenclatura seguidas
- [ ] Documentación completa (dartdoc)
- [ ] Manejo de errores robusto
- [ ] Logging implementado

### ✅ UI/UX
- [ ] Material 3 Design System
- [ ] Responsive design
- [ ] Animaciones suaves
- [ ] Accesibilidad considerada

### ✅ Performance
- [ ] Widgets optimizados con const
- [ ] Listas virtualizadas
- [ ] Imágenes optimizadas
- [ ] Memory leaks verificados

### ✅ Testing
- [ ] >90% code coverage
- [ ] Tests unitarios
- [ ] Tests de widgets
- [ ] Tests de integración
- [ ] Golden tests

### ✅ Seguridad
- [ ] Almacenamiento seguro
- [ ] Validación de entrada
- [ ] Certificate pinning
- [ ] Datos sensibles protegidos

### ✅ Multiplataforma
- [ ] Código específico de plataforma aislado
- [ ] Widgets adaptativos
- [ ] Navigation 2.0
- [ ] Responsive para desktop

### ✅ Mantenimiento
- [ ] Code generation configurado
- [ ] CI/CD pipeline
- [ ] Documentación actualizada
- [ ] Versionado semántico

---

Siguiendo estas mejores prácticas basadas en los ejemplos oficiales de Flutter, crearás aplicaciones robustas, mantenibles y de calidad profesional que destacarán en el ecosistema Flutter/Dart.

¡Feliz desarrollo! 🚀
import 'package:args/args.dart';
import 'base_command.dart';
import '../utils/logger.dart';

/// Comando para generar ejemplos de código
class ExampleCommand extends Command {
  late final ArgParser _argParser;

  static const Map<String, String> _examples = {
    'widget': 'Widget básico con mejores prácticas',
    'bloc': 'Implementación BLoC completa',
    'model': 'Modelo de datos con serialización',
    'service': 'Servicio con manejo de errores',
    'test': 'Test unitario comprehensivo',
    'screen': 'Pantalla completa con navegación',
  };

  ExampleCommand() {
    _argParser = ArgParser()
      ..addFlag(
        'list',
        abbr: 'l',
        negatable: false,
        help: 'Lista todos los ejemplos disponibles',
      )
      ..addFlag(
        'help',
        abbr: 'h',
        negatable: false,
        help: 'Muestra ayuda para este comando',
      );
  }

  @override
  String get name => 'example';

  @override
  String get description => 'Genera ejemplos de código con mejores prácticas';

  @override
  ArgParser get argParser => _argParser;

  @override
  Future<void> run(ArgResults argResults) async {
    if (argResults['help'] as bool) {
      showHelp();
      return;
    }

    if (argResults['list'] as bool) {
      _listExamples();
      return;
    }

    final args = argResults.rest;
    if (args.isEmpty) {
      _listExamples();
      Logger.info('\nUsa: fpd-toolkit example <tipo> para ver un ejemplo específico');
      return;
    }

    final exampleType = args[0];
    await _showExample(exampleType);
  }

  void _listExamples() {
    Logger.info('📋 Ejemplos de código disponibles:\n');
    
    for (final entry in _examples.entries) {
      Logger.info('  ${entry.key.padRight(10)} - ${entry.value}');
    }

    Logger.info('\nEjemplos de uso:');
    Logger.info('  fpd-toolkit example widget');
    Logger.info('  fpd-toolkit example bloc');
    Logger.info('  fpd-toolkit example test');
  }

  Future<void> _showExample(String exampleType) async {
    if (!_examples.containsKey(exampleType)) {
      Logger.error('❌ Ejemplo no encontrado: $exampleType');
      Logger.info('Ejemplos disponibles: ${_examples.keys.join(', ')}');
      return;
    }

    Logger.info('📝 Ejemplo: ${_examples[exampleType]}\n');

    switch (exampleType) {
      case 'widget':
        _showWidgetExample();
        break;
      case 'bloc':
        _showBlocExample();
        break;
      case 'model':
        _showModelExample();
        break;
      case 'service':
        _showServiceExample();
        break;
      case 'test':
        _showTestExample();
        break;
      case 'screen':
        _showScreenExample();
        break;
    }
  }

  void _showWidgetExample() {
    print('''
// lib/widgets/user_card.dart
import 'package:flutter/material.dart';

/// Widget que muestra información de un usuario
class UserCard extends StatelessWidget {
  /// Crea una nueva instancia de [UserCard]
  const UserCard({
    required this.user,
    this.onTap,
    super.key,
  });

  /// Usuario a mostrar
  final User user;

  /// Callback ejecutado al tocar la tarjeta
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(user.avatarUrl),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Uso:
UserCard(
  user: user,
  onTap: () => Navigator.pushNamed(context, '/user-details'),
)
''');
  }

  void _showBlocExample() {
    print('''
// lib/blocs/user/user_event.dart
import 'package:equatable/equatable.dart';

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

class UpdateUserEvent extends UserEvent {
  const UpdateUserEvent(this.user);

  final User user;

  @override
  List<Object> get props => [user];
}

// lib/blocs/user/user_state.dart
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

// lib/blocs/user/user_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc({
    required UserRepository userRepository,
  })  : _userRepository = userRepository,
        super(UserInitial()) {
    on<GetUserEvent>(_onGetUser);
    on<UpdateUserEvent>(_onUpdateUser);
  }

  final UserRepository _userRepository;

  Future<void> _onGetUser(
    GetUserEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    
    try {
      final user = await _userRepository.getUserById(event.userId);
      emit(UserLoaded(user));
    } catch (e) {
      emit(UserError('Failed to load user: \$e'));
    }
  }

  Future<void> _onUpdateUser(
    UpdateUserEvent event,
    Emitter<UserState> emit,
  ) async {
    if (state is! UserLoaded) return;

    emit(UserLoading());
    
    try {
      final updatedUser = await _userRepository.updateUser(event.user);
      emit(UserLoaded(updatedUser));
    } catch (e) {
      emit(UserError('Failed to update user: \$e'));
    }
  }
}

// Uso en widget:
BlocBuilder<UserBloc, UserState>(
  builder: (context, state) {
    return switch (state) {
      UserInitial() => const SizedBox(),
      UserLoading() => const CircularProgressIndicator(),
      UserLoaded() => UserCard(user: state.user),
      UserError() => Text('Error: \${state.message}'),
    };
  },
)
''');
  }

  void _showModelExample() {
    print('''
// lib/models/user.dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

/// Representa un usuario en el sistema
@JsonSerializable()
class User extends Equatable {
  /// Crea una nueva instancia de [User]
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    this.isActive = true,
    this.createdAt,
  });

  /// Identificador único del usuario
  final String id;

  /// Nombre completo del usuario
  final String name;

  /// Dirección de email del usuario
  final String email;

  /// URL del avatar del usuario
  @JsonKey(name: 'avatar_url')
  final String avatarUrl;

  /// Indica si el usuario está activo
  @JsonKey(name: 'is_active')
  final bool isActive;

  /// Fecha de creación del usuario
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  /// Crea una copia del usuario con campos actualizados
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convierte el usuario a JSON
  Map<String, dynamic> toJson() => _\$UserToJson(this);

  /// Crea un usuario desde JSON
  factory User.fromJson(Map<String, dynamic> json) => _\$UserFromJson(json);

  @override
  List<Object?> get props => [id, name, email, avatarUrl, isActive, createdAt];

  @override
  String toString() {
    return 'User(id: \$id, name: \$name, email: \$email, '
        'avatarUrl: \$avatarUrl, isActive: \$isActive, createdAt: \$createdAt)';
  }
}

// Para generar el código:
// dart run build_runner build
''');
  }

  void _showServiceExample() {
    print('''
// lib/services/user_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';

/// Excepción personalizada para errores de API
class ApiException implements Exception {
  const ApiException(this.message, [this.statusCode]);

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException: \$message';
}

/// Servicio para manejar operaciones de usuario
class UserService {
  /// Crea una nueva instancia de [UserService]
  UserService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;
  static const String _baseUrl = 'https://api.example.com';

  /// Obtiene todos los usuarios
  /// 
  /// Throws [ApiException] en caso de error
  Future<List<User>> getUsers() async {
    try {
      final response = await _dio.get('\$_baseUrl/users');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) => User.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ApiException(
          'Failed to fetch users',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ApiException(_handleDioError(e));
    } catch (e) {
      throw ApiException('Unexpected error: \$e');
    }
  }

  /// Obtiene un usuario por ID
  Future<User> getUserById(String id) async {
    try {
      final response = await _dio.get('\$_baseUrl/users/\$id');
      
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
      throw ApiException('Unexpected error: \$e');
    }
  }

  /// Crea un nuevo usuario
  Future<User> createUser(User user) async {
    try {
      final response = await _dio.post(
        '\$_baseUrl/users',
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
      throw ApiException('Unexpected error: \$e');
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
        return 'Server error: \${e.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      case DioExceptionType.connectionError:
        return 'Connection error';
      case DioExceptionType.unknown:
        return 'Unknown error: \${e.message}';
      default:
        return 'Network error';
    }
  }
}
''');
  }

  void _showTestExample() {
    print('''
// test/services/user_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';

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

        when(() => mockDio.get(any())).thenAnswer(
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
        verify(() => mockDio.get('https://api.example.com/users')).called(1);
      });

      test('should throw ApiException when API call fails', () async {
        // Arrange
        when(() => mockDio.get(any())).thenThrow(
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

      test('should throw ApiException when status code is not 200', () async {
        // Arrange
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            data: {},
            statusCode: 500,
            requestOptions: RequestOptions(path: '/users'),
          ),
        );

        // Act & Assert
        expect(
          () => userService.getUsers(),
          throwsA(
            isA<ApiException>().having(
              (e) => e.statusCode,
              'statusCode',
              equals(500),
            ),
          ),
        );
      });
    });

    group('getUserById', () {
      test('should return user when found', () async {
        // Arrange
        const userId = '1';
        const mockUser = {
          'id': '1',
          'name': 'John Doe',
          'email': 'john@example.com',
          'avatar_url': 'https://example.com/avatar.jpg',
          'is_active': true,
        };

        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            data: mockUser,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/users/\$userId'),
          ),
        );

        // Act
        final result = await userService.getUserById(userId);

        // Assert
        expect(result, isA<User>());
        expect(result.id, equals('1'));
        expect(result.name, equals('John Doe'));
        verify(() => mockDio.get('https://api.example.com/users/1')).called(1);
      });
    });
  });
}
''');
  }

  void _showScreenExample() {
    print('''
// lib/screens/user_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pantalla que muestra la lista de usuarios
class UserListScreen extends StatelessWidget {
  /// Crea una nueva instancia de [UserListScreen]
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserListBloc()..add(const LoadUsersEvent()),
      child: const UserListView(),
    );
  }
}

class UserListView extends StatelessWidget {
  const UserListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<UserListBloc>().add(const RefreshUsersEvent());
            },
          ),
        ],
      ),
      body: BlocBuilder<UserListBloc, UserListState>(
        builder: (context, state) {
          return switch (state) {
            UserListInitial() => const Center(
                child: CircularProgressIndicator(),
              ),
            UserListLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            UserListLoaded() => _buildUserList(context, state.users),
            UserListError() => _buildErrorState(context, state.message),
          };
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateUser(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildUserList(BuildContext context, List<User> users) {
    if (users.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No hay usuarios disponibles'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<UserListBloc>().add(const RefreshUsersEvent());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: UserCard(
              user: user,
              onTap: () => _navigateToUserDetails(context, user),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error: \$message',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<UserListBloc>().add(const LoadUsersEvent());
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  void _navigateToUserDetails(BuildContext context, User user) {
    Navigator.pushNamed(
      context,
      '/user-details',
      arguments: user,
    );
  }

  void _navigateToCreateUser(BuildContext context) {
    Navigator.pushNamed(context, '/create-user').then((result) {
      if (result == true) {
        context.read<UserListBloc>().add(const RefreshUsersEvent());
      }
    });
  }
}
''');
  }

  @override
  void showHelp() {
    print('''
$description

Uso: fpd-toolkit example [tipo] [opciones]

Tipos de ejemplo:
''');
    
    for (final entry in _examples.entries) {
      print('  ${entry.key.padRight(10)} - ${entry.value}');
    }

    print('''

Opciones:
  -l, --list           Lista todos los ejemplos disponibles
  -h, --help           Muestra esta ayuda

Ejemplos:
  fpd-toolkit example widget
  fpd-toolkit example bloc
  fpd-toolkit example test
  fpd-toolkit example --list

Cada ejemplo muestra:
  📝 Código completo con documentación
  🏗️ Estructura recomendada
  ✅ Mejores prácticas aplicadas
  🧪 Patrones de testing cuando aplica
''');
  }
}
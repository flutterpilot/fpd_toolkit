---
title: Architecture & Structure
description: This rule defines best practices for architecture and project structure in Flutter and Dart, based on official examples. It promotes using Clean Architecture, ensuring clear separation of responsibilities between data, domain, and presentation layers, and implementing dependency injection using the GetIt pattern.
globs:
  - '**/lib/**'
  - '**/pubspec.yaml'
  - '**/analysis_options.yaml'
alwaysApply: false
---
# Architecture & Structure

## Clean Architecture Pattern

Based on the `compass_app` example, implement a clean and scalable architecture:

```
lib/
├── core/                     # Shared functionalities
│   ├── constants/
│   ├── errors/
│   ├── utils/
│   └── extensions/
├── data/                     # Data layer
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/                   # Business logic
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/             # UI and state
│   ├── pages/
│   ├── widgets/
│   ├── providers/
│   └── theme/
└── services/                 # External services
```

## Separation of Responsibilities

### ✅ Correct - Clear Separation
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

## Dependency Injection

### Provider Pattern with GetIt (based on official examples)
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
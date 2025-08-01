---
title: State Management
description: This rule details best practices for state management in Flutter, based on official recommendations. It provides a detailed implementation of the BLoC pattern for complex state and a simpler example using the Provider pattern for less complex scenarios, allowing developers to choose the right approach for their needs.
alwaysApply: false
globs:
  - '**/lib/**'
  - '**/pubspec.yaml'
  - '**/analysis_options.yaml'
---
# State Management

## BLoC Pattern (Recommended by Flutter Team)

### Implementation based on official examples:
```dart
// Events
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

// States
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
        return 'Server error';
      case NetworkFailure:
        return 'Connection error';
      default:
        return 'Unexpected error';
    }
  }
}
```

## Provider Pattern (For simple cases)

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

// Usage in widget
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
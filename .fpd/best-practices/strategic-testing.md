---
title: Strategic Testing
description: This rule provides a strategic guide to testing in Flutter and Dart. It covers the complete testing pyramid with examples of exhaustive unit tests, widget tests including golden file testing for UI consistency, and end-to-end integration tests for user flows. It also includes best practices for managing mock data and dependencies.
alwaysApply: false
title: Strategic Testing
globs:
  - '**/test/**'
  - '**/integration_test/**'
  - '**/lib/**'
  - '**/pubspec.yaml'
---
# Strategic Testing

## Complete Testing Pyramid

### Exhaustive Unit Test:
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

### Widget Test with Golden Tests:
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

### End-to-End Integration Test:
```dart
// integration_test/user_flow_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('User Flow Integration Tests', () {
    testWidgets('complete user management flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify initial screen
      expect(find.text('Users'), findsOneWidget);

      // Navigate to create user
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Complete form
      await tester.enterText(
        find.byKey(const Key('name_field')),
        'John Doe',
      );
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'john@example.com',
      );

      // Save user
      await tester.tap(find.byKey(const Key('save_button')));
      await tester.pumpAndSettle();

      // Verify user was created
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('john@example.com'), findsOneWidget);

      // Edit user
      await tester.tap(find.byKey(const Key('edit_button')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('name_field')),
        'Jane Doe',
      );

      await tester.tap(find.byKey(const Key('save_button')));
      await tester.pumpAndSettle();

      // Verify changes
      expect(find.text('Jane Doe'), findsOneWidget);
    });
  });
}
```

## Mocking and Test Data

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
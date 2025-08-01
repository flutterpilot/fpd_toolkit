---
title: Multiplatform Development
description: This rule provides best practices for multiplatform development in Flutter. It demonstrates how to manage platform-specific code, create adaptive widgets that adjust to different operating systems (iOS, Android, etc.), and implement a robust navigation system using Navigation 2.0 with the go_router package.
alwaysApply: false
globs:
  - '**/lib/**'
  - '**/pubspec.yaml'
  - '**/android/**'
  - '**/ios/**'
  - '**/web/**'
  - '**/macos/**'
  - '**/windows/**'
  - '**/linux/**'
---
# Multiplatform Development

## Platform-Specific Code

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
      // Fallback for desktop/web
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
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
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

## Navigation 2.0 Implementation

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
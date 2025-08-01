---
title: Security and Privacy
description: This rule outlines best practices for ensuring security and privacy in Flutter and Dart applications. It covers secure data management using flutter_secure_storage, robust input validation techniques, and network security measures such as using Dio interceptors for auth and implementing certificate pinning.
alwaysApply: false
globs:
  - '**/lib/**'
  - '**/pubspec.yaml'
  - '**/analysis_options.yaml'
---
# Security and Privacy

## Secure Data Management

### Secure Storage:
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

### Input Validation:
```dart
// utils/input_validator.dart
class InputValidator {
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(email)) {
      return 'Enter a valid email';
    }
    
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    
    return null;
  }

  static String? validatePhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) {
      return 'Phone number is required';
    }
    
    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    
    if (!phoneRegex.hasMatch(phone.replaceAll(RegExp(r'[^\d+]'), ''))) {
      return 'Enter a valid phone number';
    }
    
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }
}
```

## Network Security

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
    // Logging interceptor (only in debug)
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

    // Certificate pinning (recommended for production)
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) {
        // Implement certificate pinning here
        return _verifyCertificate(cert, host);
      };
      return client;
    };
  }

  bool _verifyCertificate(X509Certificate cert, String host) {
    // Implement certificate verification
    // For example, check the SHA-256 fingerprint
    const expectedFingerprint = 'YOUR_EXPECTED_FINGERPRINT';
    return cert.sha256 == expectedFingerprint;
  }

  Future<void> _handleUnauthorized() async {
    await SecureStorageService.deleteToken();
    // Navigate to login
    // GetIt.instance<NavigationService>().navigateToLogin();
  }
}
``` 
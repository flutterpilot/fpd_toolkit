/// Utilidades de validación
class Validator {
  /// Valida si un nombre de paquete es válido
  static bool isValidPackageName(String name) {
    final regex = RegExp(r'^[a-z][a-z0-9_]*$');
    return regex.hasMatch(name) && 
           !name.startsWith('_') && 
           !name.endsWith('_') && 
           !name.contains('__');
  }

  /// Valida si un email es válido
  static bool isValidEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }

  /// Valida si una versión sigue semantic versioning
  static bool isValidSemanticVersion(String version) {
    final regex = RegExp(r'^\d+\.\d+\.\d+(\+\d+)?(-[\w\.-]+)?$');
    return regex.hasMatch(version);
  }

  /// Valida si una URL es válida
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// Convierte texto a PascalCase
  static String toPascalCase(String input) {
    return input.split('_').map((word) => 
      word[0].toUpperCase() + word.substring(1)).join('');
  }

  /// Convierte texto a camelCase
  static String toCamelCase(String input) {
    final pascalCase = toPascalCase(input);
    return pascalCase[0].toLowerCase() + pascalCase.substring(1);
  }

  /// Convierte texto a snake_case
  static String toSnakeCase(String input) {
    return input
        .replaceAllMapped(RegExp(r'[A-Z]'), (match) => '_${match.group(0)?.toLowerCase()}')
        .replaceAll(RegExp(r'^_'), '')
        .toLowerCase();
  }
}
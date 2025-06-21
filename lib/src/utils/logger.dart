import 'dart:io';

/// Sistema de logging para el CLI
class Logger {
  static bool _verbose = false;

  /// Habilita logging verbose
  static void enableVerbose() {
    _verbose = true;
  }

  /// Log de información general
  static void info(String message) {
    print(message);
  }

  /// Log de éxito
  static void success(String message) {
    print('\x1B[32m$message\x1B[0m');
  }

  /// Log de advertencia
  static void warning(String message) {
    print('\x1B[33m$message\x1B[0m');
  }

  /// Log de error
  static void error(String message) {
    stderr.writeln('\x1B[31m$message\x1B[0m');
  }

  /// Log verbose (solo si está habilitado)
  static void verbose(String message) {
    if (_verbose) {
      print('\x1B[36m[VERBOSE] $message\x1B[0m');
    }
  }

  /// Log de debug
  static void debug(String message) {
    if (_verbose) {
      print('\x1B[35m[DEBUG] $message\x1B[0m');
    }
  }
}
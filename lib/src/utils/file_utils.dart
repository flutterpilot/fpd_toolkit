import 'dart:io';

/// Utilidades para manejo de archivos
class FileUtils {
  /// Crea un directorio si no existe
  static Future<Directory> ensureDirectoryExists(String path) async {
    final directory = Directory(path);
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  /// Copia un archivo
  static Future<void> copyFile(String sourcePath, String destinationPath) async {
    final sourceFile = File(sourcePath);
    final destinationFile = File(destinationPath);
    
    await ensureDirectoryExists(destinationFile.parent.path);
    await sourceFile.copy(destinationPath);
  }

  /// Lee un archivo como string
  static Future<String> readFileAsString(String path) async {
    final file = File(path);
    if (!file.existsSync()) {
      throw FileSystemException('File not found', path);
    }
    return await file.readAsString();
  }

  /// Escribe contenido a un archivo
  static Future<void> writeStringToFile(String path, String content) async {
    final file = File(path);
    await ensureDirectoryExists(file.parent.path);
    await file.writeAsString(content);
  }

  /// Verifica si un archivo existe
  static bool fileExists(String path) {
    return File(path).existsSync();
  }

  /// Verifica si un directorio existe
  static bool directoryExists(String path) {
    return Directory(path).existsSync();
  }

  /// Obtiene la extensión de un archivo
  static String getFileExtension(String path) {
    final file = File(path);
    final name = file.path.split('/').last;
    final lastDot = name.lastIndexOf('.');
    
    if (lastDot == -1 || lastDot == name.length - 1) {
      return '';
    }
    
    return name.substring(lastDot + 1);
  }

  /// Lista archivos en un directorio con filtro opcional
  static List<File> listFiles(String directoryPath, {String? extension}) {
    final directory = Directory(directoryPath);
    if (!directory.existsSync()) {
      return [];
    }

    final files = directory
        .listSync(recursive: false)
        .whereType<File>()
        .toList();

    if (extension != null) {
      return files.where((file) => getFileExtension(file.path) == extension).toList();
    }

    return files;
  }

  /// Obtiene el tamaño de un archivo en bytes
  static int getFileSize(String path) {
    final file = File(path);
    if (!file.existsSync()) {
      return 0;
    }
    return file.lengthSync();
  }

  /// Formatea el tamaño de archivo en formato legible
  static String formatFileSize(int bytes) {
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }
}
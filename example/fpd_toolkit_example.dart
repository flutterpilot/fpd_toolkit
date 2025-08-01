/// Example of using FPD Toolkit programmatically
library fpd_toolkit_example;

import 'package:fpd_toolkit/fpd_toolkit.dart';

Future<void> main() async {
  // Example 1: Create a new Dart package
  print('Creating a new Dart package...');
  await FpdToolkit.run([
    'create',
    'package',
    'my_awesome_package',
    '--description',
    'An awesome Dart package created with FPD Toolkit'
  ]);

  // Example 2: Create a Flutter application
  print('Creating a Flutter application...');
  await FpdToolkit.run([
    'create',
    'app',
    'my_flutter_app',
    '--description',
    'A Flutter application created with FPD Toolkit'
  ]);

  // Example 3: Create a Flutter plugin
  print('Creating a Flutter plugin...');
  await FpdToolkit.run([
    'create',
    'plugin',
    'my_flutter_plugin',
    '--platforms',
    'android,ios',
    '--description',
    'A cross-platform Flutter plugin'
  ]);

  // Example 4: Validate a package
  print('Validating the created package...');
  await FpdToolkit.run([
    'validate',
    'my_awesome_package'
  ]);

  // Example 5: Access development guides
  print('Accessing development guides...');
  await FpdToolkit.run([
    'guide',
    'best-practices',
    'architecture-structure'
  ]);

  // Example 6: View code examples
  print('Viewing code examples...');
  await FpdToolkit.run([
    'example',
    'widget'
  ]);

  print('All examples completed successfully!');
}
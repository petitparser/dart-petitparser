import 'environment.dart';

/// Lambda function type in the Dart world.
typedef Lambda = dynamic Function(Environment env, dynamic args);

/// Type of printer function to output text on the console.
typedef Printer = void Function(Object? object);

/// Default printer to output text on the console.
Printer printer = print;

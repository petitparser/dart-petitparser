library petitparser.example.bin.prolog;

import 'dart:convert';
import 'dart:io';

import 'package:example/prolog.dart';

/// Entry point for the command line interpreter.
void main(List<String> arguments) {
  // parse arguments
  final rules = StringBuffer();
  for (final option in arguments) {
    if (option.startsWith('-')) {
      if (option == '-?') {
        print('${Platform.executable} prolog.dart rules...');
        exit(0);
      } else {
        print('Unknown option: $option');
        exit(1);
      }
    } else {
      final file = File(option);
      if (file.existsSync()) {
        rules.writeln(file.readAsStringSync());
      } else {
        print('File not found: $option');
        exit(2);
      }
    }
  }

  // evaluation context
  final db = Database.parse(rules.toString());

  // the read-eval loop
  stdout.write('?- ');
  stdin
      .transform(systemEncoding.decoder)
      .transform(const LineSplitter())
      .map((query) => Term.parse(query))
      .asyncMap((goal) async {
    await db.query(goal).forEach(stdout.writeln);
  }).forEach((each) => stdout.write('?- '));
}

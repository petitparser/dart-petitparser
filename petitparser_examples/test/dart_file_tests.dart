/// This test-case automatically generates various tests from Dart source
/// code. Unfortunately the parser is currently unable to parse most of
/// these files.
import 'dart:io';

import 'package:petitparser/petitparser.dart';
import 'package:petitparser_examples/dart.dart';
import 'package:test/test.dart';

final grammar = DartGrammarDefinition().build();

Function accept(Parser parser) => (input) => parser.parse(input).isSuccess;

void generateTests(String title, Directory root) {
  group(title, () {
    final files = root
        .listSync(recursive: true)
        .where((file) => file is File && file.path.endsWith('.dart'))
        .cast<File>();
    for (final file in files) {
      test(file.path.substring(root.path.length + 1), () {
        expect(file.readAsStringSync(), accept(grammar));
      });
    }
  });
}

void main() {
  generateTests('PetitParser', Directory.current);
}

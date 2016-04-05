/// This test-case automatically generates various tests from Dart source
/// code. Unfortunately the parser is currently unable to parse most of
/// these files.
library petitparser.test.dart_file_test;

import 'dart:io';

import 'package:test/test.dart';

import 'package:petitparser/dart.dart';
import 'package:petitparser/test.dart';

void generateTests(DartGrammar dart, String title, Directory root) {
  group(title, () {
    root.listSync(recursive: true)
        .where((file) => file is File && file.path.endsWith('.dart'))
        .map((file) => file as File)
        .forEach((File file) {
          test(file.path.substring(root.path.length + 1), () {
            expect(file.readAsStringSync(), accept(dart));
          });
        });
  });
}

void main() {
  var dart = new DartGrammar();
  generateTests(dart, 'Dart SDK', new Directory('packages'));
  generateTests(dart, 'PetitParser', Directory.current);
}

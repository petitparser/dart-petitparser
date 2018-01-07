/// This test-case automatically generates various tests from Dart source
/// code. Unfortunately the parser is currently unable to parse most of
/// these files.
library petitparser.test.dart_file_test;

import 'dart:io';

import 'package:petitparser/test.dart';
import 'package:test/test.dart';

import '../example/dart/dart.dart';

final grammar = new DartGrammar();

void generateTests(String title, Directory root) {
  group(title, () {
    var files = root.listSync(recursive: true)
        .where((file) => file is File && file.path.endsWith('.dart'))
        .map((file) => file as File);
    for (var file in files) {
      test(file.path.substring(root.path.length + 1), () {
        expect(file.readAsStringSync(), accept(grammar));
      });
    }
  });
}

void main() {
  generateTests('PetitParser', Directory.current);
}

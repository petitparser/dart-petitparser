/**
 * This test-case automatically generates various tests from Dart source
 * code. Unfortunately the parser is currently unable to parse most of
 * these files.
 */
library dart_file_test;

import 'dart:io';
import 'package:petitparser/dart.dart';
import 'package:petitparser/test.dart';
import 'package:unittest/unittest.dart';

void generateTests(DartGrammar dart, String title, String path) {
  group(title, () {
    new Directory(path)
      .listSync(recursive: true, followLinks: false)
      .where((file) => file is File && file.path.endsWith('.dart'))
      .forEach((File file) {
        test(file.path, () {
          var source = new StringBuffer();
          file.openRead()
              .transform(SYSTEM_ENCODING.decoder)
              .listen(
                  (part) => source.write(part),
                  onDone: expectAsync(() {
                    expect(source.toString(), accept(dart));
                  }),
                  onError: fail);
        });
      });
  });
}

void main() {
  var dart = new DartGrammar();
  //generateTests(dart, 'Dart SDK', '/Applications/Dart/dart-sdk');
  generateTests(dart, 'PetitParser', Directory.current.path);
}

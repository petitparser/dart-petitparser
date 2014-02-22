library all_test;

import 'package:unittest/unittest.dart';
import 'core_test.dart' as core_test;
import 'dart_test.dart' as dart_test;
import 'json_test.dart' as json_test;
import 'lisp_test.dart' as lisp_test;
import 'smalltalk_test.dart' as smalltalk_test;
import 'test_test.dart' as test_test;
import 'xml_test.dart' as xml_test;

void main() {
  group('PetitParser', core_test.main);
  group('Dart', dart_test.main);
  group('JSON', json_test.main);
  group('Lisp', lisp_test.main);
  group('Smalltalk', smalltalk_test.main);
  group('Test', test_test.main);
  group('XML', xml_test.main);
}

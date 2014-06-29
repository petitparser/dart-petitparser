library all_test;

import 'package:unittest/unittest.dart';

import 'core_test.dart' as core_test;
import 'dart_test.dart' as dart_test;
import 'debug_test.dart' as debug_test;
import 'json_test.dart' as json_test;
import 'lisp_test.dart' as lisp_test;
import 'reflection_test.dart' as reflection_test;
import 'smalltalk_test.dart' as smalltalk_test;
import 'test_test.dart' as test_test;

void main() {
  testCore(new Configuration());
}

void testCore(Configuration config) {
  unittestConfiguration = config;
  groupSep = ' - ';

  group('PetitParser', core_test.main);
  group('Dart', dart_test.main);
  group('Debug', debug_test.main);
  group('JSON', json_test.main);
  group('Lisp', lisp_test.main);
  group('Reflection', reflection_test.main);
  group('Smalltalk', smalltalk_test.main);
  group('Test', test_test.main);
}

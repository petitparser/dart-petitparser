library petitparser.example.test.all_test;

import 'package:test/test.dart';

import 'dart_test.dart' as dart_test;
import 'json_test.dart' as json_test;
import 'lisp_test.dart' as lisp_test;
import 'prolog_test.dart' as prolog_test;
import 'smalltalk_test.dart' as smalltalk_test;

void main() {
  group('dart', dart_test.main);
  group('json', json_test.main);
  group('lisp', lisp_test.main);
  group('prolog', prolog_test.main);
  group('smalltalk', smalltalk_test.main);
}

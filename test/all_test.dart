// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

library all_test;

import 'package:unittest/unittest.dart';
import 'core_test.dart' as core_test;
import 'json_test.dart' as json_test;
import 'lisp_test.dart' as lisp_test;
import 'xml_test.dart' as xml_test;

void main() {
  group('PetitParser', core_test.main);
  group('JSON', json_test.main);
  group('LISP', xml_test.main);
  group('XML', lisp_test.main);
}

// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

library all_tests;

import 'package:unittest/unittest.dart';
import 'json_tests.dart' as json;
import 'lisp_tests.dart' as lisp;
import 'core_tests.dart' as core;
import 'xml_tests.dart' as xml;

void main() {
  group('PetitParser', core.main);
  group('JSON', json.main);
  group('XML', xml.main);
  group('LISP', lisp.main);
}

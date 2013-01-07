// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

library all_tests;

import 'package:petitparser/petitparser.dart';
import 'package:unittest/unittest.dart';
import 'json_tests.dart' as json;
import 'lisp_tests.dart' as lisp;
import 'petitparser_tests.dart' as petitparser;
import 'xml_tests.dart' as xml;

void main() {
  group('PetitParser', petitparser.main);
  group('JSON', json.main);
  group('XML', xml.main);
  group('LISP', lisp.main);
}

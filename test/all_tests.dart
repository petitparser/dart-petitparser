// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

library all_tests;

import 'package:unittest/unittest.dart';
import 'package:petitparser/petitparser.dart';

import 'petitparser_tests.dart' as petitparser;
import 'json_tests.dart' as json;
import 'xml_tests.dart' as xml;
import 'lisp_tests.dart' as lisp;

void main() {
  group('PetitParser', petitparser.main);
  group('JSON', json.main);
  group('XML', xml.main);
  group('LISP', lisp.main);
}
// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

#library('all_tests');

#import('package:unittest/unittest.dart');
#import('package:petitparser/petitparser.dart');

#import('petitparser_tests.dart', prefix: 'petitparser');
#import('json_tests.dart', prefix: 'json');
#import('xml_tests.dart', prefix: 'xml');
#import('lisp_tests.dart', prefix: 'lisp');

void main() {
  group('PetitParser', petitparser.main);
  group('JSON', json.main);
  group('XML', xml.main);
  group('LISP', lisp.main);
}

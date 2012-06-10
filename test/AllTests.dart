// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

#library('AllTests');

#import('/Applications/Dart/dart-sdk/lib/unittest/unittest.dart');

#import('PetitParserTests.dart', prefix: 'petitparser');
#import('JsonTests.dart', prefix: 'json');
#import('XmlTests.dart', prefix: 'xml');

void main() {
  group('PetitParser -', petitparser.main);
  group('JSON -', json.main);
  group('XML -', xml.main);
}
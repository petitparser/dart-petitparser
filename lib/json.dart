// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

#library('json');

#import('dart:math');

#import('package:petitparser/petitparser.dart');

#source('src/json/grammar.dart');
#source('src/json/parser.dart');

final ESCAPE_TABLE = const {
  '\\': '\\',
  '/': '/',
  '"': '"',
  'b': '\b',
  'f': '\f',
  'n': '\n',
  'r': '\r',
  't': '\t'
};

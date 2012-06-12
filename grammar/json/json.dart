// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

#library('json');

#import('../../lib/petitparser.dart');

#source('json_grammar.dart');
#source('json_parser.dart');

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

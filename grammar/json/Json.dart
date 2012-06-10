// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

#library('Json');

#import('../../lib/PetitParser.dart');

#source('JsonGrammar.dart');
#source('JsonParser.dart');

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

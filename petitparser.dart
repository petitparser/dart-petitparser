// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

#library('petitparser');

#import('dart:core');

#source('context.dart');
#source('parser.dart');

void main() {
  Parser a = PredicateParser.any();
  Parser b = PredicateParser.expect("x");
  Parser c = PredicateParser.range("a", "f");

  Parser d = c | b | a;
  Parser e = d >> (each) => print(each);

  Result r = e.parse(new Context("a"));

  print(r);
}
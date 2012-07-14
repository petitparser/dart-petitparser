// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

#library('lisp');

#import('../../lib/petitparser.dart');
#import('dart:io');

#source('cells.dart');
#source('environment.dart');
#source('grammar.dart');
#source('parser.dart');

void process(Parser parser, Environment environment, InputStream input, OutputStream output) {
  new StringInputStream(input)
    .onLine((String line) {
      output.writeString(parser.parse(line).getResult().eval(environment));
    });
}

void main() {
  process(new LispParser(), new Environment(), stdin, stdout);
}
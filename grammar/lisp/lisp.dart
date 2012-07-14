// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

#library('lisp');

#import('../../lib/petitparser.dart');
#import('dart:io');

#source('cells.dart');
#source('environment.dart');
#source('grammar.dart');
#source('parser.dart');

void process(Parser parser, Environment environment, InputStream input, OutputStream output) {
  var lines = new StringInputStream(input);
  lines.onLine(() {
      output.writeString(parser.parse(lines.readLine()).getResult().eval(environment));
    });
}

void main() {
  process(new LispParser(), new Environment(), stdin, stdout);
}
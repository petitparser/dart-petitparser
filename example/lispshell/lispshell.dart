// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

library lispshell;

import 'dart:io';
import 'dart:async';
import 'package:petitparser/petitparser.dart';
import 'package:petitparser/lisp.dart';

/** Read, evaluate, print loop. */
void evalInteractive(LispParser parser, Environment env,
                     Stream<String> input, IOSink output,
                     IOSink error) {
  input.listen((String line) {
    try {
      output.addString('${evalString(parser, env, line)}\n');
    } on ParserError catch(exception) {
      error.addString(exception.toString());
    }
  });
}

/** Entry point for the command line interpreter. */
void main() {

  // default options
  var standardLibrary = true;
  var interactiveMode = false;
  var files = new List();

  // parse arguments
  var options = new Options();
  for (var option in options.arguments) {
    if (option.startsWith('-') && files.isEmpty) {
      if (option == '-n') {
        standardLibrary = false;
      } else if (option == '-i') {
        interactiveMode = true;
      } else if (option == '-?') {
        print('${options.executable} lisp.dart -n -i [files]');
        print(' -i enforces the interactive mode');
        print(' -n does not load the standard library');
        exit(0);
      } else {
        print('Unknown option: $option');
        exit(1);
      }
    } else {
      var file = new File(option);
      if (file.existsSync()) {
        files.add(file);
      } else {
        print('File not found: $option');
        exit(2);
      }
    }
  }

  // evaluation context
  var parser = new LispParser();
  var environment = Natives.importNatives(new Environment());

  // process standard library
  if (standardLibrary) {
    environment = Natives.importStandard(environment.create());
  }

  // create empty context
  environment = environment.create();

  // process files given as argument
  files.forEach((file) {
    evalString(parser, environment, file.readAsTextSync());
  });

  // process console input
  if (interactiveMode || files.isEmpty) {
    var input = stdin
        .transform(new StringDecoder())
        .transform(new LineTransformer());
    evalInteractive(parser, environment, input, stdout, stderr);
  }
}

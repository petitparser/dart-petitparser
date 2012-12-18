// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

library lispshell;

import 'dart:io';
import 'package:petitparser/lisp.dart';

/** Read, evaluate, print loop. */
void evalInteractive(LispParser parser, Environment env, InputStream input, OutputStream output) {
  var stream = new StringInputStream(input);
  stream.onLine = () {
    output.writeString('${evalString(parser, env, stream.readLine())}\n');
  };
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
    evalInteractive(parser, environment, stdin, stdout);
  }
}
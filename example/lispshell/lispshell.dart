library petitparser.example.lispshell;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:petitparser/petitparser.dart';

import '../lisp/lisp.dart';

/// Read, evaluate, print loop.
void evalInteractive(Parser parser, Environment env, Stream<String> input,
    IOSink output, IOSink error) {
  output.write('>> ');
  input.listen((String line) {
    try {
      output.writeln('=> ${evalString(parser, env, line)}');
    } on ParserError catch (exception) {
      error.writeln('Parser error: ${exception.toString()}');
    } on Error catch (exception) {
      error.writeln(exception.toString());
    }
    output.write('>> ');
  });
}

/// Entry point for the command line interpreter.
void main(List<String> arguments) {
  // default options
  var standardLibrary = true;
  var interactiveMode = false;
  var files = <File>[];

  // parse arguments
  for (var option in arguments) {
    if (option.startsWith('-') && files.isEmpty) {
      if (option == '-n') {
        standardLibrary = false;
      } else if (option == '-i') {
        interactiveMode = true;
      } else if (option == '-?') {
        print('${Platform.executable} lisp.dart -n -i [files]');
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
  Environment environment = new NativeEnvironment();

  // add additional primitives
  environment.define(new Name('exit'), (Environment env, Cons args) {
    exit(args == null ? 0 : args.head);
  });
  environment.define(new Name('sleep'), (Environment env, Cons args) {
    sleep(new Duration(milliseconds: args.head));
  });

  // process standard library
  if (standardLibrary) {
    environment = new StandardEnvironment(environment);
  }

  // create empty context
  environment = environment.create();

  // process files given as argument
  for (var file in files) {
    evalString(lispParser, environment, file.readAsStringSync());
  }

  // process console input
  if (interactiveMode || files.isEmpty) {
    var input = stdin
        .transform(systemEncoding.decoder)
        .transform(const LineSplitter());
    evalInteractive(lispParser, environment, input, stdout, stderr);
  }
}

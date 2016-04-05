library petitparser.example.lispshell;

import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:petitparser/petitparser.dart';
import 'package:petitparser/lisp.dart';

/// Read, evaluate, print loop.
void evalInteractive(Parser parser, Environment env, Stream<String> input,
    IOSink output, IOSink error) {
  output.write('>> ');
  input.listen((String line) {
    try {
      output.writeln('=> ${evalString(parser, env, line)}');
    } on ParserError catch (exception) {
      error.writeln('Parser error: ' + exception.toString());
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
  var files = new List();

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
  var environment = Natives.import(new Environment());

  // add additional primitives
  environment.define(new Name('exit'), (env, args) => exit(args == null ? 0 : args.head));
  environment.define(new Name('sleep'), (env, args) => sleep(new Duration(milliseconds: args.head)));

  // process standard library
  if (standardLibrary) {
    environment = Standard.import(environment.create());
  }

  // create empty context
  environment = environment.create();

  // process files given as argument
  files.forEach((file) {
    evalString(lispParser, environment, file.readAsStringSync());
  });

  // process console input
  if (interactiveMode || files.isEmpty) {
    var input = stdin
        .transform(SYSTEM_ENCODING.decoder as StreamTransformer<List<int>, String>)
        .transform(new LineSplitter() as Converter<String, List<String>>);
    evalInteractive(lispParser, environment, input as Stream<String>, stdout, stderr);
  }
}

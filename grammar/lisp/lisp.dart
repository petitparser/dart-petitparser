// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

#library('lisp');

#import('dart:builtin');
#import('dart:io');

#import('../../lib/petitparser.dart');
#import('lisplib.dart');

void main() {

  // default options
  bool standardLibrary = true;
  bool interactiveMode = false;
  List files = new List();

  // parse arguments
  var options = new Options();
  for (var option in options.arguments) {
    if (option.startsWith('-') && files.isEmpty()) {
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
  var environment = new RootEnvironment();

  // process standard library
  if (standardLibrary) {
    var file = new File('/Users/renggli/Programming/dart/PetitParser/grammar/lisp/default.lisp');
    evalString(parser, environment, file.readAsTextSync());
  }

  // process files given as argument
  files.forEach((file) {
    evalString(parser, environment, file.readAsTextSync());
  });

  // process console input
  if (interactiveMode || files.isEmpty()) {
    evalInteractive(parser, environment, stdin, stdout);
  }
}

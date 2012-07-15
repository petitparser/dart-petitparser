// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

#library('lisp');

#import('dart:builtin');
#import('dart:io');

#import('../../lib/petitparser.dart');
#import('lisplib.dart');

class _NullStream implements OutputStream {
  bool write(List<int> buffer, [bool copyBuffer]) { return true; }
  bool writeFrom(List<int> buffer, [int offset, int len]) { return true; }
  bool writeString(String value, [Encoding encoding]) { return true; }
  void flush() { }
  void close() { }
  void destroy() { }
  void set onNoPendingWrites(void callback()) { }
  void set onClosed(void callback()) { }
  void set onError(void callback(e)) { }
}

void process(Parser parser, Environment environment, InputStream input, OutputStream output) {
  var stream = new StringInputStream(input);
  stream.onLine = () {
    var line = stream.readLine();
    var cell = parser.parse(line).getResult();
    var result = cell.evaluate(environment);
    output.writeString('${result}\n');
  };
}

void mainWithOptions(Options options) {

  // default options
  bool standardLibrary = true;
  bool interactiveMode = false;
  List files = new List();

  // parse arguments
  for (var option in options.arguments) {
    if (option.startsWith('-') && files.isEmpty()) {
      if (option == '-n') {
        standardLibrary = false;
      } else if (option == '-i') {
        interactiveMode = true;
      } else if (option == '-?') {
        print('${options.executable} -n -i [files]');
        print('  -i enforces the interactive mode');
        print('  -n does not load the standard library');
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
  var environment = new Environment();
  var nullout = new _NullStream();

  // process standard library
  if (standardLibrary) {
    var stream = new File('default.lisp').openInputStream();
    process(parser, environment, stream, nullout);
    stream.close();
  }

  // process files given as argument
  files.forEach((each) {
    var stream = each.openInputStream();
    process(parser, environment, stream, nullout);
    stream.close();
  });

  // process console input
  if (interactiveMode || files.isEmpty()) {
    process(parser, environment, stdin, stdout);
  }

>>>>>>> - getting basic REPL working
}

void main() {
  mainWithOptions(new Options());
}

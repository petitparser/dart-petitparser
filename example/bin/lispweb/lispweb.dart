library petitparser.example.lispweb;

import 'dart:html';

import 'package:example/lisp.dart';

void inspect(Element element, Environment environment) {
  final buffer = StringBuffer();
  while (environment != null) {
    buffer.write('<ul>');
    for (var symbol in environment.keys) {
      buffer.write('<li><b>$symbol</b>: ${environment[symbol]}</li>');
    }
    buffer.write('</ul>');
    buffer.write('<hr/>');
    environment = environment.owner;
  }
  element.innerHtml = buffer.toString();
}

void main() {
  final root = NativeEnvironment();
  final standard = StandardEnvironment(root);
  final environment = standard.create();

  final TextAreaElement input = querySelector('#input');
  final TextAreaElement output = querySelector('#output');
  final DivElement transcript = querySelector('#transcript');
  final DivElement inspector = querySelector('#inspector');

  printer = (object) {
    transcript.appendText(object.toString());
    transcript.append(document.createElement('br'));
  };
  querySelector('#evaluate').onClick.listen((event) {
    transcript.innerHtml = '';
    final result = evalString(lispParser, environment, input.value);
    output.value = result.toString();
    inspect(inspector, environment);
  });
  inspect(inspector, environment);
}

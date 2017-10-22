library petitparser.example.lispweb;

import 'dart:html';

import '../lisp/lisp.dart';

void inspect(Element element, Environment environment) {
  var buffer = new StringBuffer();
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
  final root = new NativeEnvironment();
  final standard = new StandardEnvironment(root);
  final environment = standard.create();

  final input = querySelector('#input') as TextAreaElement;
  final output = querySelector('#output') as TextAreaElement;
  final transcript = querySelector('#transcript');
  final inspector = querySelector('#inspector');

  printer = (Object object) {
    transcript.appendText(object.toString());
    transcript.append(document.createElement('br'));
  };
  querySelector('#evaluate').onClick.listen((event) {
    transcript.innerHtml = '';
    Object result = evalString(lispParser, environment, input.value);
    output.value = result.toString();
    inspect(inspector, environment);
  });
  inspect(inspector, environment);
}

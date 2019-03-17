library petitparser.example.web.lisp;

import 'dart:html';

import 'package:example/lisp.dart';

final TextAreaElement input = querySelector('#input');
final output = querySelector('#output');
final console = querySelector('#console');
final environment = querySelector('#environment');

void main() {
  final root = NativeEnvironment();
  final standard = StandardEnvironment(root);
  final user = standard.create();

  printer = (object) {
    console.appendText(object.toString());
    console.append(document.createElement('br'));
  };
  querySelector('#evaluate').onClick.listen((event) {
    output.innerHtml = 'Evaluating...';
    output.classes.clear();
    console.innerHtml = '';
    try {
      final result = evalString(lispParser, user, input.value);
      output.text = result.toString();
    } on Object catch (exception) {
      output.text = exception.toString();
      output.classes.add('error');
    }
    inspect(environment, user);
  });
  inspect(environment, user);
}

void inspect(Element element, Environment environment) {
  final buffer = StringBuffer();
  while (environment != null) {
    if (environment.keys.isNotEmpty) {
      buffer.write('<ul>');
      for (final symbol in environment.keys) {
        var object = environment[symbol];
        if (object is Function) {
          object = '($symbol ...)';
        }
        buffer.write('<li><b>$symbol</b>: $object</li>');
      }
      buffer.write('</ul>');
      buffer.write('<hr/>');
    }
    environment = environment.owner;
  }
  element.innerHtml = buffer.toString();
}

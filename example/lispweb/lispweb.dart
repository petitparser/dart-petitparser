library petitparser.example.lispweb;

import 'dart:html';

import '../lisp/lisp.dart';

void inspect(Element element, Environment environment) {
  var result = '';
  while (environment != null) {
    result = '$result<ul>';
    for (var symbol in environment.keys) {
      result = '$result<li><b>$symbol</b>: ${environment[symbol]}</li>';
    }
    result = '$result</ul>';
    result = '$result<hr/>';
    environment = environment.owner;
  }
  element.innerHtml = result;
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
    transcript.append(document.createElement("br"));
  };
  querySelector('#evaluate').onClick.listen((event) {
    transcript.innerHtml = '';
    Object result = evalString(lispParser, environment, input.value);
    output.value = result.toString();
    inspect(inspector, environment);
  });
  inspect(inspector, environment);
}

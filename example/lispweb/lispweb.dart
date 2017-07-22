library petitparser.example.lispweb;

import 'dart:html';

import '../lisp/lisp.dart';

void inspector(Element element, Environment environment) {
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
  var root = new NativeEnvironment();
  var standard = new StandardEnvironment(root);
  var environment = standard.create();

  var input = querySelector('#input') as TextAreaElement;
  var output = querySelector('#output') as TextAreaElement;

  querySelector('#evaluate').onClick.listen((event) {
    Object result = evalString(lispParser, environment, input.value);
    output.value = result.toString();
    inspector(querySelector('#inspector'), environment);
  });
  inspector(querySelector('#inspector'), environment);
}

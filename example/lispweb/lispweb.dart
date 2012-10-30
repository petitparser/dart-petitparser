// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

library lispweb;

import 'dart:html';
import 'package:petitparser/lisp.dart';
import 'package:petitparser/petitparser.dart';

void inspector(Element element, Environment environment) {
  var result = '';
  while (environment != null) {
    result = '$result<ul>';
    for (var symbol in environment.keys) {
      result = '$result<li><b>$symbol</b>: ${environment[symbol]}</li>';
    }
    result = '$result</ul>';
    result = '$result<hr/>';
    environment = environment.parent;
  }
  element.innerHTML = result;
}

main() {
  Parser parser = new LispParser();
  Environment root = new RootEnvironment().create();
  evalString(parser, root, Natives.standardLibrary);
  Environment environment = root.create();

  TextAreaElement input = query('#input');
  TextAreaElement output = query('#output');

  query('#evaluate').on.click.add((event) {
    var result = evalString(parser, environment, input.value);
    output.innerHTML = result.toString();
    inspector(query('#inspector'), environment);
  });
  inspector(query('#inspector'), environment);
}
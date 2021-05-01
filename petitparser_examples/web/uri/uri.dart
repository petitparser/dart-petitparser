import 'dart:html';

import 'package:petitparser/petitparser.dart';
import 'package:petitparser_examples/uri.dart';

final parser = uri.end();

final input = querySelector('#input')! as InputElement;
final output = querySelector('#output')! as ParagraphElement;

void update() {
  final result = uri.parse(input.value ?? '');
  if (result.isSuccess) {
    output.innerHtml = '''
    <dl>
      <dt>Scheme:</dt>
      <dd>${result.value[#scheme]}</dd>
      
      <dt>Authority:</dt>
      <dd>${result.value[#authority]}</dd>
      
      <dt>Path:</dt>
      <dd>${result.value[#path]}</dd>
      
      <dt>Query:</dt>
      <dd>${result.value[#query]}</dd>
      
      <dt>Fragment:</dt>
      <dd>${result.value[#fragment]}</dd>
    </dl>
    ''';
  } else {
    output.innerHtml = '''
    <span class="error">
      Error at ${result.position}: ${result.message}
    </span>
    ''';
  }
}

void main() {
  input.onInput.listen((event) => update());
  input.value = window.location.href;
  update();
}

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
    <table>
      <tr>
        <th>Scheme:</th>
        <td>${result.value[#scheme]}</td>
      </tr>
      <tr>  
        <th>Authority:</th>
        <td>${result.value[#authority]}</td>
      </tr>
      <tr class="sub">  
        <th>Username:</th>
        <td>${result.value[#username]}</td>
      </tr>
      <tr class="sub">  
        <th>Password:</th>
        <td>${result.value[#password]}</td>
      </tr>
      <tr class="sub">  
        <th>Hostname:</th>
        <td>${result.value[#hostname]}</td>
      </tr>
      <tr class="sub">  
        <th>Port:</th>
        <td>${result.value[#port]}</td>
      </tr>
      <tr>  
        <th>Path:</th>
        <td>${result.value[#path]}</td>
      </tr>
      <tr>  
        <th>Query:</th>
        <td>${result.value[#query]}</td>
      </tr>
      <tr>  
        <th>Fragment:</th>
        <td>${result.value[#fragment]}</td>
      </tr>
    </table>
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

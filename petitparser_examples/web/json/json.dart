import 'dart:convert' as convert;
import 'dart:html';

import 'package:petitparser_examples/json.dart';

final parser = JsonParserDefinition().build();

void execute(
  String value,
  Element timingElement,
  Element outputElement,
  dynamic Function(String value) parse,
) {
  Object? result;
  var count = 0, elapsed = 0;
  final watch = Stopwatch()..start();
  while (elapsed < 100000) {
    try {
      result = parse(value);
    } on Exception catch (exception) {
      result = exception;
    }
    elapsed = watch.elapsedMicroseconds;
    count++;
  }
  final timing = (elapsed / count).round();

  timingElement.innerText = '$timingμs';
  if (result is Exception) {
    outputElement.classes.add('error');
    outputElement.innerText =
        result is FormatException ? result.message : result.toString();
  } else {
    outputElement.classes.remove('error');
    outputElement.innerText = convert.json.encode(result);
  }
}

final input = querySelector('#input')! as TextAreaElement;
final action = querySelector('#action')! as SubmitButtonInputElement;

final timingCustom = querySelector('#timing .custom')!;
final timingNative = querySelector('#timing .native')!;
final outputCustom = querySelector('#output .custom')!;
final outputNative = querySelector('#output .native')!;

void update() {
  final value = input.value ?? '';
  execute(
    value,
    timingCustom,
    outputCustom,
    (input) => parser.parse(input).value,
  );
  execute(
    value,
    timingNative,
    outputNative,
    (input) => convert.json.decode(input),
  );
}

void main() {
  action.onClick.listen((event) => update());
  update();
}

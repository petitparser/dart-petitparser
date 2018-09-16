library petitparser.example.core_benchmark;

import 'dart:convert' as convert;

import 'package:petitparser/petitparser.dart';

import 'package:example/json.dart';

double benchmark(Function function,
    [int warmUp = 1000, int milliseconds = 2500]) {
  var count = 0;
  var elapsed = 0;
  final watch = Stopwatch();
  while (warmUp-- > 0) {
    function();
  }
  watch.start();
  while (elapsed < milliseconds) {
    function();
    elapsed = watch.elapsedMilliseconds;
    count++;
  }
  return elapsed / count;
}

// Character tests

Function charTest(List<String> inputs, Parser parser) {
  return () {
    for (var i = 0; i < inputs.length; i++) {
      parser.parse(inputs[i]);
    }
  };
}

final List<String> characters =
    List.generate(256, (value) => String.fromCharCode(value));

// String tests

Function stringTest(String input, Parser parser) {
  return () {
    parser.parse(input);
  };
}

final string = characters.join();

// JSON tests

final json = JsonParser();

const jsonEvent =
    '{"type": "change", "eventPhase": 2, "bubbles": true, "cancelable": true, '
    '"timeStamp": 0, "CAPTURING_PHASE": 1, "AT_TARGET": 2, "BUBBLING_PHASE": 3, "isTrusted": '
    'true, "MOUSEDOWN": 1, "MOUSEUP": 2, "MOUSEOVER": 4, "MOUSEOUT": 8, "MOUSEMOVE": 16, '
    '"MOUSEDRAG": 32, "CLICK": 64, "DBLCLICK": 128, "KEYDOWN": 256, "KEYUP": 512, "KEYPRESS": '
    '1024, "DRAGDROP": 2048, "FOCUS": 4096, "BLUR": 8192, "SELECT": 16384, "CHANGE": 32768, '
    '"RESET": 65536, "SUBMIT": 131072, "SCROLL": 262144, "LOAD": 524288, "UNLOAD": 1048576, '
    '"XFER_DONE": 2097152, "ABORT": 4194304, "ERROR": 8388608, "LOCATE": 16777216, "MOVE": '
    '33554432, "RESIZE": 67108864, "FORWARD": 134217728, "HELP": 268435456, "BACK": 536870912, '
    '"TEXT": 1073741824, "ALT_MASK": 1, "CONTROL_MASK": 2, "SHIFT_MASK": 4, "META_MASK": 8}';

// All benchmarks

final Map<String, Function> benchmarks = {
  // char tests
  'any()': charTest(characters, any()),
  "anyOf('uncopyrightable')": charTest(characters, anyOf('uncopyrightable')),
  "char('a')": charTest(characters, char('a')),
  'digit()': charTest(characters, digit()),
  'letter()': charTest(characters, letter()),
  'lowercase()': charTest(characters, lowercase()),
  "noneOf('uncopyrightable')": charTest(characters, noneOf('uncopyrightable')),
  "pattern('^a')": charTest(characters, pattern('^a')),
  "pattern('^a-cx-zA-CX-Z1-37-9')":
      charTest(characters, pattern('^a-cx-zA-CX-Z1-37-9')),
  "pattern('^a-z')": charTest(characters, pattern('^a-z')),
  "pattern('^acegik')": charTest(characters, pattern('^acegik')),
  "pattern('a')": charTest(characters, pattern('a')),
  "pattern('a-cx-zA-CX-Z1-37-9')":
      charTest(characters, pattern('a-cx-zA-CX-Z1-37-9')),
  "pattern('a-z')": charTest(characters, pattern('a-z')),
  "pattern('acegik')": charTest(characters, pattern('acegik')),
  "range('a', 'z')": charTest(characters, range('a', 'z')),
  'uppercase()': charTest(characters, uppercase()),
  'whitespace()': charTest(characters, whitespace()),
  'word()': charTest(characters, word()),

  // combinator tests
  'star()': stringTest(string, any().star()),
  'starLazy()': stringTest(string, any().starLazy(failure())),
  'starGreedy()': stringTest(string, any().starGreedy(failure())),
  'plus()': stringTest(string, any().plus()),
  'plusLazy()': stringTest(string, any().plusLazy(failure())),
  'plusGreedy()': stringTest(string, any().plusGreedy(failure())),
  'or()': stringTest(string, failure().or(any()).star()),
  'seq()':
      stringTest(string, SequenceParser(List.filled(string.length, any()))),

  // json tests
  'JSON.decode()': () => convert.json.decode(jsonEvent),
  'JsonParser()': () => json.parse(jsonEvent).value
};

void main() {
  for (var name in benchmarks.keys) {
    print('$name\t${benchmark(benchmarks[name])}');
  }
}

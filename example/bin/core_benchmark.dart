library petitparser.example.core_benchmark;

import 'package:example/json.dart';
import 'package:petitparser/petitparser.dart';

import 'benchmark.dart';

// Character tests

Function charTest(List<String> inputs, Parser parser) {
  return (fast) {
    if (fast) {
      return () {
        for (var i = 0; i < inputs.length; i++) {
          parser.accept(inputs[i]);
        }
      };
    } else {
      return () {
        for (var i = 0; i < inputs.length; i++) {
          parser.parse(inputs[i]);
        }
      };
    }
  };
}

final List<String> characters =
    List.generate(256, (value) => String.fromCharCode(value));

// String tests

Function stringTest(String input, Parser parser, {bool fast = false}) {
  return (fast) {
    if (fast) {
      return () => parser.accept(input);
    } else {
      return () => parser.parse(input).isSuccess;
    }
  };
}

final String string = characters.join();

// JSON tests

final JsonParser json = JsonParser();

const String jsonEvent =
    '{"type": "change", "eventPhase": 2, "bubbles": true, "cancelable": true, '
    '"timeStamp": 0, "CAPTURING_PHASE": 1, "AT_TARGET": 2, '
    '"BUBBLING_PHASE": 3, "isTrusted": true, "MOUSEDOWN": 1, "MOUSEUP": 2, '
    '"MOUSEOVER": 4, "MOUSEOUT": 8, "MOUSEMOVE": 16, "MOUSEDRAG": 32, '
    '"CLICK": 64, "DBLCLICK": 128, "KEYDOWN": 256, "KEYUP": 512, '
    '"KEYPRESS": 1024, "DRAGDROP": 2048, "FOCUS": 4096, "BLUR": 8192, '
    '"SELECT": 16384, "CHANGE": 32768, "RESET": 65536, "SUBMIT": 131072, '
    '"SCROLL": 262144, "LOAD": 524288, "UNLOAD": 1048576, '
    '"XFER_DONE": 2097152, "ABORT": 4194304, "ERROR": 8388608, '
    '"LOCATE": 16777216, "MOVE": 33554432, "RESIZE": 67108864, '
    '"FORWARD": 134217728, "HELP": 268435456, "BACK": 536870912, '
    '"TEXT": 1073741824, "ALT_MASK": 1, "CONTROL_MASK": 2, '
    '"SHIFT_MASK": 4, "META_MASK": 8}';

// All benchmarks

final Map<String, Function> benchmarks = {
  // char tests
  'any()': charTest(characters, any()),
  "anyOf('uncopyrightable')": charTest(characters, anyOf('uncopyrightable')),
  "char('a')": charTest(characters, char('a')),
  'digit()': charTest(characters, digit()),
  'failure()': charTest(characters, failure()),
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
  'optional()': charTest(characters, any().optional()),
  'and()': charTest(characters, any().and()),
  'not()': charTest(characters, any().not()),
  'neg()': charTest(characters, any().neg()),
  'flatten()': charTest(characters, any().flatten()),
  'token()': charTest(characters, any().token()),
  'trim()': charTest(characters, any().trim()),
  'end()': charTest(characters, any().end()),
  'set()': charTest(characters, any().settable()),
  'map()': charTest(characters, any().map((_) => null)),
  'cast()': charTest(characters, any().cast()),
  'castList()': charTest(characters, any().star().castList()),
  'pick()': charTest(characters, any().star().pick(0)),
  'permute()': charTest(characters, any().star().permute([0])),
  'or()': charTest(characters, failure().or(any()).star()),

  // repeater tests
  'star()': stringTest(string, any().star()),
  'starGreedy()': stringTest(string, any().starGreedy(failure())),
  'starLazy()': stringTest(string, any().starLazy(failure())),
  'plus()': stringTest(string, any().plus()),
  'plusGreedy()': stringTest(string, any().plusGreedy(failure())),
  'plusLazy()': stringTest(string, any().plusLazy(failure())),
  'times()': stringTest(string, any().times(string.length)),
  'seq()': stringTest(
    string,
    SequenceParser(List.filled(string.length, any())),
  ),

  // composite
  'JsonParser()': (fast) {
    if (fast) {
      return () => json.fastParseOn(jsonEvent, 0);
    } else {
      return () => json.parse(jsonEvent);
    }
  },
};

void main() {
  print('Name\tparseOn\tfastParseOn\tChange');
  for (var name in benchmarks.keys) {
    final parseOnTime = benchmark(benchmarks[name](false));
    final fastParseOnTime = benchmark(benchmarks[name](true));
    print('$name\t'
        '${parseOnTime.toStringAsFixed(6)}\t'
        '${fastParseOnTime.toStringAsFixed(6)}\t'
        '${(100 * parseOnTime / fastParseOnTime).round() - 100}%');
  }
}

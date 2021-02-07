import 'package:characters/characters.dart';
import 'package:petitparser/petitparser.dart';
import 'package:petitparser_examples/json.dart';

import 'benchmark.dart';

class Benchmark {
  final String name;
  final Parser parser;
  final List<String> inputs;

  Benchmark(this.name, this.parser, this.inputs);

  double measure({bool isFast = false, bool isCharacters = false}) {
    final buffers = isCharacters
        ? inputs
            .map((input) => Buffer.fromCharacters(input.characters))
            .toList(growable: false)
        : inputs
            .map((input) => Buffer.fromString(input))
            .toList(growable: false);
    if (isFast) {
      return benchmark(() {
        for (var i = 0; i < buffers.length; i++) {
          parser.accept(buffers[i]);
        }
      });
    } else {
      return benchmark(() {
        for (var i = 0; i < buffers.length; i++) {
          parser.parse(buffers[i]);
        }
      });
    }
  }
}

final List<String> characters =
    List.generate(0xff, (value) => String.fromCharCode(value));

final String string = characters.join();

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

final List<Benchmark> benchmarks = [
  // char tests
  Benchmark("anyOf('uncopyrightable')", anyOf('uncopyrightable'), characters),
  Benchmark("char('a')", char('a'), characters),
  Benchmark("noneOf('uncopyrightable')", noneOf('uncopyrightable'), characters),
  Benchmark("pattern('^a')", pattern('^a'), characters),
  Benchmark("pattern('^a-cx-zA-CX-Z1-37-9')", pattern('^a-cx-zA-CX-Z1-37-9'),
      characters),
  Benchmark("pattern('^a-z')", pattern('^a-z'), characters),
  Benchmark("pattern('^acegik')", pattern('^acegik'), characters),
  Benchmark("pattern('a')", pattern('a'), characters),
  Benchmark("pattern('a-cx-zA-CX-Z1-37-9')", pattern('a-cx-zA-CX-Z1-37-9'),
      characters),
  Benchmark("pattern('a-z')", pattern('a-z'), characters),
  Benchmark("pattern('acegik')", pattern('acegik'), characters),
  Benchmark("range('a', 'z')", range('a', 'z'), characters),
  Benchmark('any()', any(), characters),
  Benchmark('digit()', digit(), characters),
  Benchmark('failure()', failure(), characters),
  Benchmark('letter()', letter(), characters),
  Benchmark('lowercase()', lowercase(), characters),
  Benchmark('uppercase()', uppercase(), characters),
  Benchmark('whitespace()', whitespace(), characters),
  Benchmark('word()', word(), characters),

  // combinator tests
  Benchmark('optional()', any().optional(), characters),
  Benchmark('and()', any().and(), characters),
  Benchmark('not()', any().not(), characters),
  Benchmark('neg()', any().neg(), characters),
  Benchmark('flatten()', any().flatten(), characters),
  Benchmark('token()', any().token(), characters),
  Benchmark('trim()', any().trim(), characters),
  Benchmark('end()', any().end(), characters),
  Benchmark('set()', any().settable(), characters),
  Benchmark('map()', any().map((_) => null), characters),
  Benchmark('cast()', any().cast(), characters),
  Benchmark('castList()', any().star().castList(), characters),
  Benchmark('pick()', any().star().pick(0), characters),
  Benchmark('permute()', any().star().permute([0]), characters),
  Benchmark('or()', failure().or(any()).star(), characters),

  // repeater tests
  Benchmark('star()', any().star(), [string]),
  Benchmark('starGreedy()', any().starGreedy(failure()), [string]),
  Benchmark('starLazy()', any().starLazy(failure()), [string]),
  Benchmark('plus()', any().plus(), [string]),
  Benchmark('plusGreedy()', any().plusGreedy(failure()), [string]),
  Benchmark('plusLazy()', any().plusLazy(failure()), [string]),
  Benchmark('times()', any().times(string.length), [string]),
  Benchmark(
      'seq()', SequenceParser(List.filled(string.length, any())), [string]),

  // composite
  Benchmark('JsonParser()', json, [jsonEvent]),
];

void main() {
  print([
    'Name',
    'Normal String',
    'Fast String',
    'Normal Characters',
    'Fast Characters',
    'Normal String -> Fast String %',
    'Normal Characters -> Fast Characters %',
    'Normal String -> Normal Characters %',
    'Fast String -> Fast Characters %',
  ].join('\t'));
  for (final benchmark in benchmarks) {
    final normalString = benchmark.measure(isFast: false, isCharacters: false);
    final fastString = benchmark.measure(isFast: true, isCharacters: false);
    final normalChars = benchmark.measure(isFast: false, isCharacters: true);
    final fastChars = benchmark.measure(isFast: true, isCharacters: true);
    print([
      '${benchmark.name}',
      '${normalString.toStringAsFixed(3)}',
      '${fastString.toStringAsFixed(3)}',
      '${normalChars.toStringAsFixed(3)}',
      '${fastChars.toStringAsFixed(3)}',
      '${percentChange(normalString, fastString).round()}%',
      '${percentChange(normalChars, fastChars).round()}%',
      '${percentChange(normalString, normalChars).round()}%',
      '${percentChange(fastString, fastChars).round()}%',
    ].join('\t'));
  }
}

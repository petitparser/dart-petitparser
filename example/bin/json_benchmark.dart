library petitparser.example.json_benchmark;

import 'dart:convert' as convert;

import 'package:example/json.dart';

double benchmark(Function function,
    [int warmUp = 1000, int milliseconds = 5000]) {
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

final JsonParser json = JsonParser();

Object native(String input) => convert.json.decode(input);
Object custom(String input) => json.parse(input).value;

void main() {
  final nativeResult = native(jsonEvent);
  final customResult = custom(jsonEvent);

  if (nativeResult.toString() != customResult.toString()) {
    print('Results not matching!');
    print('  Native: $nativeResult');
    print('  Custom: $customResult');
    return;
  }

  final nativeTime = benchmark(() => native(jsonEvent));
  final customTime = benchmark(() => custom(jsonEvent));
  final ratio = customTime / nativeTime;

  print('Slowdown: ${ratio.toStringAsFixed(1)}');
  print('Native: ${nativeTime.toStringAsFixed(6)}');
  print('Custom: ${customTime.toStringAsFixed(6)}');
}

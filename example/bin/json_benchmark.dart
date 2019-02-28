library petitparser.example.json_benchmark;

import 'dart:convert' as convert;

import 'package:example/json.dart';

import 'benchmark.dart';

const String jsonEvent = '''
{"type": "change", "eventPhase": 2, "bubbles": true, "cancelable": true, 
"timeStamp": 0, "CAPTURING_PHASE": 1, "AT_TARGET": 2, "BUBBLING_PHASE": 3, 
"isTrusted": true, "MOUSEDOWN": 1, "MOUSEUP": 2, "MOUSEOVER": 4, "MOUSEOUT": 8, 
"MOUSEMOVE": 16, "MOUSEDRAG": 32, "CLICK": 64, "DBLCLICK": 128, "KEYDOWN": 256, 
"KEYUP": 512, "KEYPRESS": 1024, "DRAGDROP": 2048, "FOCUS": 4096, "BLUR": 8192, 
"SELECT": 16384, "CHANGE": 32768, "RESET": 65536, "SUBMIT": 131072, 
"SCROLL": 262144, "LOAD": 524288, "UNLOAD": 1048576, "XFER_DONE": 2097152, 
"ABORT": 4194304, "ERROR": 8388608, "LOCATE": 16777216, "MOVE": 33554432, 
"RESIZE": 67108864, "FORWARD": 134217728, "HELP": 268435456, "BACK": 536870912, 
"TEXT": 1073741824, "ALT_MASK": 1, "CONTROL_MASK": 2, "SHIFT_MASK": 4, 
"META_MASK": 8}
''';
const String jsonNested = '''{"items":{"item":[{"id": "0001","type": "donut",
"name": "Cake","ppu": 0.55,"batters":{"batter":[{ "id": "1001", "type": 
"Regular" },{ "id": "1002", "type": "Chocolate" },{ "id": "1003", "type": 
"Blueberry" },{ "id": "1004", "type": "Devil's Food" }]},"topping":[{ "id": 
"5001", "type": "None" },{ "id": "5002", "type": "Glazed" },{ "id": "5005", 
"type": "Sugar" },{ "id": "5007", "type": "Powdered Sugar" },{ "id": "5006", 
"type": "Chocolate with Sprinkles" },{ "id": "5003", "type": "Chocolate" },
{ "id": "5004", "type": "Maple" }]}]}}''';

final JsonParser json = JsonParser();

Object native(String input) => convert.json.decode(input);
Object custom(String input) => json.parse(input).value;

void compare(String name, String input) {
  final nativeResult = native(input);
  final customResult = custom(input);

  if (nativeResult.toString() != customResult.toString()) {
    print('$name\nERROR');
    return;
  }

  final nativeTime = benchmark(() => native(input));
  final customTime = benchmark(() => custom(input));
  print('$name\t'
      '${nativeTime.toStringAsFixed(6)}\t'
      '${customTime.toStringAsFixed(6)}\t'
      '${(100 * nativeTime / customTime).round() - 100}%');
}

void main() {
  print('Name\tNative\tParser\tChange');
  compare('Object', '{"a": 1, "b": 2, "c": 3, "d": 4, "e": 5, "f": 6, "g": 7}');
  compare('Array', '[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]');
  compare('Event', jsonEvent);
  compare('Nested', jsonNested);
}

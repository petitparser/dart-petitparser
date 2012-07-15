// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

#library('json_tests');

#import('/Applications/Dart/dart-sdk/lib/unittest/unittest.dart');

#import('../lib/petitparser.dart');
#import('../grammar/json/json.dart');

void main() {
  Parser json = new JsonParser();

  group('arrays', () {
    test('empty', () {
      expect(json.parse('[]').getResult(), []);
    });
    test('small', () {
      expect(json.parse('["a"]').getResult(), ['a']);
    });
    test('large', () {
      expect(json.parse('["a", "b", "c"]').getResult(), ['a', 'b', 'c']);
    });
    test('nested', () {
      expect(json.parse('[["a"]]').getResult(), [['a']]);
    });
    test('invalid', () {
      expect(json.parse('[').isFailure());
      expect(json.parse('[1').isFailure());
      expect(json.parse('[1,').isFailure());
      expect(json.parse('[1,]').isFailure());
      expect(json.parse('[1 2]').isFailure());
      expect(json.parse('[]]').isFailure());
    });
  });

  group('objects', () {
    test('empty', () {
      expect(json.parse('{}').getResult(), {});
    });
    test('small', () {
      expect(json.parse('{"a": 1}').getResult(), {'a': 1});
    });
    test('large', () {
      expect(json.parse('{"a": 1, "b": 2, "c": 3}').getResult(), {'a': 1, 'b': 2, 'c': 3});
    });
    test('nested', () {
      expect(json.parse('{"obj": {"a": 1}}').getResult(), {'obj': {"a": 1}});
    });
    test('invalid', () {
      expect(json.parse('{').isFailure());
      expect(json.parse('{\'a\'').isFailure());
      expect(json.parse('{\'a\':').isFailure());
      expect(json.parse('{\'a\':\'b\'').isFailure());
      expect(json.parse('{\'a\':\'b\',').isFailure());
      expect(json.parse('{\'a\'}').isFailure());
      expect(json.parse('{\'a\':}').isFailure());
      expect(json.parse('{\'a\':\'b\',}').isFailure());
      expect(json.parse('{}}').isFailure());
    });
  });

  group('literals', () {
    test('valid true', () {
      expect(json.parse('true').getResult());
    });
    test('invalid true', () {
      expect(json.parse('tr').isFailure());
      expect(json.parse('trace').isFailure());
      expect(json.parse('truest').isFailure());
    });
    test('valid false', () {
      expect(json.parse('false').getResult(), isFalse);
    });
    test('invalid false', () {
      expect(json.parse('fa').isFailure());
      expect(json.parse('falsely').isFailure());
      expect(json.parse('fabulous').isFailure());
    });
    test('valid null', () {
      expect(json.parse('null').getResult(), isNull);
    });
    test('invalid null', () {
      expect(json.parse('nu').isFailure());
      expect(json.parse('nuclear').isFailure());
      expect(json.parse('nullified').isFailure());
    });
    test('valid integer', () {
      expect(json.parse('0').getResult(), 0);
      expect(json.parse('1').getResult(), 1);
      expect(json.parse('-1').getResult(), -1);
      expect(json.parse('12').getResult(), 12);
      expect(json.parse('-12').getResult(), -12);
      expect(json.parse('1e2').getResult(), 100);
      expect(json.parse('1e+2').getResult(), 100);
    });
    test('invalid integer', () {
      expect(json.parse('00').isFailure());
      expect(json.parse('01').isFailure());
    });
    test('valid float', () {
      expect(json.parse('0.0').getResult(), 0.0);
      expect(json.parse('0.12').getResult(), 0.12);
      expect(json.parse('-0.12').getResult(), -0.12);
      expect(json.parse('12.34').getResult(), 12.34);
      expect(json.parse('-12.34').getResult(), -12.34);
      expect(json.parse('1.2e-1').getResult(), 1.2e-1);
      expect(json.parse('1.2E-1').getResult(), 1.2e-1);
    });
    test('invalid float', () {
      expect(json.parse('.1').isFailure());
      expect(json.parse('0.1.1').isFailure());
    });
    test('plain string', () {
      expect(json.parse('""').getResult(), '');
      expect(json.parse('"foo"').getResult(), 'foo');
      expect(json.parse('"foo bar"').getResult(), 'foo bar');
    });
    test('escaped string', () {
      expect(json.parse(@'"\""').getResult(), '"');
      expect(json.parse(@'"\\"').getResult(), '\\');
      expect(json.parse(@'"\b"').getResult(), '\b');
      expect(json.parse(@'"\f"').getResult(), '\f');
      expect(json.parse(@'"\n"').getResult(), '\n');
      expect(json.parse(@'"\r"').getResult(), '\r');
      expect(json.parse(@'"\t"').getResult(), '\t');
    });
    test('invalid string', () {
      expect(json.parse('"').isFailure());
      expect(json.parse('"a').isFailure());
      expect(json.parse('"a\\\"').isFailure());
    });
  });

  group('browser', () {
    test('Internet Explorer', () {
      var input = '{"recordset": null, "type": "change", "fromElement": null, "toElement": null, "altLeft": false, "keyCode": 0, "repeat": false, "reason": 0, "behaviorCookie": 0, "contentOverflow": false, "behaviorPart": 0, "dataTransfer": null, "ctrlKey": false, "shiftLeft": false, "dataFld": "", "qualifier": "", "wheelDelta": 0, "bookmarks": null, "button": 0, "srcFilter": null, "nextPage": "", "cancelBubble": false, "x": 89, "y": 502, "screenX": 231, "screenY": 1694, "srcUrn": "", "boundElements": {"length": 0}, "clientX": 89, "clientY": 502, "propertyName": "", "shiftKey": false, "ctrlLeft": false, "offsetX": 25, "offsetY": 2, "altKey": false}';
      expect(json.parse(input).isSuccess());
    });
    test('FireFox', () {
      var input = '{"type": "change", "eventPhase": 2, "bubbles": true, "cancelable": true, "timeStamp": 0, "CAPTURING_PHASE": 1, "AT_TARGET": 2, "BUBBLING_PHASE": 3, "isTrusted": true, "MOUSEDOWN": 1, "MOUSEUP": 2, "MOUSEOVER": 4, "MOUSEOUT": 8, "MOUSEMOVE": 16, "MOUSEDRAG": 32, "CLICK": 64, "DBLCLICK": 128, "KEYDOWN": 256, "KEYUP": 512, "KEYPRESS": 1024, "DRAGDROP": 2048, "FOCUS": 4096, "BLUR": 8192, "SELECT": 16384, "CHANGE": 32768, "RESET": 65536, "SUBMIT": 131072, "SCROLL": 262144, "LOAD": 524288, "UNLOAD": 1048576, "XFER_DONE": 2097152, "ABORT": 4194304, "ERROR": 8388608, "LOCATE": 16777216, "MOVE": 33554432, "RESIZE": 67108864, "FORWARD": 134217728, "HELP": 268435456, "BACK": 536870912, "TEXT": 1073741824, "ALT_MASK": 1, "CONTROL_MASK": 2, "SHIFT_MASK": 4, "META_MASK": 8}';
      expect(json.parse(input).isSuccess());
    });
    test('WebKit', () {
      var input = '{"returnValue": true, "timeStamp": 1226697417289, "eventPhase": 2, "type": "change", "cancelable": false, "bubbles": true, "cancelBubble": false, "MOUSEOUT": 8, "FOCUS": 4096, "CHANGE": 32768, "MOUSEMOVE": 16, "AT_TARGET": 2, "SELECT": 16384, "BLUR": 8192, "KEYUP": 512, "MOUSEDOWN": 1, "MOUSEDRAG": 32, "BUBBLING_PHASE": 3, "MOUSEUP": 2, "CAPTURING_PHASE": 1, "MOUSEOVER": 4, "CLICK": 64, "DBLCLICK": 128, "KEYDOWN": 256, "KEYPRESS": 1024, "DRAGDROP": 2048}';
      expect(json.parse(input).isSuccess());
    });
  });

}

library json_test;

import 'package:unittest/unittest.dart';

import 'package:petitparser/json.dart';

void main() {
  var json = new JsonParser();
  group('arrays', () {
    test('empty', () {
      expect(json.parse('[]').value, []);
    });
    test('small', () {
      expect(json.parse('["a"]').value, ['a']);
    });
    test('large', () {
      expect(json.parse('["a", "b", "c"]').value, ['a', 'b', 'c']);
    });
    test('nested', () {
      expect(json.parse('[["a"]]').value, [['a']]);
    });
    test('invalid', () {
      expect(json.parse('[').isFailure, isTrue);
      expect(json.parse('[1').isFailure, isTrue);
      expect(json.parse('[1,').isFailure, isTrue);
      expect(json.parse('[1,]').isFailure, isTrue);
      expect(json.parse('[1 2]').isFailure, isTrue);
      expect(json.parse('[]]').isFailure, isTrue);
    });
  });
  group('objects', () {
    test('empty', () {
      expect(json.parse('{}').value, {});
    });
    test('small', () {
      expect(json.parse('{"a": 1}').value, {'a': 1});
    });
    test('large', () {
      expect(json.parse('{"a": 1, "b": 2, "c": 3}').value, {
        'a': 1,
        'b': 2,
        'c': 3
      });
    });
    test('nested', () {
      expect(json.parse('{"obj": {"a": 1}}').value, {'obj': {"a": 1}});
    });
    test('invalid', () {
      expect(json.parse('{').isFailure, isTrue);
      expect(json.parse('{\'a\'').isFailure, isTrue);
      expect(json.parse('{\'a\':').isFailure, isTrue);
      expect(json.parse('{\'a\':\'b\'').isFailure, isTrue);
      expect(json.parse('{\'a\':\'b\',').isFailure, isTrue);
      expect(json.parse('{\'a\'}').isFailure, isTrue);
      expect(json.parse('{\'a\':}').isFailure, isTrue);
      expect(json.parse('{\'a\':\'b\',}').isFailure, isTrue);
      expect(json.parse('{}}').isFailure, isTrue);
    });
  });
  group('literals', () {
    test('valid true', () {
      expect(json.parse('true').value, isTrue);
    });
    test('invalid true', () {
      expect(json.parse('tr').isFailure, isTrue);
      expect(json.parse('trace').isFailure, isTrue);
      expect(json.parse('truest').isFailure, isTrue);
    });
    test('valid false', () {
      expect(json.parse('false').value, isFalse);
    });
    test('invalid false', () {
      expect(json.parse('fa').isFailure, isTrue);
      expect(json.parse('falsely').isFailure, isTrue);
      expect(json.parse('fabulous').isFailure, isTrue);
    });
    test('valid null', () {
      expect(json.parse('null').value, isNull);
    });
    test('invalid null', () {
      expect(json.parse('nu').isFailure, isTrue);
      expect(json.parse('nuclear').isFailure, isTrue);
      expect(json.parse('nullified').isFailure, isTrue);
    });
    test('valid integer', () {
      expect(json.parse('0').value, 0);
      expect(json.parse('1').value, 1);
      expect(json.parse('-1').value, -1);
      expect(json.parse('12').value, 12);
      expect(json.parse('-12').value, -12);
      expect(json.parse('1e2').value, 100);
      expect(json.parse('1e+2').value, 100);
    });
    test('invalid integer', () {
      expect(json.parse('00').isFailure, isTrue);
      expect(json.parse('01').isFailure, isTrue);
    });
    test('valid float', () {
      expect(json.parse('0.0').value, 0.0);
      expect(json.parse('0.12').value, 0.12);
      expect(json.parse('-0.12').value, -0.12);
      expect(json.parse('12.34').value, 12.34);
      expect(json.parse('-12.34').value, -12.34);
      expect(json.parse('1.2e-1').value, 1.2e-1);
      expect(json.parse('1.2E-1').value, 1.2e-1);
    });
    test('invalid float', () {
      expect(json.parse('.1').isFailure, isTrue);
      expect(json.parse('0.1.1').isFailure, isTrue);
    });
    test('plain string', () {
      expect(json.parse('""').value, '');
      expect(json.parse('"foo"').value, 'foo');
      expect(json.parse('"foo bar"').value, 'foo bar');
    });
    test('escaped string', () {
      expect(json.parse('"\\""').value, '"');
      expect(json.parse('"\\\\"').value, '\\');
      expect(json.parse('"\\b"').value, '\b');
      expect(json.parse('"\\f"').value, '\f');
      expect(json.parse('"\\n"').value, '\n');
      expect(json.parse('"\\r"').value, '\r');
      expect(json.parse('"\\t"').value, '\t');
    });
    test('invalid string', () {
      expect(json.parse('"').isFailure, isTrue);
      expect(json.parse('"a').isFailure, isTrue);
      expect(json.parse('"a\\\"').isFailure, isTrue);
    });
  });
  group('browser', () {
    test('Internet Explorer', () {
      var input = '{"recordset": null, "type": "change", "fromElement": null, "toElement": null, '
          '"altLeft": false, "keyCode": 0, "repeat": false, "reason": 0, "behaviorCookie": 0, '
          '"contentOverflow": false, "behaviorPart": 0, "dataTransfer": null, "ctrlKey": false, '
          '"shiftLeft": false, "dataFld": "", "qualifier": "", "wheelDelta": 0, "bookmarks": null, '
          '"button": 0, "srcFilter": null, "nextPage": "", "cancelBubble": false, "x": 89, "y": '
          '502, "screenX": 231, "screenY": 1694, "srcUrn": "", "boundElements": {"length": 0}, '
          '"clientX": 89, "clientY": 502, "propertyName": "", "shiftKey": false, "ctrlLeft": '
          'false, "offsetX": 25, "offsetY": 2, "altKey": false}';
      expect(json.parse(input).isSuccess, isTrue);
    });
    test('FireFox', () {
      var input = '{"type": "change", "eventPhase": 2, "bubbles": true, "cancelable": true, '
          '"timeStamp": 0, "CAPTURING_PHASE": 1, "AT_TARGET": 2, "BUBBLING_PHASE": 3, '
          '"isTrusted": true, "MOUSEDOWN": 1, "MOUSEUP": 2, "MOUSEOVER": 4, "MOUSEOUT": 8, '
          '"MOUSEMOVE": 16, "MOUSEDRAG": 32, "CLICK": 64, "DBLCLICK": 128, "KEYDOWN": 256, '
          '"KEYUP": 512, "KEYPRESS": 1024, "DRAGDROP": 2048, "FOCUS": 4096, "BLUR": 8192, '
          '"SELECT": 16384, "CHANGE": 32768, "RESET": 65536, "SUBMIT": 131072, "SCROLL": '
          '262144, "LOAD": 524288, "UNLOAD": 1048576, "XFER_DONE": 2097152, "ABORT": 4194304, '
          '"ERROR": 8388608, "LOCATE": 16777216, "MOVE": 33554432, "RESIZE": 67108864, '
          '"FORWARD": 134217728, "HELP": 268435456, "BACK": 536870912, "TEXT": 1073741824, '
          '"ALT_MASK": 1, "CONTROL_MASK": 2, "SHIFT_MASK": 4, "META_MASK": 8}';
      expect(json.parse(input).isSuccess, isTrue);
    });
    test('WebKit', () {
      var input = '{"returnValue": true, "timeStamp": 1226697417289, "eventPhase": 2, "type": '
          '"change", "cancelable": false, "bubbles": true, "cancelBubble": false, "MOUSEOUT": 8, '
          '"FOCUS": 4096, "CHANGE": 32768, "MOUSEMOVE": 16, "AT_TARGET": 2, "SELECT": 16384, '
          '"BLUR": 8192, "KEYUP": 512, "MOUSEDOWN": 1, "MOUSEDRAG": 32, "BUBBLING_PHASE": 3, '
          '"MOUSEUP": 2, "CAPTURING_PHASE": 1, "MOUSEOVER": 4, "CLICK": 64, "DBLCLICK": 128, '
          '"KEYDOWN": 256, "KEYPRESS": 1024, "DRAGDROP": 2048}';
      expect(json.parse(input).isSuccess, isTrue);
    });
  });
}

import 'package:petitparser/context.dart';
import 'package:test/test.dart';

class DebugContext implements Context {
  DebugContext(
    this.buffer, {
    int position = 0,
    bool isSuccess = true,
    dynamic value,
    String message = '',
    bool isCut = true,
  })  : _position = position,
        _isSuccess = isSuccess,
        _value = value,
        _message = message,
        _isCut = isCut;

  final events = <ContextEvent>[];

  /// The input the parser is being run on.
  @override
  final String buffer;

  /// The current position in the parser input.
  int _position;

  @override
  int get position => _position;

  @override
  set position(int position) {
    expect(position,
        allOf(greaterThanOrEqualTo(0), lessThanOrEqualTo(buffer.length)),
        reason: 'Position is out of bounds');
    events.add(ContextEvent(ContextEventType.position, _position, position));
    _position = position;
  }

  /// Whether or not the parse is currently successful.
  bool _isSuccess;

  @override
  bool get isSuccess => _isSuccess;

  @override
  set isSuccess(bool isSuccess) {
    events.add(ContextEvent(ContextEventType.isSuccess, _isSuccess, isSuccess));
    _isSuccess = isSuccess;
  }

  /// The currently successful read value.
  dynamic _value;

  @override
  dynamic get value {
    expect(isSuccess, isTrue, reason: '`value` is undefined on failure');
    return _value;
  }

  @override
  set value(dynamic value) {
    events.add(ContextEvent(ContextEventType.value, _value, value));
    _value = value;
  }

  /// The currently read error.
  String _message;

  @override
  String get message => _message;

  @override
  set message(String message) {
    expect(isSuccess, isFalse, reason: '`message` is undefined on success');
    events.add(ContextEvent(ContextEventType.message, _message, message));
    _message = message;
  }

  /// Disables backtracking of errors.
  bool _isCut;

  @override
  bool get isCut => _isCut;

  @override
  set isCut(bool isCut) {
    events.add(ContextEvent(ContextEventType.isCut, _isCut, isCut));
    _isCut = isCut;
  }

  /// Converts the current state of the context to a [Result].
  @override
  Result<T> toResult<T>() => _isSuccess
      ? Success<T>(buffer, position, value)
      : Failure<T>(buffer, position, message);

  @override
  String toString() => [
        'DebugContext{',
        'position: $_position',
        'isSuccess: $_isSuccess',
        'value: $_value',
        'message: $_message',
        'isCut: $_isCut}',
      ].join(', ');
}

enum ContextEventType {
  position,
  isSuccess,
  value,
  message,
  isSkip,
  isCut;
}

class ContextEvent {
  ContextEvent(this.type, this.previous, this.current);

  final ContextEventType type;

  final dynamic previous;

  final dynamic current;

  @override
  String toString() => '$type: $previous -> $current';
}

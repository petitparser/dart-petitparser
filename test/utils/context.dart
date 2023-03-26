import 'package:petitparser/context.dart';
import 'package:test/test.dart';

class DebugContext implements Context {
  DebugContext(
    this.buffer, {
    this.start = 0,
    int? end,
    int? position,
    bool isSuccess = true,
    dynamic value,
    String message = '',
    bool isSkip = false,
    bool isCut = false,
  })  : end = buffer.length,
        _position = position ?? start,
        _isSuccess = isSuccess,
        _value = value,
        _message = message,
        _isCut = isCut,
        _isSkip = isSkip;

  final events = <ContextEvent>[];

  /// The input the parser is being run on.
  @override
  final String buffer;

  /// The start index in the input buffer.
  @override
  final int start;

  /// The end index in the input buffer.
  @override
  final int end;

  /// The current position in the parser input.
  int _position;

  @override
  int get position => _position;

  @override
  set position(int position) {
    expect(
        _position, allOf(greaterThanOrEqualTo(start), lessThanOrEqualTo(end)),
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
    expect(_isSuccess, isTrue, reason: '`value` is undefined on failure');
    expect(_isSkip, isFalse, reason: '`value` is undefined on skip');
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

  /// Disables the population of [value].
  bool _isSkip;

  @override
  bool get isSkip => _isSkip;

  @override
  set isSkip(bool isSkip) {
    events.add(ContextEvent(ContextEventType.isSkip, _isSkip, isSkip));
    _isSkip = isSkip;
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
      ? Success<T>(buffer, position, value as T)
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

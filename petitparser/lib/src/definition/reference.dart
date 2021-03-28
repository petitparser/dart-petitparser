import 'package:meta/meta.dart';

import '../context/context.dart';
import '../context/result.dart';
import '../core/parser.dart';

@immutable
class Reference extends Parser {
  Reference(this.function, this.arguments);

  final Function function;
  final List<Object> arguments;

  Parser resolve() => Function.apply(function, arguments);

  @override
  bool operator ==(Object other) {
    if (other is Reference) {
      if (function != other.function ||
          arguments.length != other.arguments.length) {
        return false;
      }
      for (var i = 0; i < arguments.length; i++) {
        final a = arguments[i], b = other.arguments[i];
        if (a is Parser && a is! Reference && b is Parser && b is! Reference) {
          // for parsers do a deep equality check
          if (!a.isEqualTo(b)) {
            return false;
          }
        } else {
          // for everything else just do standard equality
          if (a != b) {
            return false;
          }
        }
      }
      return true;
    }
    return false;
  }

  @override
  Result parseOn(Context context) =>
      throw UnsupportedError('References cannot be parsed.');

  @override
  int fastParseOn(String buffer, int position) =>
      throw UnsupportedError('References cannot be parsed.');

  @override
  int get hashCode => function.hashCode;

  @override
  Reference copy() => throw UnsupportedError('References cannot be copied.');
}

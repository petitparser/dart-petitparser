import 'package:meta/meta.dart';

import '../context/context.dart';
import '../context/result.dart';
import '../core/parser.dart';

@immutable
class Reference<T> extends Parser<T> {
  final Function function;
  final List<dynamic> arguments;

  Reference(this.function, this.arguments);

  Parser<T> resolve() => Function.apply(function, arguments);

  @override
  bool operator ==(Object other) {
    if (other is Reference) {
      if (other.function != function ||
          other.arguments.length != arguments.length) {
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
  int get hashCode => function.hashCode;

  @override
  Reference<T> copy() => throw UnsupportedError('References cannot be copied.');

  @override
  Result<T> parseOn(Context context) =>
      throw UnsupportedError('References cannot be parsed.');
}

import 'package:meta/meta.dart';

import '../../core/context.dart';
import '../../core/parser.dart';
import '../../core/result.dart';
import '../../parser/utils/resolvable.dart';

/// Internal implementation of a reference parser.
@immutable
class ReferenceParser<R> extends Parser<R> implements ResolvableParser<R> {
  ReferenceParser(this.function, this.arguments);

  final Function function;
  final List<dynamic> arguments;

  @override
  Parser<R> resolve() => Function.apply(function, arguments) as Parser<R>;

  @override
  Result<R> parseOn(Context context) => _throwUnsupported();

  @override
  ReferenceParser<R> copy() => _throwUnsupported();

  @override
  bool operator ==(Object other) {
    if (other is ReferenceParser) {
      if (function != other.function ||
          arguments.length != other.arguments.length) {
        return false;
      }
      for (var i = 0; i < arguments.length; i++) {
        final a = arguments[i], b = other.arguments[i];
        if (a is Parser &&
            a is! ReferenceParser &&
            b is Parser &&
            b is! ReferenceParser) {
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
}

Never _throwUnsupported() =>
    throw UnsupportedError('Unsupported operation on parser reference');

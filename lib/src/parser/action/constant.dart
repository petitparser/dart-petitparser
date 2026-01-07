import 'package:meta/meta.dart';

import '../../core/context.dart';
import '../../core/parser.dart';
import '../../core/result.dart';
import '../combinator/delegate.dart';

extension ConstantParserExtension<R> on Parser<R> {
  /// Returns a parser that returns a constant value.
  ///
  /// For example, the parser `digit().star().constant(42)` returns the number
  /// `42` for whatever input digits it consumes.
  @useResult
  Parser<S> constant<S>(S value) => ConstantParser<R, S>(this, value);
}

/// A parser that returns a constant value.
class ConstantParser<R, S> extends DelegateParser<R, S> {
  ConstantParser(super.delegate, this.value);

  final S value;

  @override
  Result<S> parseOn(Context context) {
    final result = delegate.parseOn(context);
    if (result is Failure) return result;
    return result.success(value);
  }

  @override
  int fastParseOn(String buffer, int position) =>
      delegate.fastParseOn(buffer, position);

  @override
  bool hasEqualProperties(ConstantParser<R, S> other) =>
      super.hasEqualProperties(other) && value == other.value;

  @override
  ConstantParser<R, S> copy() => ConstantParser<R, S>(delegate, value);
}

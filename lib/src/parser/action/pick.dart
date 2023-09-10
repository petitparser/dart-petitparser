import 'package:meta/meta.dart';

import '../../core/context.dart';
import '../../core/parser.dart';
import '../../core/result.dart';
import '../combinator/delegate.dart';

extension PickParserExtension<R> on Parser<List<R>> {
  /// Returns a parser that transforms a successful parse result by returning
  /// the element at [index] of a list. A negative index can be used to access
  /// the elements from the back of the list.
  ///
  /// For example, the parser `letter().star().pick(-1)` returns the last
  /// letter parsed. For the input `'abc'` it returns `'c'`.
  @useResult
  Parser<R> pick(int index) => PickParser<R>(this, index);
}

/// A parser that performs a transformation with a given function on the
/// successful parse result of the delegate.
class PickParser<R> extends DelegateParser<List<R>, R> {
  PickParser(super.delegate, this.index);

  /// Indicates which element to return from the parsed list.
  final int index;

  @override
  Result<R> parseOn(Context context) {
    final result = delegate.parseOn(context);
    if (result is Failure) return result;
    final value = result.value;
    return result.success(value[index < 0 ? value.length + index : index]);
  }

  @override
  int fastParseOn(String buffer, int position) =>
      delegate.fastParseOn(buffer, position);

  @override
  String toString() => '${super.toString()}[$index]';

  @override
  PickParser<R> copy() => PickParser<R>(delegate, index);

  @override
  bool hasEqualProperties(PickParser<R> other) =>
      super.hasEqualProperties(other) && index == other.index;
}

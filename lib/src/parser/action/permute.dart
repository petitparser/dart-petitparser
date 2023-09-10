import 'package:meta/meta.dart';

import '../../core/context.dart';
import '../../core/parser.dart';
import '../../core/result.dart';
import '../combinator/delegate.dart';

extension PermuteParserExtension<R> on Parser<List<R>> {
  /// Returns a parser that transforms a successful parse result by returning
  /// the permuted elements at [indexes] of a list. Negative indexes can be
  /// used to access the elements from the back of the list.
  ///
  /// For example, the parser `letter().star().permute([0, -1])` returns the
  /// first and last letter parsed. For the input `'abc'` it returns
  /// `['a', 'c']`.
  @useResult
  Parser<List<R>> permute(List<int> indexes) => PermuteParser<R>(this, indexes);
}

/// A parser that performs a transformation with a given function on the
/// successful parse result of the delegate.
class PermuteParser<R> extends DelegateParser<List<R>, List<R>> {
  PermuteParser(super.delegate, this.indexes);

  /// Indicates which elements to return from the parsed list.
  final List<int> indexes;

  @override
  Result<List<R>> parseOn(Context context) {
    final result = delegate.parseOn(context);
    if (result is Failure) return result;
    final value = result.value;
    final values = indexes
        .map((index) => value[index < 0 ? value.length + index : index])
        .toList(growable: false);
    return result.success(values);
  }

  @override
  int fastParseOn(String buffer, int position) =>
      delegate.fastParseOn(buffer, position);

  @override
  String toString() => '${super.toString()}[${indexes.join(', ')}]';

  @override
  PermuteParser<R> copy() => PermuteParser<R>(delegate, indexes);

  @override
  bool hasEqualProperties(PermuteParser<R> other) =>
      super.hasEqualProperties(other) && indexes == other.indexes;
}

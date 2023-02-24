import 'package:meta/meta.dart';

import '../../context/context.dart';
import '../../core/parser.dart';
import '../combinator/delegate.dart';

extension PermuteParserExtension<T> on Parser<List<T>> {
  /// Returns a parser that transforms a successful parse result by returning
  /// the permuted elements at [indexes] of a list. Negative indexes can be
  /// used to access the elements from the back of the list.
  ///
  /// For example, the parser `letter().star().permute([0, -1])` returns the
  /// first and last letter parsed. For the input `'abc'` it returns
  /// `['a', 'c']`.
  @useResult
  Parser<List<T>> permute(List<int> indexes) => PermuteParser<T>(this, indexes);
}

/// A parser that performs a transformation with a given function on the
/// successful parse result of the delegate.
class PermuteParser<R> extends DelegateParser<List<R>, List<R>> {
  PermuteParser(super.delegate, this.indexes);

  /// Indicates which elements to return from the parsed list.
  final List<int> indexes;

  @override
  void parseOn(Context context) {
    delegate.parseOn(context);
    if (context.isSuccess) {
      final value = context.value as List<R>;
      context.value = indexes
          .map((index) => value[index < 0 ? value.length + index : index])
          .toList(growable: false);
    }
  }

  @override
  PermuteParser<R> copy() => PermuteParser<R>(delegate, indexes);

  @override
  bool hasEqualProperties(PermuteParser<R> other) =>
      super.hasEqualProperties(other) && indexes == other.indexes;
}

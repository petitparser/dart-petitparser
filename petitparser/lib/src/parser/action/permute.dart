import '../../context/context.dart';
import '../../context/result.dart';
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
  Parser<List<T>> permute(List<int> indexes) => PermuteParser<T>(this, indexes);
}

/// A parser that performs a transformation with a given function on the
/// successful parse result of the delegate.
class PermuteParser<T> extends DelegateParser<List<T>, List<T>> {
  final List<int> indexes;

  PermuteParser(Parser<List<T>> delegate, this.indexes) : super(delegate);

  @override
  Result<List<T>> parseOn(Context context) {
    final result = delegate.parseOn(context);
    if (result.isSuccess) {
      final value = result.value;
      final values = indexes
          .map((index) => value[index < 0 ? value.length + index : index])
          .cast<T>()
          .toList(growable: false);
      return result.success(values);
    } else {
      return result.failure(result.message);
    }
  }

  @override
  int fastParseOn(String buffer, int position) =>
      delegate.fastParseOn(buffer, position);

  @override
  PermuteParser<T> copy() => PermuteParser<T>(delegate, indexes);

  @override
  bool hasEqualProperties(PermuteParser<T> other) =>
      super.hasEqualProperties(other) && indexes == other.indexes;
}

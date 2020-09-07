import '../../context/context.dart';
import '../../context/result.dart';
import '../../core/parser.dart';
import '../combinator/delegate.dart';

extension PickParserExtension<T> on Parser<List<T>> {
  /// Returns a parser that transforms a successful parse result by returning
  /// the element at [index] of a list. A negative index can be used to access
  /// the elements from the back of the list.
  ///
  /// For example, the parser `letter().star().pick(-1)` returns the last
  /// letter parsed. For the input `'abc'` it returns `'c'`.
  Parser<T> pick(int index) => PickParser<T>(this, index);
}

/// A parser that performs a transformation with a given function on the
/// successful parse result of the delegate.
class PickParser<T> extends DelegateParser<T> {
  final int index;

  PickParser(Parser delegate, this.index) : super(delegate);

  @override
  Result<T> parseOn(Context context) {
    final result = delegate.parseOn(context);
    if (result.isSuccess) {
      final value = result.value;
      final picked = value[index < 0 ? value.length + index : index];
      return result.success(picked);
    } else {
      return result.failure(result.message);
    }
  }

  @override
  int fastParseOn(String buffer, int position) =>
      delegate.fastParseOn(buffer, position);

  @override
  PickParser<T> copy() => PickParser<T>(delegate, index);

  @override
  bool hasEqualProperties(PickParser<T> other) =>
      super.hasEqualProperties(other) && index == other.index;
}

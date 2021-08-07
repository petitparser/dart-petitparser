import '../../context/context.dart';
import '../../context/result.dart';
import '../../core/parser.dart';
import '../combinator/delegate.dart';

extension LabelParserExtension<R> on Parser<R> {
  /// Returns a parser that simply defers to its delegate, but that
  /// has a [label] for debugging purposes.
  Parser<R> label(String label) => LabelParser<R>(this, label);
}

/// A parser that alwauys defers to its delegate, but that also holds a label
/// for debugging.
class LabelParser<R> extends DelegateParser<R, R> {
  LabelParser(Parser<R> delegate, this.label) : super(delegate);

  /// Label of this parser.
  final String label;

  @override
  Result<R> parseOn(Context context) => delegate.parseOn(context);

  @override
  int fastParseOn(String buffer, int position) =>
      delegate.fastParseOn(buffer, position);

  @override
  String toString() => '${super.toString()}[$label]';

  @override
  LabelParser<R> copy() => LabelParser<R>(delegate, label);

  @override
  bool hasEqualProperties(LabelParser<R> other) =>
      super.hasEqualProperties(other) && label == other.label;
}

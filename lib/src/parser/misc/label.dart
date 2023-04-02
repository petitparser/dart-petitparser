import 'package:meta/meta.dart';

import '../../context/context.dart';
import '../../core/parser.dart';
import '../../parser/utils/labeled.dart';
import '../combinator/delegate.dart';

extension LabelParserExtension<R> on Parser<R> {
  /// Returns a parser that simply defers to its delegate, but that
  /// has a [label] for debugging purposes.
  @useResult
  LabeledParser<R> labeled(String label) => LabelParser<R>(this, label);
}

/// A parser that always defers to its delegate, but that also holds a label
/// for debugging purposes.
class LabelParser<R> extends DelegateParser<R, R> implements LabeledParser<R> {
  LabelParser(super.delegate, this.label);

  /// Label of this parser.
  @override
  final String label;

  @override
  void parseOn(Context context) => delegate.parseOn(context);

  @override
  String toString() => '${super.toString()}[$label]';

  @override
  LabelParser<R> copy() => LabelParser<R>(delegate, label);

  @override
  bool hasEqualProperties(LabelParser<R> other) =>
      super.hasEqualProperties(other) && label == other.label;
}

import '../../core/parser.dart';

/// An abstract parser that delegates to a parser of type [T].
abstract class DelegateParser<R, S> extends Parser<S> {
  DelegateParser(this.delegate);

  /// The parser this parser delegates to.
  Parser<R> delegate;

  @override
  List<Parser> get children => [delegate];

  @override
  void replace(Parser source, Parser target) {
    super.replace(source, target);
    if (delegate == source) {
      delegate = target as Parser<R>;
    }
  }
}

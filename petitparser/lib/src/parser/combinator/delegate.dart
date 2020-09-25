import '../../core/parser.dart';

/// A parser that delegates to another one.
abstract class DelegateParser<T> extends Parser<T> {
  Parser delegate;

  DelegateParser(this.delegate)
      : assert(delegate != null, 'delegate must not be null');

  @override
  List<Parser> get children => [delegate];

  @override
  void replace(Parser source, Parser target) {
    super.replace(source, target);
    if (delegate == source) {
      delegate = target;
    }
  }
}

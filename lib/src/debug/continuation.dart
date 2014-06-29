part of debug;

/**
 * Handler function of a [ContinuationParser].
 */
typedef Result ContinuationHandler(Context context, Function continuation);

/**
 * Continuation parser that when executed allows the handler to
 * dynamically wrap its delegate.
 */
class ContinuationParser extends DelegateParser {

  final ContinuationHandler handler;

  ContinuationParser(parser, this.handler): super(parser);

  @override
  Result parseOn(Context context) {
    return handler(context, (result) => super.parseOn(result));
  }

  @override
  Parser copy() => new ContinuationParser(children[0], handler);

}
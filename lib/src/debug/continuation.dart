part of debug;

/**
 * Handler function for the [ContinuationParser].
 */
typedef Result ContinuationHandler(Result continuation(Context context), Context context);

/**
 * Continuation parser that when activated captures a continuation function
 * and passes it together with the current context into the handler.
 *
 * Handlers are not required to call the continuation, but can completely ignore
 * it, call it multiple times, and/or store it away for later use. Similarly
 * handlers can modify the current context and/or modify the returned result.
 *
 * The following example shows a simple wrapper. Messages are printed before and
 * after the `digit()` parser is activated:
 *
 *    var wrapped = digit();
 *    var parser = new ContinuationParser(wrapped, (continuation, context) {
 *      print('Parser will be activated, the context is $context.');
 *      var result = continuation(context);
 *      print('Parser was activated, the result is $result.');
 *      return result;
 *    });
 *
 * See [profile], [progress], and [trace] for more elaborate examples.
 */
class ContinuationParser extends DelegateParser {

  final ContinuationHandler handler;

  ContinuationParser(parser, this.handler): super(parser);

  @override
  Result parseOn(Context context) {
    return handler((result) => super.parseOn(result), context);
  }

  @override
  Parser copy() => new ContinuationParser(children[0], handler);

}
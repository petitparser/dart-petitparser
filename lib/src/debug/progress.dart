part of debug;

/**
 * Adds progress handlers to each parser reachable from [root].
 */
Parser progress(Parser root, [OutputHandler output = print]) {
  return transformParser(root, (parser) {
    return new ContinuationParser(parser, (continuation, context) {
      output('${_repeat(1 + context.position, '*')} $parser');
      return continuation(context);
    });
  });
}
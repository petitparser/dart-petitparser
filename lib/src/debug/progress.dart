part of debug;

/**
 * Adds progress handlers to each parser reachable from [root].
 */
Parser progress(Parser root, [StringSink output]) {
  if (output == null) output = stdout;
  return transformParser(root, (parser) {
    return new ContinuationParser(parser, (continuation, context) {
      output.writeln('${_repeat(1 + context.position, '*')} $parser');
      return continuation(context);
    });
  });
}
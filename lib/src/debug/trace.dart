part of debug;

/**
 * Adds trace handlers to each parser reachable from [root].
 */
Parser trace(Parser root, [StringSink output]) {
  var level = 0;
  if (output == null) output = stdout;
  return transformParser(root, (parser) {
    return new ContinuationParser(parser, (continuation, context) {
      output.writeln('${_repeat(level, '  ')}${parser}');
      level++;
      var result = continuation(context);
      level--;
      output.writeln('${_repeat(level, '  ')}${result}');
      return result;
    });
  });
}
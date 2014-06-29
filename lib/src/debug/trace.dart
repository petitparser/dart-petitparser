part of debug;

/**
 * Adds trace handlers to each parser reachable from [root].
 */
Parser trace(Parser root, [OutputHandler output = print]) {
  var level = 0;
  return transformParser(root, (parser) {
    return new ContinuationParser(parser, (continuation, context) {
      output('${_repeat(level, '  ')}${parser}');
      level++;
      var result = continuation(context);
      level--;
      output('${_repeat(level, '  ')}${result}');
      return result;
    });
  });
}
part of debug;

/**
 * Adds profiling handlers to each parser reachable from [root].
 */
Parser profile(Parser root, [StringSink output]) {
  var count = new Map();
  var watch = new Map();
  var parsers = new List();
  if (output == null) output = stdout;
  return new ContinuationParser(transformParser(root, (parser) {
    parsers.add(parser);
    return new ContinuationParser(parser, (context, continuation) {
      count[parser]++;
      watch[parser].start();
      var result = continuation(context);
      watch[parser].stop();
      return result;
    });
  }), (context, continuation) {
    parsers.forEach((parser) {
      count[parser] = 0;
      watch[parser] = new Stopwatch();
    });
    var result = continuation(context);
    parsers.forEach((parser) {
      output.writeln('${count[parser]}\t'
        '${watch[parser].elapsedMicroseconds}\t'
        '${parser}');
    });
    return result;
  });
}
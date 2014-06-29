part of debug;

/**
 * Adds profiling handlers to each parser reachable from [root].
 */
Parser profile(Parser root, [OutputHandler output = print]) {
  var count = new Map();
  var watch = new Map();
  var parsers = new List();
  return new ContinuationParser(transformParser(root, (parser) {
    parsers.add(parser);
    return new ContinuationParser(parser, (continuation, context) {
      count[parser]++;
      watch[parser].start();
      var result = continuation(context);
      watch[parser].stop();
      return result;
    });
  }), (continuation, context) {
    parsers.forEach((parser) {
      count[parser] = 0;
      watch[parser] = new Stopwatch();
    });
    var result = continuation(context);
    parsers.forEach((parser) {
      output('${count[parser]}\t'
        '${watch[parser].elapsedMicroseconds}\t'
        '${parser}');
    });
    return result;
  });
}
part of debug;

/**
 * Returns a transformed [parser] that when being used measures
 * the activation count and total time of each parser.
 *
 * For example, the snippet
 *
 *   var parser = letter() & word().star();
 *   profile(parser).parse('f1234567890');
 *
 * produces the following output:
 *
 *    1  2006  Instance of 'SequenceParser'
 *    1   697  Instance of 'PossessiveRepeatingParser'[0..*]
 *   11   406  Instance of 'CharacterParser'[letter or digit expected]
 *    1   947  Instance of 'CharacterParser'[letter expected]
 *
 * The first number refers to the number of activations of each parser, and
 * the second number is the microseconds spent in this parser and all its
 * children.
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
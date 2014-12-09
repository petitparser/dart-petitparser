library all_benchmark;

import 'package:petitparser/petitparser.dart';

double benchmark(Function function, [int warmup = 100, int milliseconds = 2500]) {
  var count = 0;
  var elapsed = 0;
  var watch = new Stopwatch();
  while (warmup-- > 0) {
    function();
  }
  watch.start();
  while (elapsed < milliseconds) {
    function();
    elapsed = watch.elapsedMilliseconds;
    count++;
  }
  return elapsed / count;
}

Function charTest(List<String> inputs, Parser parser) {
  return () {
    for (var i = 0; i < inputs.length; i++) {
      parser.parse(inputs[i]);
    }
  };
}

final characters = new List.generate(256, (value) => new String.fromCharCode(value));

Function stringTest(String input, Parser parser) {
  return () {
    parser.parse(input);
  };
}

final string = characters.join();

final benchmarks = {

  // char tests
  "any()": charTest(characters, any()),
  "anyOf('uncopyrightable')": charTest(characters, anyOf('uncopyrightable')),
  "char('a')": charTest(characters, char('a')),
  "digit()": charTest(characters, digit()),
  "letter()": charTest(characters, letter()),
  "lowercase()": charTest(characters, lowercase()),
  "noneOf('uncopyrightable')": charTest(characters, noneOf('uncopyrightable')),
  "pattern('^a')": charTest(characters, pattern('^a')),
  "pattern('^a-cx-zA-CX-Z1-37-9')": charTest(characters, pattern('^a-cx-zA-CX-Z1-37-9')),
  "pattern('^a-z')": charTest(characters, pattern('^a-z')),
  "pattern('^acegik')": charTest(characters, pattern('^acegik')),
  "pattern('a')": charTest(characters, pattern('a')),
  "pattern('a-cx-zA-CX-Z1-37-9')": charTest(characters, pattern('a-cx-zA-CX-Z1-37-9')),
  "pattern('a-z')": charTest(characters, pattern('a-z')),
  "pattern('acegik')": charTest(characters, pattern('acegik')),
  "range('a', 'z')": charTest(characters, range('a', 'z')),
  "uppercase()": charTest(characters, uppercase()),
  "whitespace()": charTest(characters, whitespace()),
  "word()": charTest(characters, word()),

  // combinator tests
  "star()": stringTest(string, any().star()),
  "starLazy()": stringTest(string, any().starLazy(failure())),
  "starGreedy()": stringTest(string, any().starGreedy(failure())),
  "plus()": stringTest(string, any().plus()),
  "plusLazy()": stringTest(string, any().plusLazy(failure())),
  "plusGreedy()": stringTest(string, any().plusGreedy(failure())),
  "or()": stringTest(string, failure().or(any()).star()),
  "seq()": stringTest(string, new SequenceParser(new List.filled(string.length, any()))),

};

void main() {
  print('<?xml version="1.0"?>');
  print('<benchmarks>');
  for (var name in benchmarks.keys) {
    print('  <benchmark name="$name">${benchmark(benchmarks[name])}</benchmark>');
  }
  print('</benchmarks>');
}

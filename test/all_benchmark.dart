library xml_benchmark;

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

Function tester(List<String> inputs, Parser parser) {
  return () {
    for (var i = 0; i < inputs.length; i++) {
      parser.parse(inputs[i]);
    }
  };
}

final characters = new List.generate(256, (value) => new String.fromCharCode(value));

final benchmarks = {
  "anyOf('uncopyrightable')": tester(characters, anyOf('uncopyrightable')),
  "char('a')": tester(characters, char('a')),
  "digit()": tester(characters, digit()),
  "letter()": tester(characters, letter()),
  "lowercase()": tester(characters, lowercase()),
  "noneOf('uncopyrightable')": tester(characters, noneOf('uncopyrightable')),
  "pattern('^a')": tester(characters, pattern('^a')),
  "pattern('^a-cx-zA-CX-Z1-37-9')": tester(characters, pattern('^a-cx-zA-CX-Z1-37-9')),
  "pattern('^a-z')": tester(characters, pattern('^a-z')),
  "pattern('^acegik')": tester(characters, pattern('^acegik')),
  "pattern('a')": tester(characters, pattern('a')),
  "pattern('a-cx-zA-CX-Z1-37-9')": tester(characters, pattern('a-cx-zA-CX-Z1-37-9')),
  "pattern('a-z')": tester(characters, pattern('a-z')),
  "pattern('acegik')": tester(characters, pattern('acegik')),
  "range('a', 'z')": tester(characters, range('a', 'z')),
  "uppercase()": tester(characters, uppercase()),
  "whitespace()": tester(characters, whitespace()),
  "word()": tester(characters, word()),
};

void main() {
  print('<?xml version="1.0"?>');
  print('<benchmarks>');
  for (var name in benchmarks.keys) {
    print('  <benchmark name="$name">${benchmark(benchmarks[name])}</benchmark>');
  }
  print('</benchmarks>');
}

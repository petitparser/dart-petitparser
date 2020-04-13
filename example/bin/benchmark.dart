library petitparser.example.benchmark;

double benchmark(Function function, {int minMillis = 2000}) {
  _benchmark(function, 100);
  return _benchmark(function, minMillis);
}

double _benchmark(Function function, int minMillis) {
  final minMicros = 1000 * minMillis;
  final watch = Stopwatch();
  var count = 0;
  var elapsed = 0;
  watch.start();
  while (elapsed < minMicros) {
    function();
    elapsed = watch.elapsedMicroseconds;
    count++;
  }
  return elapsed / count;
}

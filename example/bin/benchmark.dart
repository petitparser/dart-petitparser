library petitparser.example.benchmark;

double benchmark(Function function,
    [int warmUp = 1000, int milliseconds = 5000]) {
  var count = 0;
  var elapsed = 0;
  final watch = Stopwatch();
  while (warmUp-- > 0) {
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

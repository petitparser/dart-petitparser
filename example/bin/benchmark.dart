library petitparser.example.benchmark;

/// Measures the time it takes to run [function] in microseconds.
///
/// It does so in two steps:
///
///  - the code is warmed up for the duration of [warmup]; and
///  - the code is benchmarked for the duration of [measure].
///
/// The resulting duration is the average time measured to run [function] once.
double benchmark(Function function,
    {Duration warmup = const Duration(milliseconds: 200),
    Duration measure = const Duration(seconds: 2)}) {
  _benchmark(function, warmup);
  return _benchmark(function, measure);
}

double _benchmark(Function function, Duration duration) {
  final watch = Stopwatch();
  final micros = duration.inMicroseconds;
  var count = 0;
  var elapsed = 0;
  watch.start();
  while (elapsed < micros) {
    function();
    elapsed = watch.elapsedMicroseconds;
    count++;
  }
  return elapsed / count;
}

/// Compare the speedup between [reference] and [comparison] in percentage.
///
/// A result of 0 means that both reference and comparison run at the same
/// speed. A positive number signifies a speedup, a negative one a slowdown.
double percentChange(double reference, double comparison) =>
    100 * (reference - comparison) / reference;

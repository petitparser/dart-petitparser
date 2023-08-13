import '../../core/result.dart';

/// Function definition that joins parse [Failure] instances.
typedef FailureJoiner = Failure Function(Failure first, Failure second);

/// Reports the first parse failure observed.
Failure selectFirst(Failure first, Failure second) => first;

/// Reports the last parse failure observed (default).
Failure selectLast(Failure first, Failure second) => second;

/// Reports the parser failure farthest down in the input string, preferring
/// later failures over earlier ones.
Failure selectFarthest(Failure first, Failure second) =>
    first.position <= second.position ? second : first;

/// Reports the parser failure farthest down in the input string, joining
/// error messages at the same position.
Failure selectFarthestJoined(Failure first, Failure second) =>
    first.position > second.position
        ? first
        : first.position < second.position
            ? second
            : first.failure('${first.message} OR ${second.message}');

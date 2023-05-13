import '../../core/result.dart';

/// Function definition that joins parse [Failure] instances.
typedef FailureJoiner<R> = Failure<R> Function(
    Failure<R> first, Failure<R> second);

/// Reports the first parse failure observed.
Failure<R> selectFirst<R>(Failure<R> first, Failure<R> second) => first;

/// Reports the last parse failure observed (default).
Failure<R> selectLast<R>(Failure<R> first, Failure<R> second) => second;

/// Reports the parser failure farthest down in the input string, preferring
/// later failures over earlier ones.
Failure<R> selectFarthest<R>(Failure<R> first, Failure<R> second) =>
    first.position <= second.position ? second : first;

/// Reports the parser failure farthest down in the input string, joining
/// error messages at the same position.
Failure<R> selectFarthestJoined<R>(Failure<R> first, Failure<R> second) =>
    first.position > second.position
        ? first
        : first.position < second.position
            ? second
            : first.failure<R>('${first.message} OR ${second.message}');

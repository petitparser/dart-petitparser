import 'dart:math';

/// A list of [elements] and its [separators].
class SeparatedList<R, S> {
  SeparatedList(this.elements, this.separators)
      : assert(
          max(0, elements.length - 1) == separators.length,
          'Inconsistent number of elements ($elements) and separators ($separators)',
        );

  /// The parsed elements.
  final List<R> elements;

  /// The parsed separators.
  final List<S> separators;

  /// An (untyped) iterable over the [elements] and the interleaved [separators]
  /// in order of appearance.
  Iterable<dynamic /* R | S */ > get sequential sync* {
    for (var i = 0; i < elements.length; i++) {
      yield elements[i];
      if (i < separators.length) {
        yield separators[i];
      }
    }
  }

  /// Combines the [elements] by grouping the elements from the left and
  /// calling [callback] on all consecutive elements with the corresponding
  /// `separator`.
  ///
  /// For example, if the elements are numbers and the separators are
  /// subtraction operations sequential values `1 - 2 - 3` are grouped like
  /// `(1 - 2) - 3`.
  R foldLeft(R Function(R left, S seperator, R right) callback) {
    var result = elements.first;
    for (var i = 1; i < elements.length; i++) {
      result = callback(result, separators[i - 1], elements[i]);
    }
    return result;
  }

  /// Combines the [elements] by grouping the elements from the right and
  /// calling [callback] on all consecutive elements with the corresponding
  /// `separator`.
  ///
  /// For example, if the elements are numbers and the separators are
  /// exponentiation operations sequential values `1 ^ 2 ^ 3` are grouped like
  /// `1 ^ (2 ^ 3)`.
  R foldRight(R Function(R left, S seperator, R right) callback) {
    var result = elements.last;
    for (var i = elements.length - 2; i >= 0; i--) {
      result = callback(elements[i], separators[i], result);
    }
    return result;
  }

  @override
  String toString() => 'SeparatedList$sequential';
}

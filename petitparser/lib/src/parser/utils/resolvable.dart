import '../../core/parser.dart';

/// Interface of a parser that can be resolved to another one.
abstract class ResolvableParser<R> implements Parser<R> {
  Parser<R> resolve();
}

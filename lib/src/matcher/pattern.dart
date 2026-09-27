import '../core/parser.dart';
import 'pattern/parser_pattern.dart';

/// Extension on [Parser] to convert it to a [Pattern].
extension PatternParserExtension<R> on Parser<R> {
  /// Converts this [Parser] into a [Pattern] for basic searches within strings.
  Pattern toPattern() => ParserPattern(this);
}

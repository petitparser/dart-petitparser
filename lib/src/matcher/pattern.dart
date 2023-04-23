import '../core/parser.dart';
import 'pattern/parser_pattern.dart';

extension PatternParserExtension<R> on Parser<R> {
  /// Converts this [Parser] into a [Pattern] for basic searches within strings.
  Pattern toPattern() => ParserPattern(this);
}

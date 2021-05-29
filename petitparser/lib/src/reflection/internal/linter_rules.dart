import '../../core/parser.dart';
import '../../parser/combinator/choice.dart';
import '../../parser/combinator/settable.dart';
import '../../parser/misc/failure.dart';
import '../../parser/utils/resolvable.dart';
import '../analyzer.dart';
import '../linter.dart';

void unresolvedSettable(
    Analyzer analyzer, Parser parser, LinterCallback callback) {
  if (parser is SettableParser && parser.delegate is FailureParser) {
    callback(
        parser,
        LinterType.error,
        'Unresolved settable',
        'This error is typically a bug in the code where a recursive '
            'grammar was created with `undefined()` that has not been '
            'resolved.');
  }
}

void unnecessaryResolvable(
    Analyzer analyzer, Parser parser, LinterCallback callback) {
  if (parser is ResolvableParser) {
    callback(
        parser,
        LinterType.warning,
        'Unnecessary resolvable',
        'Resolvable parsers are used during construction of recursive '
            'grammars. While they typically dispatch to their delegate, '
            'they add unnecessary overhead that can be avoided by removing '
            'them before parsing using `resolve(parser)`.',
        () => analyzer.replaceAll(parser, parser.resolve()));
  }
}

void nestedChoice(Analyzer analyzer, Parser parser, LinterCallback callback) {
  if (parser is ChoiceParser) {
    for (var i = 0; i < parser.children.length - 1; i++) {
      if (parser.children[i] is ChoiceParser) {
        callback(
            parser,
            LinterType.info,
            'Nested choice',
            'The choice at index $i is another choice that adds unnecessary '
                'overhead that can be avoided by flattening it into the '
                'parent.',
            () => analyzer.replaceAll(
                parser,
                [
                  ...parser.children.sublist(0, i - 1),
                  ...parser.children[i].children,
                  ...parser.children.sublist(i + 1),
                ].toChoiceParser()));
        return;
      }
    }
  }
}

void unreachableChoice(
    Analyzer analyzer, Parser parser, LinterCallback callback) {
  if (parser is ChoiceParser) {
    for (var i = 0; i < parser.children.length - 1; i++) {
      if (analyzer.isNullable(parser.children[i])) {
        callback(
            parser,
            LinterType.info,
            'Unreachable choice',
            'The choice at index $i is nullable, therefore the choices '
                'after that can never be reached and can be removed.',
            () => analyzer.replaceAll(
                parser, parser.children.sublist(0, i).toChoiceParser()));
      }
    }
  }
}

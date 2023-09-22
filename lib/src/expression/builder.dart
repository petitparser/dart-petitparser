import 'package:meta/meta.dart';

import '../core/parser.dart';
import '../parser/combinator/settable.dart';
import '../reflection/iterable.dart';
import 'group.dart';
import 'utils.dart';

/// A builder that allows the simple definition of expression grammars with
/// prefix, postfix, and left- and right-associative infix operators.
///
/// The following code creates the empty expression builder producing values of
/// type [num]:
///
///     final builder = ExpressionBuilder<num>();
///
/// Every [ExpressionBuilder] needs to define at least one primitive type to
/// parse. In this example these are the literal numbers. The mapping function
/// converts the string input into an actual number.
///
///     builder.primitive(digit()
///         .plus()
///         .seq(char('.').seq(digit().plus()).optional())
///         .flatten()
///         .trim()
///         .map(num.parse));
///
/// Then we define the operator-groups in descending precedence. The highest
/// precedence have parentheses. The mapping function receives both the opening
/// parenthesis, the value, and the closing parenthesis as arguments:
///
///     builder.group().wrapper(
///         char('(').trim(), char(')').trim(), (left, value, right) => value);
///
/// Then come the normal arithmetic operators. We are using
/// [cascade notation](https://dart.dev/guides/language/language-tour#cascade-notation)
/// to define multiple operators on the same precedence-group. The mapping
/// functions receive both, the terms and the parsed operator in the order they
/// appear in the parsed input:
///
///     // Negation is a prefix operator.
///     builder.group().prefix(char('-').trim(), (operator, value) => -value);
///
///     // Power is right-associative.
///     builder.group().right(char('^').trim(), (left, operator, right) => math.pow(left, right));
///
///     // Multiplication and addition are left-associative, multiplication has
///     // higher priority than addition.
///     builder.group()
///       ..left(char('*').trim(), (left, operator, right) => left * right)
///       ..left(char('/').trim(), (left, operator, right) => left / right);
///     builder.group()
///       ..left(char('+').trim(), (left, operator, right) => left + right)
///       ..left(char('-').trim(), (left, operator, right) => left - right);
///
/// Finally we can build the parser:
///
///     final parser = builder.build();
///
/// After executing the above code we get an efficient parser that correctly
/// evaluates expressions like:
///
///     parser.parse('-8');      // -8
///     parser.parse('1+2*3');   // 7
///     parser.parse('1*2+3');   // 5
///     parser.parse('8/4/2');   // 2
///     parser.parse('2^2^3');   // 256
///
class ExpressionBuilder<T> {
  final List<Parser<T>> _primitives = [];
  final List<ExpressionGroup<T>> _groups = [];
  final SettableParser<T> _loopback = undefined();

  /// Defines a new primitive, literal, or value [parser].
  void primitive(Parser<T> parser) => _primitives.add(parser);

  /// Creates a new group of operators that share the same priority.
  @useResult
  ExpressionGroup<T> group() {
    final group = ExpressionGroup<T>(_loopback);
    _groups.add(group);
    return group;
  }

  /// Builds the expression parser.
  @useResult
  Parser<T> build() {
    final primitives = <Parser<T>>[
      ..._primitives,
      ..._groups.expand((group) => group.primitives),
    ];
    assert(primitives.isNotEmpty, 'At least one primitive parser expected');
    final parser = _groups.fold<Parser<T>>(
      buildChoice(primitives),
      (parser, group) => group.build(parser),
    );
    // Replace all uses of `_loopback` with `parser`. Do not use `resolve()`
    // because that might try to resolve unrelated parsers outside of the scope
    // of the `ExpressionBuilder` and cause infinite recursion.
    for (final parent in allParser(parser)) {
      parent.replace(_loopback, parser);
    }
    // Also update the loopback parser, just in case somebody keeps a reference
    // to it (not that anybody should do that).
    _loopback.set(parser);
    return parser;
  }
}

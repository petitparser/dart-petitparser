library petitparser.example.prolog.parser;

import 'package:petitparser/petitparser.dart';

import 'evaluator.dart';
import 'grammar.dart';

/// The standard prolog parser definition.
final PrologParserDefinition definition_ = PrologParserDefinition();

/// The standard prolog parser to read rules.
final Parser<List<Rule>> rulesParser =
    definition_.build(start: definition_.rules);

/// The standard prolog parser to read queries.
final Parser<Term> termParser = definition_.build(start: definition_.term);

/// LISP parser definition.
class PrologParserDefinition extends PrologGrammarDefinition {
  final Map<String, Variable> scope = {};

  Parser<List<Rule>> rules() => super.rules().castList();

  Parser<Rule> rule() => super.rule().map((each) {
        scope.clear();
        final Term head = each[0];
        final List rest = each[1];
        if (rest == null) {
          return Rule(head, const Value('true'));
        }
        final List terms = rest[1];
        if (terms.isEmpty) {
          return Rule(head, const Value('true'));
        } else if (terms.length == 1) {
          return Rule(head, terms[0]);
        } else {
          return Rule(head, Conjunction(terms.cast()));
        }
      });

  Parser<Term> term() => super.term().map((each) {
        final Node name = each[0];
        final List rest = each[1];
        if (rest == null) {
          return Term(name.toString(), const []);
        }
        final List terms = rest[1];
        return Term(name.toString(), terms.cast());
      });

  Parser<Node> parameter() => super.parameter().map((each) {
        final Node name = each[0];
        final List rest = each[1];
        if (rest == null) {
          return name;
        }
        final List terms = rest[1];
        return Term(name.toString(), terms.cast());
      });

  Parser<Variable> variable() => super.variable().map((name) {
        if (name == '_') {
          return const Variable('_');
        }
        if (scope.containsKey(name)) {
          return scope[name];
        }
        return scope[name] = Variable(name);
      });

  Parser<Value> value() => super.value().map((name) => Value(name));
}

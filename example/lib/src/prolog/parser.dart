library petitparser.example.prolog.parser;

import 'package:example/src/prolog/evaluator.dart';
import 'package:example/src/prolog/grammar.dart';
import 'package:petitparser/petitparser.dart';

/// The standard prolog parser defintion.
final PrologParserDefinition definition_ = PrologParserDefinition();

/// The standard prolog parser to read rules.
final Parser<Database> rulesParser =
    definition_.build(start: definition_.rules);

/// The standard prolog parser to read queries.
final Parser<Term> queryParser = definition_.build(start: definition_.term);

/// LISP parser definition.
class PrologParserDefinition extends PrologGrammarDefinition {
  Parser<Database> rules() => super.rules().map((rules) => Database(rules));

  Parser<Rule> rule() => super.rule().map((each) {
        final Term head = each[0];
        final List rest = each[1];
        if (rest == null) {
          return Rule(head, True());
        }
        final List<Term> terms = rest[1];
        if (terms.isEmpty) {
          return Rule(head, True());
        } else if (terms.length == 1) {
          return Rule(head, terms[0]);
        } else {
          return Rule(head, Conjunction(terms.cast()));
        }
      });

  Parser<Term> term() => super.term().map((each) {
        final String name = each[0];
        final List rest = each[1];
        if (rest == null) {
          return Term(name, []);
        }
        final List<Term> terms = rest[1];
        return Term(name, terms.cast());
      });

  Parser<Variable> atom() => super.atom().map((value) => Variable(value));
}

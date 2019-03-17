library petitparser.example.prolog.evaluator;

import 'package:more/iterable.dart';
import 'package:example/src/prolog/parser.dart';
import 'package:collection/collection.dart';

const argumentEquality = ListEquality();

Map<Variable, Node> mergeBindings(
  Map<Variable, Node> first,
  Map<Variable, Node> second,
) {
  if (first == null || second == null) {
    return null;
  }
  final result = Map.of(first);
  for (final key in second.keys) {
    final value = second[key];
    final other = result[key];
    if (other != null) {
      final subs = other.match(value);
      if (subs == null) {
        return null;
      } else {
        result.addAll(subs);
      }
    } else {
      result[key] = value;
    }
  }
  return result;
}

class Database {
  final List<Rule> rules;

  factory Database.parse(String rules) =>
      Database(rulesParser.parse(rules).value);

  Database(Iterable<Rule> rules) : rules = List.of(rules, growable: false);

  Stream<Node> query(Term goal) async* {
    for (final rule in rules) {
      yield* rule.query(this, goal);
    }
  }

  @override
  String toString() => rules.join('\n');
}

class Rule {
  final Node head;
  final Term body;

  Rule(this.head, this.body);

  Stream<Node> query(Database database, Term goal) async* {
    final match = head.match(goal);
    if (match != null) {
      final headSubs = head.substitute(match);
      final bodySubs = body.substitute(match);
      if (bodySubs is Term) {
        yield* bodySubs
            .query(database)
            .map((item) => headSubs.substitute(bodySubs.match(item)));
      }
    }
  }

  @override
  String toString() => '$head :- $body.';
}

abstract class Node {
  const Node();

  Map<Variable, Node> match(Node other);

  Node substitute(Map<Variable, Node> bindings);
}

class Variable extends Node {
  final String name;

  const Variable(this.name);

  @override
  Map<Variable, Node> match(Node other) {
    final bindings = <Variable, Node>{};
    if (this != other) {
      bindings[this] = other;
    }
    return bindings;
  }

  @override
  Node substitute(Map<Variable, Node> bindings) {
    final value = bindings[this];
    if (value != null) {
      return value.substitute(bindings);
    }
    return this;
  }

  @override
  bool operator ==(Object other) => other is Variable && name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => name;
}

class Term extends Node {
  final String name;
  final List<Node> args;

  factory Term.parse(String rules) => termParser.parse(rules).value;

  factory Term(String name, Iterable<Node> list) =>
      Term._(name, list.toList(growable: false));

  const Term._(this.name, this.args);

  Stream<Node> query(Database database) => database.query(this);

  @override
  Map<Variable, Node> match(Node other) {
    if (other is Term) {
      if (name != other.name) {
        return null;
      }
      if (args.length != other.args.length) {
        return null;
      }
      return zip([args, other.args])
          .map((arg) => arg[0].match(arg[1]))
          .fold(<Variable, Node>{}, mergeBindings);
    }
    return other.match(this);
  }

  @override
  Node substitute(Map<Variable, Node> bindings) =>
      Term(name, args.map((arg) => arg.substitute(bindings)));

  @override
  bool operator ==(Object other) =>
      other is Term &&
      name == other.name &&
      argumentEquality.equals(args, other.args);

  @override
  int get hashCode => name.hashCode ^ argumentEquality.hash(args);

  @override
  String toString() => args.isEmpty ? '$name' : '$name(${args.join(', ')})';
}

class Value extends Term {
  const Value(String name) : super._(name, const []);

  @override
  Stream<Node> query(Database database) => Stream.fromIterable([this]);

  @override
  Node substitute(Map<Variable, Node> bindings) => this;

  @override
  bool operator ==(Object other) => other is Value && name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => name;
}

class Conjunction extends Term {
  factory Conjunction(Iterable<Node> list) =>
      Conjunction._(list.toList(growable: false));

  const Conjunction._(List<Node> args) : super._('', args);

  @override
  Stream<Node> query(Database database) async* {
    Stream<Node> solutions(int index, Map<Variable, Node> bindings) async* {
      if (index < args.length) {
        final arg = args[index];
        yield* database.query(arg.substitute(bindings)).asyncExpand((item) {
          final unified = mergeBindings(arg.match(item), bindings);
          return unified == null
              ? const Stream.empty()
              : solutions(index + 1, unified);
        });
      } else {
        yield substitute(bindings);
      }
    }

    yield* solutions(0, {});
  }

  @override
  Node substitute(Map<Variable, Node> bindings) {
    return Conjunction(args.map((arg) => arg.substitute(bindings)));
  }

  @override
  bool operator ==(Object other) =>
      other is Conjunction && argumentEquality.equals(args, other.args);

  @override
  int get hashCode => argumentEquality.hash(args);

  @override
  String toString() => args.join(', ');
}

library petitparser.example.prolog.evaluator;

import 'package:collection/collection.dart';
import 'package:example/src/prolog/parser.dart';
import 'package:more/iterable.dart';

const Equality<List<Node>> argumentEquality = ListEquality();

Map<Variable, Node> newBindings() => Map<Variable, Node>.identity();

Map<Variable, Node> mergeBindings(
  Map<Variable, Node> first,
  Map<Variable, Node> second,
) {
  if (first == null || second == null) {
    return null;
  }
  final result = newBindings();
  result.addAll(first);
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
  final Map<String, List<Rule>> rules = {};

  factory Database.parse(String rules) =>
      Database(rulesParser.parse(rules).value);

  Database(Iterable<Rule> rules) {
    for (final rule in rules) {
      this.rules.putIfAbsent(rule.head.name, () => []).add(rule);
    }
  }

  Stream<Node> query(Term goal) async* {
    final candidates = rules[goal.name];
    if (candidates != null) {
      for (final rule in candidates) {
        yield* rule.query(this, goal);
      }
    }
  }

  @override
  String toString() =>
      rules.values.map((rules) => rules.join('\n')).join('\n\n');
}

class Rule {
  final Term head;
  final Term body;

  Rule(this.head, this.body);

  Stream<Node> query(Database database, Term goal) async* {
    final match = head.match(goal);
    if (match != null) {
      final newHead = head.substitute(match);
      final newBody = body.substitute(match);
      await for (final item in newBody.query(database)) {
        yield newHead.substitute(newBody.match(item));
      }
    }
  }

  @override
  String toString() => '$head :- $body.';
}

abstract class Node {
  Node();

  Map<Variable, Node> match(Node other);

  Node substitute(Map<Variable, Node> bindings);
}

class Variable extends Node {
  final String name;

  Variable(this.name);

  @override
  Map<Variable, Node> match(Node other) {
    final bindings = newBindings();
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
  final List<Node> arguments;

  factory Term.parse(String rules) => termParser.parse(rules).value;

  factory Term(String name, Iterable<Node> list) =>
      Term._(name, list.toList(growable: false));

  Term._(this.name, this.arguments);

  Stream<Node> query(Database database) async* {
    yield* database.query(this);
  }

  @override
  Map<Variable, Node> match(Node other) {
    if (other is Term) {
      if (name != other.name) {
        return null;
      }
      if (arguments.length != other.arguments.length) {
        return null;
      }
      return zip([arguments, other.arguments])
          .map((arg) => arg[0].match(arg[1]))
          .fold(newBindings(), mergeBindings);
    }
    return other.match(this);
  }

  @override
  Term substitute(Map<Variable, Node> bindings) =>
      Term(name, arguments.map((arg) => arg.substitute(bindings)));

  @override
  bool operator ==(Object other) =>
      other is Term &&
      name == other.name &&
      argumentEquality.equals(arguments, other.arguments);

  @override
  int get hashCode => name.hashCode ^ argumentEquality.hash(arguments);

  @override
  String toString() =>
      arguments.isEmpty ? '$name' : '$name(${arguments.join(', ')})';
}

class Value extends Term {
  Value(String name) : super._(name, const []);

  @override
  Stream<Node> query(Database database) async* {
    yield this;
  }

  @override
  Value substitute(Map<Variable, Node> bindings) => this;

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

  Conjunction._(List<Node> args) : super._(',', args);

  @override
  Stream<Node> query(Database database) async* {
    Stream<Node> solutions(int index, Map<Variable, Node> bindings) async* {
      if (index < arguments.length) {
        final arg = arguments[index];
        final subs = arg.substitute(bindings);
        await for (final item in database.query(subs)) {
          final unified = mergeBindings(arg.match(item), bindings);
          if (unified != null) {
            yield* solutions(index + 1, unified);
          }
        }
      } else {
        yield substitute(bindings);
      }
    }

    yield* solutions(0, newBindings());
  }

  @override
  Conjunction substitute(Map<Variable, Node> bindings) =>
      Conjunction(arguments.map((arg) => arg.substitute(bindings)));

  @override
  bool operator ==(Object other) =>
      other is Conjunction &&
      argumentEquality.equals(arguments, other.arguments);

  @override
  int get hashCode => argumentEquality.hash(arguments);

  @override
  String toString() => arguments.join(', ');
}

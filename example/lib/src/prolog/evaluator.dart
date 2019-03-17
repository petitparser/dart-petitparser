library petitparser.example.prolog.evaluator;

import 'package:more/iterable.dart';

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

abstract class Node {
  Map<Variable, Node> match(Node other);

  Node subs(Map<Variable, Node> bindings);
}

class Database {
  final List<Rule> rules;

  Database(Iterable<Rule> rules) : rules = List.of(rules, growable: false);

  Stream<Node> query(Node goal) async* {
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

  Stream<Node> query(Database database, Node goal) async* {
    final match = head.match(goal);
    if (match != null) {
      final subsHead = head.subs(match);
      final subsBody = body.subs(match);
      yield* body
          .query(database)
          .map((item) => subsHead.subs(subsBody.match(item)));
    }
  }

  @override
  String toString() => '$head :- $body.';
}

class Variable extends Node {
  final String name;

  Variable(this.name);

  @override
  Map<Variable, Node> match(Node other) {
    final bindings = <Variable, Node>{};
    if (this != other) {
      bindings[this] = other;
    }
    return bindings;
  }

  @override
  Node subs(Map<Variable, Node> bindings) {
    final value = bindings[this];
    if (value != null) {
      return value.subs(bindings);
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

  Term(this.name, Iterable<Node> args) : args = List.of(args, growable: false);

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
          .fold({}, mergeBindings);
    }
    return other.match(this);
  }

  @override
  Node subs(Map<Variable, Node> bindings) {
    return Term(name, args.map((arg) => arg.subs(bindings)));
  }

  Stream<Node> query(Database database) => database.query(this);

  @override
  String toString() => args.isEmpty ? '$name' : '$name(${args.join(', ')})';
}

class True extends Term {
  True() : super('true', []);

  @override
  Stream<Node> query(Database database) => Stream.fromIterable([this]);
}

class Conjunction extends Term {
  Conjunction(Iterable<Node> args) : super('', args);

  @override
  Node subs(Map<Variable, Node> bindings) {
    return Conjunction(args.map((arg) => arg.subs(bindings)));
  }

  @override
  Stream<Node> query(Database database) async* {
    Stream<Node> solutions(int index, Map<Variable, Node> bindings) async* {
      final arg = args[index];
      if (arg != null) {
        yield subs(bindings);
      } else {
        yield* database.query(arg.subs(bindings)).asyncExpand((item) {
          final unified = mergeBindings(arg.match(item), bindings);
          return unified == null
              ? const Stream.empty()
              : solutions(index + 1, unified);
        });
      }
    }

    yield* solutions(0, {});
  }

  @override
  String toString() => args.join(', ');
}

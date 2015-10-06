part of petitparser;

/// A builder that allows the simple definition of expression grammars with
/// prefix, postfix, and left- and right-associative infix operators.
///
/// The following code creates the empty expression builder:
///
///     var builder = new ExpressionBuilder();
///
/// Then we define the operator-groups in descending precedence. The highest
/// precedence have the literal numbers themselves:
///
///     builder.group()
///       ..primitive(digit().plus()
///         .seq(char('.').seq(digit().plus()).optional())
///         .flatten().trim().map((a) => double.parse(a)));
///
/// Then come the normal arithmetic operators. Note, that the action blocks receive
/// both, the terms and the parsed operator in the order they appear in the parsed
/// input.
///
///     // negation is a prefix operator
///     builder.group()
///       ..prefix(char('-').trim(), (op, a) => -a);
///
///     // power is right-associative
///     builder.group()
///       ..right(char('^').trim(), (a, op, b) => math.pow(a, b));
///
///     // multiplication and addition is left-associative
///     builder.group()
///       ..left(char('*').trim(), (a, op, b) => a * b)
///       ..left(char('/').trim(), (a, op, b) => a / b);
///     builder.group()
///       ..left(char('+').trim(), (a, op, b) => a + b)
///       ..left(char('-').trim(), (a, op, b) => a - b);
///
/// Finally we can build the parser:
///
///     var parser = builder.build();
///
/// After executing the above code we get an efficient parser that correctly
/// evaluates expressions like:
///
///     parser.parse('-8');      // -8
///     parser.parse('1+2*3');   // 7
///     parser.parse('1*2+3');   // 5
///     parser.parse('8/4/2');   // 2
///     parser.parse('2^2^3');   // 256
class ExpressionBuilder {
  final List<ExpressionGroup> _groups = new List();

  /// Creates a new group of operators that share the same priority.
  ExpressionGroup group() {
    var group = new ExpressionGroup();
    _groups.add(group);
    return group;
  }

  /// Builds the expression parser.
  Parser build() => _groups.fold(
      failure('Highest priority group should define a primitive parser.'),
      (a, b) => b._build(a));
}

/// Models a group of operators of the same precedence.
class ExpressionGroup {

  /// Defines a new primitive or literal [parser].
  void primitive(Parser parser) {
    _primitives.add(parser);
  }

  Parser _buildPrimitive(Parser inner) {
    return _buildChoice(_primitives, inner);
  }

  final List<Parser> _primitives = new List();

  /// Adds a prefix operator [parser]. Evaluates the optional [action] with the
  /// parsed `operator` and `value`.
  void prefix(Parser parser, [action(operator, value)]) {
    if (action == null) {
      action = (operator, value) => [operator, value];
    }
    _prefix.add(parser.map((operator) => new _ExpressionResult(operator, action)));
  }

  Parser _buildPrefix(Parser inner) {
    if (_prefix.isEmpty) {
      return inner;
    } else {
      return new SequenceParser([_buildChoice(_prefix).star(), inner]).map(
          (tuple) {
        return tuple.first.reversed.fold(tuple.last, (value, result) {
          return result.action(result.operator, value);
        });
      });
    }
  }

  final List<Parser> _prefix = new List();

  /// Adds a postfix operator [parser]. Evaluates the optional [action] with the
  /// parsed `value` and `operator`.
  void postfix(Parser parser, [action(value, operator)]) {
    if (action == null) {
      action = (value, operator) => [value, operator];
    }
    _postfix.add(parser.map((operator) => new _ExpressionResult(operator, action)));
  }

  Parser _buildPostfix(Parser inner) {
    if (_postfix.isEmpty) {
      return inner;
    } else {
      return new SequenceParser([inner, _buildChoice(_postfix).star()]).map(
          (tuple) {
        return tuple.last.fold(tuple.first, (value, result) {
          return result.action(value, result.operator);
        });
      });
    }
  }

  final List<Parser> _postfix = new List();

  /// Adds a right-associative operator [parser]. Evaluates the optional [action] with
  /// the parsed `left` term, `operator`, and `right` term.
  void right(Parser parser, [action(left, operator, right)]) {
    if (action == null) {
      action = (left, operator, right) => [left, operator, right];
    }
    _right.add(parser.map((operator) => new _ExpressionResult(operator, action)));
  }

  Parser _buildRight(Parser inner) {
    if (_right.isEmpty) {
      return inner;
    } else {
      return inner.separatedBy(_buildChoice(_right)).map((sequence) {
        var result = sequence.last;
        for (var i = sequence.length - 2; i > 0; i -= 2) {
          result =
              sequence[i].action(sequence[i - 1], sequence[i].operator, result);
        }
        return result;
      });
    }
  }

  final List<Parser> _right = new List();

  /// Adds a left-associative operator [parser]. Evaluates the optional [action] with
  /// the parsed `left` term, `operator`, and `right` term.
  void left(Parser parser, [action(left, operator, right)]) {
    if (action == null) {
      action = (left, operator, right) => [left, operator, right];
    }
    _left.add(parser.map((operator) => new _ExpressionResult(operator, action)));
  }

  Parser _buildLeft(Parser inner) {
    if (_left.isEmpty) {
      return inner;
    } else {
      return inner.separatedBy(_buildChoice(_left)).map((sequence) {
        var result = sequence.first;
        for (var i = 1; i < sequence.length; i += 2) {
          result =
              sequence[i].action(result, sequence[i].operator, sequence[i + 1]);
        }
        return result;
      });
    }
  }

  final List<Parser> _left = new List();

  // helper to build an optimal choice parser
  Parser _buildChoice(List<Parser> parsers, [Parser otherwise]) {
    if (parsers.isEmpty) {
      return otherwise;
    } else if (parsers.length == 1) {
      return parsers.first;
    } else {
      return new ChoiceParser(parsers);
    }
  }

  // helper to build the group of parsers
  Parser _build(Parser inner) {
    return _buildLeft(_buildRight(_buildPostfix(_buildPrefix(_buildPrimitive(inner)))));
  }
}

// helper class to associate operators and actions
class _ExpressionResult {
  final operator;
  final Function action;
  _ExpressionResult(this.operator, this.action);
}

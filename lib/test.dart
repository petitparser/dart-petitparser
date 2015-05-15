/**
 * This package contains matches to write tests for parsers.
 *
 * Examples:
 *
 *     var json = new JsonParser();
 *
 *     // verifies that the input gets parsed and all input is consumed
 *     expect('{"a": 1}', accepts(new JsonParser()));
 *
 *     // verifies that the input gets parsed to a dictionary and that all input is consumed
 *     expect('{"a": 1}', parses(new JsonParser(), {'a': 1}));
 */

library test_util;

import 'package:matcher/matcher.dart';
import 'package:petitparser/petitparser.dart' hide predicate;

/**
 * Returns a matcher that succeeds if the [parser] accepts the input.
 */
Matcher accept(Parser parser) {
  return parse(parser, predicate((value) => true, 'input'));
}

/**
 * Returns a matcher that succeeds if the [parser] succeeds and accepts the provided [matcher].
 */
Matcher parse(Parser parser, matcher, [int position = -1]) {
  return new _Parse(parser, wrapMatcher(matcher), position);
}

class _Parse extends Matcher {

  final Parser parser;
  final Matcher matcher;
  final int position;

  _Parse(this.parser, this.matcher, this.position);

  @override
  bool matches(item, Map matchState) {
    Result result = parser.parse(item);
    if (result.isFailure) {
      addStateInfo(matchState, {'reason': 'failure', 'result': result});
      return false;
    }
    if (!matcher.matches(result.value, matchState)) {
      addStateInfo(matchState, {'reason': 'matcher', 'result': result});
      return false;
    }
    if (position >= 0 && position != result.value) {
      addStateInfo(matchState, {'reason': 'position', 'result': result});
      return false;
    }
    return true;
  }

  @override
  Description describe(Description description) {
    return description.add('"$parser" accepts ').addDescriptionOf(matcher);
  }

  @override
  Description describeMismatch(item, Description description, Map matchState, bool verbose) {
    description.add('"$parser" produces "${matchState['result']}"');
    switch (matchState['reason']) {
      case 'failure':
        description.add(' which is not accepted');
        return description;
      case 'matcher':
        description.add(' which parse result ');
        var subDescription = new StringDescription();
        matcher.describeMismatch(matchState['result'].value, subDescription,
            matchState['state'], verbose);
        if (subDescription.length > 0) {
          description.add(subDescription.toString());
        } else {
          description.add('doesn\'t match');
          matcher.describe(description);
        }
        return description;
      case 'position':
        description
            .add(' that consumes input to ')
            .add(matchState['result'].position.toString())
            .add(' instead of ')
            .add(position.toString());
        return description;
    }
    throw new Exception('Internal matcher error');
  }
}

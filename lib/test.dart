// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

/**
 * This package contains matches to write test for parsers.
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

import 'package:unittest/matcher.dart';
import 'package:petitparser/petitparser.dart';

/**
 * Returns a matcher that succeeds if the [parser] accepts the input.
 */
Matcher accept(Parser parser) {
  return new _Accept(parser);
}

class _Accept extends Matcher {
  final Parser _parser;
  _Accept(this._parser);
  bool matches(item, Map matchState) {
    return _parser.accept(item);
  }
  Description describe(Description description) {
    return description.add('$_parser to accept input');
  }
}

/**
 * Returns a matcher that succeeds if the [parser] results in [matcher].
 */
Matcher parse(Parser parser, dynamic matcher, [int position = -1]) {
  return new _Parse(parser, wrapMatcher(matcher), position);
}

class _Parse extends Matcher {
  final Parser _parser;
  final Matcher _matcher;
  final int _position;
  _Parse(this._parser, this._matcher, this._position);
  bool matches(item, Map matchState) {
    Result result = _parser.parse(item);
    if (!_matcher.matches(result.value, matchState)) {
      addStateInfo(matchState, {'property': 'value', 'result': result});
      return false;
    }
    if (_position >= 0 && !equals(_position).matches(result.position, matchState)) {
      addStateInfo(matchState, {'property': 'position', 'result': result});
      return false;
    }
    return true;
  }
  Description describe(Description description) {
    return description.add('$_parser to accept ').addDescriptionOf(_matcher);
  }
  Description describeMismatch(item, Description mismatchDescription,
                               Map matchState, bool verbose) {
    mismatchDescription.add('has parse result ').add('"${matchState['result']}"');
    if (matchState['property'] == 'value') {
      mismatchDescription.add(' which parse result ');
      var subDescription = new StringDescription();
      _matcher.describeMismatch(matchState['result'].value, subDescription,
          matchState['state'], verbose);
      if (subDescription.length > 0) {
        mismatchDescription.add(subDescription);
      } else {
        mismatchDescription.add('doesn\'t match');
        _matcher.describe(mismatchDescription);
      }
      return mismatchDescription;
    } else if (matchState['property'] == 'position') {
      mismatchDescription
          .add(' that consumes input to ')
          .add(matchState['result'].position.toString())
          .add(' instead of ')
          .add(_position.toString());
      return mismatchDescription;
    }
    throw new Exception('Internal matcher error');
  }
}
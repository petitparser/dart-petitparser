library test_util;

import 'package:unittest/matcher.dart';
import 'package:petitparser/petitparser.dart';

/** Returns a matcher that succeeds if the [parser] accepts the input. */
Matcher accepts(Parser parser) {
  return new _Accepts(parser);
}

class _Accepts extends BaseMatcher {
  final Parser _parser;
  _Accepts(this._parser);
  bool matches(item, MatchState matchState) {
    return _parser.accept(item);
  }
  Description describe(Description description) {
    return description.add('accepts $_parser');
  }
}

/** Returns a matcher that succeeds if the [parser] results in [matcher]. */
Matcher parses(Parser parser, dynamic matcher, [int position = -1]) {
  return new _Parses(parser, wrapMatcher(matcher), position);
}

class _Parses extends BaseMatcher {
  final Parser parser;
  final Matcher matcher;
  final int position;
  _Parses(this.parser, this.matcher, this.position);
  bool matches(item, MatchState matchState) {
    Result result = parser.parse(item);
    if (!isTrue.matches(result.isSuccess, matchState)) {
      matchState.state = {
                           'innerState': matchState.state,
                           'feature': result.isSuccess,
                           'label': 'success'
                         };
      return false;
    }
    if (!matcher.matches(result.value, matchState)) {
      matchState.state = {
                           'innerState': matchState.state,
                           'feature': result.value,
                           'label': 'result'
                         };
      return false;
    }
    if (position >= 0) {
      if (!equals(position).matches(result.position, matchState)) {
        matchState.state = {
                             'innerState': matchState.state,
                             'feature': result.position,
                             'label': 'position'
                           };
        return false;
      }
    }
    return true;
  }
  Description describe(Description description) {
    return description.add('parses to ').addDescriptionOf(matcher);
  }
  Description describeMismatch(item, Description mismatchDescription,
                               MatchState matchState, bool verbose) {
    mismatchDescription.add(matchState.state['label']).add(' ');
    matcher.describeMismatch(matchState.state['feature'], mismatchDescription,
        matchState.state['innerState'], verbose);
    return mismatchDescription;
  }
}
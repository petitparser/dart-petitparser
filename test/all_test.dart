import 'package:test/test.dart';

import 'context_test.dart' as context_test;
import 'debug_test.dart' as debug_test;
import 'definition_test.dart' as definition_test;
import 'example_test.dart' as example_test;
import 'expression_test.dart' as expression_test;
import 'indent_test.dart' as indent_test;
import 'matcher_test.dart' as matcher_test;
import 'parser_action_test.dart' as parser_action_test;
import 'parser_character_test.dart' as parser_character_test;
import 'parser_combinator_test.dart' as parser_combinator_test;
import 'parser_misc_test.dart' as parser_misc_test;
import 'parser_predicate_test.dart' as parser_predicate_test;
import 'parser_repeater_test.dart' as parser_repeater_test;
import 'reflection_test.dart' as reflection_test;
import 'regression_test.dart' as regression_test;
import 'tutorial_test.dart' as tutorial_test;

void main() {
  group('context', context_test.main);
  group('debug', debug_test.main);
  group('definition', definition_test.main);
  group('example', example_test.main);
  group('expression', expression_test.main);
  group('indent', indent_test.main);
  group('matcher', matcher_test.main);
  group('parser', () {
    group('action', parser_action_test.main);
    group('character', parser_character_test.main);
    group('combinator', parser_combinator_test.main);
    group('misc', parser_misc_test.main);
    group('predicate', parser_predicate_test.main);
    group('repeater', parser_repeater_test.main);
  });
  group('reflection', reflection_test.main);
  group('regression', regression_test.main);
  group('tutorial', tutorial_test.main);
}

library petitparser.test.all_test;

import 'package:test/test.dart';

import 'context_test.dart' as context_test;
import 'debug_test.dart' as debug_test;
import 'definition_test.dart' as definition_test;
import 'expression_test.dart' as expression_test;
import 'matcher_test.dart' as matcher_test;
import 'parser_test.dart' as parser_test;
import 'petitparser_test.dart' as petitparser_test;
import 'reflection_test.dart' as reflection_test;

void main() {
  group('context', context_test.main);
  group('debug', debug_test.main);
  group('definition', definition_test.main);
  group('expression', expression_test.main);
  group('matcher', matcher_test.main);
  group('parser', parser_test.main);
  group('petitparser', petitparser_test.main);
  group('reflection', reflection_test.main);
}

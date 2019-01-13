library petitparser.test.all_test;

import 'package:test/test.dart';

import 'debug_test.dart' as debug_test;
import 'petitparser_test.dart' as petitparser_test;
import 'reflection_test.dart' as reflection_test;

main() {
  group('debug', debug_test.main);
  group('petitparser', petitparser_test.main);
  group('reflection', reflection_test.main);
}

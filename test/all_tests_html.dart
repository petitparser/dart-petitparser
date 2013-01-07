// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

library all_tests_html;

import 'package:unittest/html_enhanced_config.dart';
import 'all_tests.dart' as all;

void main() {
  useHtmlEnhancedConfiguration();
  all.main();
}

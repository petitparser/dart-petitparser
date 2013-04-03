// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

library all_test_html;

import 'package:unittest/html_enhanced_config.dart';
import 'all_test.dart' as all_test;

void main() {
  useHtmlEnhancedConfiguration();
  all_test.main();
}

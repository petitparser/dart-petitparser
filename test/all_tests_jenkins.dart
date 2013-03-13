// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

library all_tests_jenkins;

import 'package:junitconfiguration/junitconfiguration.dart';
import 'all_tests.dart' as all_tests;

void main() {
  JUnitConfiguration.install();
  all_tests.main();
}
// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

#library('all_tests_html');

#import('/Applications/Dart/dart-sdk/lib/unittest/html_enhanced_config.dart');
#import('all_tests.dart', prefix: 'all');

void main() {
  useHtmlEnhancedConfiguration();
  all.main();
}

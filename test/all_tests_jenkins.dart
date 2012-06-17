// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

#library('all_tests_jenkins');

#import('/Applications/Dart/dart-sdk/lib/unittest/unittest.dart');

#import('all_tests.dart', prefix: 'all');

void main() {
  configure(new JenkinsConfiguration());
  all.main();
}

class JenkinsConfiguration extends Configuration {
  void onDone(int passed, int failed, int errors, List<TestCase> results, String uncaughtError) {
    print('<?xml version="1.0" encoding="UTF-8" ?>');
    print('<testsuite name="All tests" tests="${results.length}" failures="$failed" errors="$errors">');
    for (var testcase in results) {
      print('  <testcase name="${_xml(testcase.description)}">');
      if (testcase.result == 'fail') {
        print('    <failure>${_xml(testcase.message)}</failure>');
      } else if (testcase.result == 'error') {
        print('    <error>${_xml(testcase.message)}</error>');
      }
      if (testcase.stackTrace != null && testcase.stackTrace != '') {
        print('    <system-err>${_xml(testcase.stackTrace)}</system-err>');
      }
      print('  </testcase>');
    }
    print('</testsuite>');
  }
}

String _xml(String string) {
  return string.replaceAll('&', '&amp;')
               .replaceAll('<', '&lt;')
               .replaceAll('>', '&gt;')
               .replaceAll('"', '&quot;');
}
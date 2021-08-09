import 'package:meta/meta.dart';
import 'package:petitparser/petitparser.dart';
import 'package:petitparser/reflection.dart';
import 'package:petitparser_examples/src/uri/authority.dart';
import 'package:petitparser_examples/src/uri/query.dart';
import 'package:petitparser_examples/uri.dart';
import 'package:test/test.dart';

final parser = uri.end();

@isTest
void uriTest(String source, Map<Symbol, dynamic> values) {
  test(source, () {
    final result = parser.parse(source);
    expect(result.isSuccess, isTrue, reason: 'isSuccess');
    for (final entry in values.entries) {
      expect(result.value[entry.key], entry.value,
          reason: entry.key.toString());
    }
  });
}

void main() {
  test('linter', () {
    expect(linter(parser), isEmpty);
    expect(linter(authority), isEmpty);
    expect(linter(query), isEmpty);
  });
  uriTest('http://www.ics.uci.edu/pub/ietf/uri/#Related', {
    #scheme: 'http',
    #authority: 'www.ics.uci.edu',
    #username: isNull,
    #password: isNull,
    #hostname: 'www.ics.uci.edu',
    #port: isNull,
    #path: '/pub/ietf/uri/',
    #query: isNull,
    #params: [],
    #fragment: 'Related',
  });
  uriTest('http://a/b/c/d;e?f&g=h', {
    #scheme: 'http',
    #authority: 'a',
    #username: isNull,
    #password: isNull,
    #hostname: 'a',
    #port: isNull,
    #path: '/b/c/d;e',
    #query: 'f&g=h',
    #params: [
      ['f', null],
      ['g', 'h']
    ],
    #fragment: isNull,
  });
  uriTest(r'ftp://www.example.org:22/foo bar/zork<>?\^`{|}', {
    #scheme: 'ftp',
    #authority: 'www.example.org:22',
    #username: isNull,
    #password: isNull,
    #hostname: 'www.example.org',
    #port: '22',
    #path: '/foo bar/zork<>',
    #query: r'\^`{|}',
    #fragment: isNull,
  });
  uriTest('data:text/plain;charset=iso-8859-7,hallo', {
    #scheme: 'data',
    #authority: isNull,
    #username: isNull,
    #password: isNull,
    #hostname: isNull,
    #port: isNull,
    #path: 'text/plain;charset=iso-8859-7,hallo',
    #query: isNull,
    #params: [],
    #fragment: isNull,
  });
  uriTest('https://www.übermäßig.de/müßiggänger', {
    #scheme: 'https',
    #authority: 'www.übermäßig.de',
    #username: isNull,
    #password: isNull,
    #hostname: 'www.übermäßig.de',
    #port: isNull,
    #path: '/müßiggänger',
    #query: isNull,
    #params: [],
    #fragment: isNull,
  });
  uriTest('http:test', {
    #scheme: 'http',
    #authority: isNull,
    #username: isNull,
    #password: isNull,
    #hostname: isNull,
    #port: isNull,
    #path: 'test',
    #query: isNull,
    #params: [],
    #fragment: isNull,
  });
  uriTest(r'file:c:\\foo\\bar.html', {
    #scheme: 'file',
    #authority: isNull,
    #username: isNull,
    #password: isNull,
    #hostname: isNull,
    #port: isNull,
    #path: r'c:\\foo\\bar.html',
    #query: isNull,
    #params: [],
    #fragment: isNull,
  });
  uriTest('file://foo:bar@localhost/test', {
    #scheme: 'file',
    #authority: 'foo:bar@localhost',
    #username: 'foo',
    #password: 'bar',
    #hostname: 'localhost',
    #port: isNull,
    #path: '/test',
    #query: isNull,
    #params: [],
    #fragment: isNull,
  });
}

import 'package:petitparser/petitparser.dart';
import 'package:petitparser/reflection.dart';
import 'package:petitparser_examples/uri.dart';
import 'package:test/test.dart';

final parser = uri.end();

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
    #fragment: 'Related',
  });
  uriTest('http://a/b/c/d;p?q', {
    #scheme: 'http',
    #authority: 'a',
    #username: isNull,
    #password: isNull,
    #hostname: 'a',
    #port: isNull,
    #path: '/b/c/d;p',
    #query: 'q',
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
    #fragment: isNull,
  });
}

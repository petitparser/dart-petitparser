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
  group('https://mathiasbynens.be/demo/url-regex', () {
    for (final input in const [
      'http://foo.com/blah_blah',
      'http://foo.com/blah_blah/',
      'http://foo.com/blah_blah_(wikipedia)',
      'http://foo.com/blah_blah_(wikipedia)_(again)',
      'http://www.example.com/wpstyle/?p=364',
      'https://www.example.com/foo/?bar=baz&inga=42&quux',
      'http://✪df.ws/123',
      'http://userid:password@example.com:8080',
      'http://userid:password@example.com:8080/',
      'http://userid@example.com',
      'http://userid@example.com/',
      'http://userid@example.com:8080',
      'http://userid@example.com:8080/',
      'http://userid:password@example.com',
      'http://userid:password@example.com/',
      'http://142.42.1.1/',
      'http://142.42.1.1:8080/',
      'http://➡.ws/䨹',
      'http://⌘.ws',
      'http://⌘.ws/',
      'http://foo.com/blah_(wikipedia)#cite-1',
      'http://foo.com/blah_(wikipedia)_blah#cite-1',
      'http://foo.com/unicode_(✪)_in_parens',
      'http://foo.com/(something)?after=parens',
      'http://☺.damowmow.com/',
      'http://code.google.com/events/#&product=browser',
      'http://j.mp',
      'ftp://foo.bar/baz',
      'http://foo.bar/?q=Test%20URL-encoded%20stuff',
      'http://مثال.إختبار',
      'http://例子.测试',
      'http://उदाहरण.परीक्षा',
      'http://-.~_!\$&\'()*+,;=:%40:80%2f::::::@example.com',
      'http://1337.net',
      'http://a.b-c.de',
      'http://223.255.255.254',
    ]) {
      test(input, () {
        final result = parser.parse(input);
        expect(result.isSuccess, isTrue);
      });
    }
  });
}

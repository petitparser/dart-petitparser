import 'package:petitparser/petitparser.dart';
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
  uriTest('http://www.ics.uci.edu/pub/ietf/uri/#Related', {
    #scheme: 'http',
    #authority: 'www.ics.uci.edu',
    #path: '/pub/ietf/uri/',
    #query: isNull,
    #fragment: 'Related',
  });
  uriTest('http://a/b/c/d;p?q', {
    #scheme: 'http',
    #authority: 'a',
    #path: '/b/c/d;p',
    #query: 'q',
    #fragment: isNull,
  });
  uriTest(r'ftp://www.example.org/foo bar/zork<>?\^`{|}', {
    #scheme: 'ftp',
    #authority: 'www.example.org',
    #path: '/foo bar/zork<>',
    #query: r'\^`{|}',
    #fragment: isNull,
  });
  uriTest('data:text/plain;charset=iso-8859-7,hallo', {
    #scheme: 'data',
    #authority: isNull,
    #path: 'text/plain;charset=iso-8859-7,hallo',
    #query: isNull,
    #fragment: isNull,
  });
  uriTest('https://www.übermäßig.de/müßiggänger', {
    #scheme: 'https',
    #authority: 'www.übermäßig.de',
    #path: '/müßiggänger',
    #query: isNull,
    #fragment: isNull,
  });
  uriTest('http:test', {
    #scheme: 'http',
    #authority: isNull,
    #path: 'test',
    #query: isNull,
    #fragment: isNull,
  });
  uriTest(r'file:c:\\foo\\bar.html', {
    #scheme: 'file',
    #authority: isNull,
    #path: r'c:\\foo\\bar.html',
    #query: isNull,
    #fragment: isNull,
  });
  uriTest('file://localhost/test', {
    #scheme: 'file',
    #authority: 'localhost',
    #path: '/test',
    #query: isNull,
    #fragment: isNull,
  });
}

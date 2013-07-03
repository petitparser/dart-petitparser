library parser_extension_test;

import 'package:petitparser/petitparser.dart';
import 'package:unittest/unittest.dart';

class _MyExtension {
    until(Parser self, Parser newParser) => self.seq(newParser.neg().star()).seq(newParser);
}

void _initParserExtension() {
    parserExtension = new _MyExtension();
}

void main() {

    _initParserExtension();

    test("custom methods", () {
        var parser = string("/*").until(string("*/")).flatten();
        var result = parser.parse("/* hello, /* extension */");
        expect(result.isSuccess, true);
        expect(result.value, "/* hello, /* extension */");
        expect(result.position, 25);
    });

}

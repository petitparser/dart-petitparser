/// This package contains a complete implementation of [JSON](https://json.org/).
///
/// [JsonParserDefinition] builds a JSON parser for nested Dart objects from a
/// given JSON string. For example the following code prints `{a: 1, b: [2,
/// 3.4], c: false}`:
///
///     final json = new JsonParser();
///     final result = json.parse('{"a": 1, "b": [2, 3.4], "c": false}');
///     print(result.value);  // {a: 1, b: [2, 3.4], c: false}
///
/// The grammar definition [JsonGrammarDefinition] can be subclassed to
/// construct other objects.
import 'src/json/grammar.dart';
import 'src/json/parser.dart';

export 'src/json/grammar.dart';
export 'src/json/parser.dart';

import 'dart:io';

/// Number of parsers that can be combined.
const min = 2;
const max = 9;

/// Ordinal numbers for the sequence.
const ordinals = [
  'first',
  'second',
  'third',
  'fourth',
  'fifth',
  'sixth',
  'seventh',
  'eighth',
  'ninth',
];

/// Implementation file.
File implementationFile(int i) =>
    File('lib/src/parser/combinator/generated/sequence_$i.dart');

/// Test file.
final testFile = File('test/generated/sequence_test.dart');

/// Pretty prints and cleans up a dart file.
Future<void> format(File file) async =>
    Process.run('dart', ['format', '--fix', file.absolute.path]);

/// Generate the variable names.
List<String> generateValues(String prefix, int i) =>
    List.generate(i, (i) => '$prefix${i + 1}');

void generateWarning(StringSink out) {
  out.writeln('// AUTO-GENERATED CODE: DO NOT EDIT');
  out.writeln();
}

Future<void> generateImplementation(int index) async {
  final file = implementationFile(index);
  final out = file.openWrite();
  final parserNames = generateValues('parser', index);
  final resultTypes = generateValues('R', index);
  final resultNames = generateValues('result', index);
  final valueTypes = generateValues('T', index);
  final valueNames = generateValues('\$', index);
  final ordinalNames = ordinals.sublist(0, index);
  final characters =
      List.generate(index, (i) => String.fromCharCode('a'.codeUnitAt(0) + i));

  generateWarning(out);
  out.writeln('import \'package:meta/meta.dart\';');
  out.writeln();
  out.writeln('import \'../../../core/context.dart\';');
  out.writeln('import \'../../../core/parser.dart\';');
  out.writeln('import \'../../../core/result.dart\';');
  out.writeln('import \'../../../shared/annotations.dart\';');
  out.writeln('import \'../../action/map.dart\';');
  out.writeln('import \'../../utils/sequential.dart\';');
  out.writeln();

  // Constructor function.
  out.writeln('/// Creates a [Parser] that consumes the $index parsers passed '
      'as argument in ');
  out.writeln('/// sequence and returns a [Record] with $index positional '
      'parse results.');
  out.writeln('///');
  out.writeln('/// For example,');
  out.writeln('/// the parser `seq$index('
      '${characters.map((char) => 'char(\'$char\')').join(', ')})`');
  out.writeln('/// returns `('
      '${characters.map((char) => '\'$char\'').join(', ')})`');
  out.writeln('/// for the input `\'${characters.join()}\'`.');
  out.writeln('@useResult');
  out.writeln('Parser<(${resultTypes.join(', ')})> '
      'seq$index<${resultTypes.join(', ')}>(');
  for (var i = 0; i < index; i++) {
    out.writeln('Parser<${resultTypes[i]}> ${parserNames[i]},');
  }
  out.writeln(') => SequenceParser$index<${resultTypes.join(', ')}>('
      '${parserNames.join(', ')});');
  out.writeln();

  // Converter extension.
  out.writeln('/// Extensions on a [Record] with $index positional [Parser]s.');
  out.writeln('extension RecordOfParsersExtension$index'
      '<${resultTypes.join(', ')}> on '
      '(${resultTypes.map((type) => 'Parser<$type>').join(', ')}) {');
  out.writeln('/// Converts a [Record] of $index positional parsers to a '
      '[Parser] that runs the');
  out.writeln('/// parsers in sequence and returns a [Record] with $index '
      'positional parse results.');
  out.writeln('///');
  out.writeln('/// For example,');
  out.writeln('/// the parser `('
      '${characters.map((char) => 'char(\'$char\')').join(', ')})'
      '.toSequenceParser()`');
  out.writeln('/// returns `('
      '${characters.map((char) => '\'$char\'').join(', ')})`');
  out.writeln('/// for the input `\'${characters.join()}\'`.');
  out.writeln('@useResult');
  out.writeln('Parser<(${resultTypes.join(', ')})> toSequenceParser() => ');
  out.writeln('SequenceParser$index<${resultTypes.join(', ')}>('
      '${valueNames.join(', ')});');
  out.writeln('}');
  out.writeln();

  // Parser implementation.
  out.writeln('/// A parser that consumes a sequence of $index parsers and '
      'returns a [Record] with ');
  out.writeln('/// $index positional parse results.');
  out.writeln('class SequenceParser$index<${resultTypes.join(', ')}> '
      'extends Parser<(${resultTypes.join(', ')})> '
      'implements SequentialParser {');
  out.writeln('SequenceParser$index('
      '${parserNames.map((each) => 'this.$each').join(', ')});');
  out.writeln();
  for (var i = 0; i < index; i++) {
    out.writeln('Parser<${resultTypes[i]}> ${parserNames[i]};');
  }
  out.writeln();
  out.writeln('@override');
  out.writeln('Result<(${resultTypes.join(', ')})> '
      'parseOn(Context context) {');
  for (var i = 0; i < index; i++) {
    out.writeln('final ${resultNames[i]} = ${parserNames[i]}'
        '.parseOn(${i == 0 ? 'context' : resultNames[i - 1]});');
    out.writeln('if (${resultNames[i]} is Failure) '
        'return ${resultNames[i]};');
  }
  out.writeln('return ${resultNames[index - 1]}.success('
      '(${resultNames.map((each) => '$each.value').join(', ')}));');
  out.writeln('}');
  out.writeln();
  out.writeln('@override');
  out.writeln('int fastParseOn(String buffer, int position) {');
  for (var i = 0; i < index; i++) {
    out.writeln('position = ${parserNames[i]}.fastParseOn(buffer, position);');
    out.writeln('if (position < 0) return -1;');
  }
  out.writeln('return position;');
  out.writeln('}');
  out.writeln();
  out.writeln('@override');
  out.writeln('List<Parser> get children => [${parserNames.join(', ')}];');
  out.writeln();
  out.writeln('@override');
  out.writeln('void replace(Parser source, Parser target) {');
  out.writeln('super.replace(source, target);');
  for (var i = 0; i < index; i++) {
    out.writeln('if (${parserNames[i]} == source) '
        '${parserNames[i]} = target as Parser<${resultTypes[i]}>;');
  }
  out.writeln('}');
  out.writeln();
  out.writeln('@override');
  out.writeln('SequenceParser$index<${resultTypes.join(', ')}> copy() => '
      'SequenceParser$index<${resultTypes.join(', ')}>'
      '(${parserNames.join(', ')});');
  out.writeln('}');
  out.writeln();

  // Extension on a [Record] with values.
  out.writeln('/// Extension on a [Record] with $index positional values.');
  out.writeln(
      'extension RecordOfValuesExtension$index<${valueTypes.join(', ')}> on '
      '(${valueTypes.join(', ')}) {');
  for (var i = 0; i < index; i++) {
    out.writeln('/// Returns the ${ordinalNames[i]} element of this record.');
    out.writeln('@inlineVm @inlineJs');
    out.writeln('@Deprecated(r\'Instead use the canonical accessor '
        '${valueNames[i]}\')');
    out.writeln('${valueTypes[i]} get ${ordinalNames[i]} => ${valueNames[i]};');
    out.writeln();
  }
  out.writeln('/// Returns the last element of this record.');
  out.writeln('@inlineVm @inlineJs');
  out.writeln('@Deprecated(r\'Instead use the canonical accessor '
      '${valueNames.last}\')');
  out.writeln('${valueTypes.last} get last => ${valueNames.last};');
  out.writeln();
  out.writeln('/// Converts this [Record] with $index positional values to '
      'a new type [R] using');
  out.writeln('/// the provided [callback] with $index positional arguments.');
  out.writeln('@inlineVm @inlineJs');
  out.writeln('R map<R>(R Function(${valueTypes.join(', ')}) callback) => '
      'callback(${valueNames.join(', ')});');
  out.writeln('}');
  out.writeln();

  // Extension on a [Parser] producing a [Record] of values.
  out.writeln('/// Extension on a [Parser] producing a [Record] of $index '
      'positional values.');
  out.writeln('extension RecordParserExtension$index<${valueTypes.join(', ')}>'
      ' on Parser<(${valueTypes.join(', ')})> {');
  out.writeln('/// Maps a parsed [Record] to [R] using the provided '
      '[callback], see ');
  out.writeln('/// [MapParserExtension.map] for details.');
  out.writeln('@useResult');
  out.writeln('Parser<R> map$index<R>('
      'R Function(${valueTypes.join(', ')}) callback, '
      '{bool hasSideEffects = false}) => '
      'map((record) => record.map(callback), hasSideEffects: hasSideEffects);');
  out.writeln('}');
  out.writeln();

  await out.close();
  await format(file);
}

Future<void> generateTest() async {
  final file = testFile;
  final out = file.openWrite();
  generateWarning(out);
  out.writeln('import \'package:petitparser/petitparser.dart\';');
  out.writeln('import \'package:test/test.dart\';');
  out.writeln();
  out.writeln('import \'../utils/assertions.dart\';');
  out.writeln('import \'../utils/matchers.dart\';');
  out.writeln();
  out.writeln('void main() {');
  for (var i = min; i <= max; i++) {
    final chars =
        List.generate(i, (i) => String.fromCharCode('a'.codeUnitAt(0) + i));
    final string = chars.join();

    out.writeln('group(\'seq$i\', () {');
    out.writeln('final parser = seq$i('
        '${chars.map((each) => 'char(\'$each\')').join(', ')});');
    out.writeln('const record = ('
        '${chars.map((each) => '\'$each\'').join(', ')});');
    out.writeln('expectParserInvariants(parser);');
    out.writeln('test(\'success\', () {');
    out.writeln('expect(parser, '
        'isParseSuccess(\'$string\', result: record));');
    out.writeln('expect(parser, '
        'isParseSuccess(\'$string*\', result: record, position: $i));');
    out.writeln('});');
    for (var j = 0; j < i; j++) {
      out.writeln('test(\'failure at $j\', () {');
      out.writeln('expect(parser, isParseFailure(\''
          '${string.substring(0, j)}\', '
          'message: \'"${chars[j]}" expected\', '
          'position: $j));');
      out.writeln('expect(parser, isParseFailure(\''
          '${string.substring(0, j)}*\', '
          'message: \'"${chars[j]}" expected\', '
          'position: $j));');
      out.writeln('});');
    }
    out.writeln('});');

    out.writeln('group(\'toSequenceParser()\', () {');
    out.writeln('final parser = ('
        '${chars.map((each) => 'char(\'$each\')').join(', ')}).toSequenceParser();');
    out.writeln('const record = ('
        '${chars.map((each) => '\'$each\'').join(', ')});');
    out.writeln('expectParserInvariants(parser);');
    out.writeln('test(\'success\', () {');
    out.writeln('expect(parser, '
        'isParseSuccess(\'$string\', result: record));');
    out.writeln('expect(parser, '
        'isParseSuccess(\'$string*\', result: record, position: $i));');
    out.writeln('});');
    for (var j = 0; j < i; j++) {
      out.writeln('test(\'failure at $j\', () {');
      out.writeln('expect(parser, isParseFailure(\''
          '${string.substring(0, j)}\', '
          'message: \'"${chars[j]}" expected\', '
          'position: $j));');
      out.writeln('expect(parser, isParseFailure(\''
          '${string.substring(0, j)}*\', '
          'message: \'"${chars[j]}" expected\', '
          'position: $j));');
      out.writeln('});');
    }
    out.writeln('});');

    out.writeln('group(\'map$i\', () {');
    out.writeln('final parser = seq$i('
        '${chars.map((each) => 'char(\'$each\')').join(', ')})'
        '.map$i((${chars.join(', ')}) => '
        '\'${chars.map((each) => '\$$each').join()}\');');
    out.writeln('expectParserInvariants(parser);');
    out.writeln('test(\'success\', () {');
    out.writeln('expect(parser, '
        'isParseSuccess(\'$string\', result: \'$string\'));');
    out.writeln('expect(parser, '
        'isParseSuccess(\'$string*\', result: \'$string\', position: $i));');
    out.writeln('});');
    for (var j = 0; j < i; j++) {
      out.writeln('test(\'failure at $j\', () {');
      out.writeln('expect(parser, isParseFailure(\''
          '${string.substring(0, j)}\', '
          'message: \'"${chars[j]}" expected\', '
          'position: $j));');
      out.writeln('expect(parser, isParseFailure(\''
          '${string.substring(0, j)}*\', '
          'message: \'"${chars[j]}" expected\', '
          'position: $j));');
      out.writeln('});');
    }
    out.writeln('});');

    out.writeln('group(\'record\', () {');
    out.writeln('const record = ('
        '${chars.map((each) => '\'$each\'').join(', ')});');
    out.writeln('const other = ('
        '${chars.reversed.map((each) => '\'$each\'').join(', ')});');
    out.writeln('test(\'accessors\', () {');
    for (var j = 0; j < i; j++) {
      out.writeln('expect(record.\$${j + 1}, \'${chars[j]}\');');
      out.writeln(' // ignore: deprecated_member_use_from_same_package');
      out.writeln('expect(record.${ordinals[j]}, \'${chars[j]}\');');
    }
    out.writeln(' // ignore: deprecated_member_use_from_same_package');
    out.writeln('expect(record.last, \'${chars[i - 1]}\');');
    out.writeln('});');
    out.writeln('test(\'map\', () {');
    out.writeln('expect(record.map((${chars.join(', ')}) {');
    for (var j = 0; j < i; j++) {
      out.writeln('expect(${chars[j]}, \'${chars[j]}\');');
    }
    out.writeln('return 42;');
    out.writeln('}), 42);');
    out.writeln('});');
    out.writeln('test(\'equals\', () {');
    out.writeln('expect(record, record);');
    out.writeln('expect(record, isNot(other));');
    out.writeln('expect(other, isNot(record));');
    out.writeln('expect(other, other);');
    out.writeln('});');
    out.writeln('test(\'hashCode\', () {');
    out.writeln('expect(record.hashCode, record.hashCode);');
    out.writeln('expect(record.hashCode, isNot(other.hashCode));');
    out.writeln('expect(other.hashCode, isNot(record.hashCode));');
    out.writeln('expect(other.hashCode, other.hashCode);');
    out.writeln('});');
    out.writeln('test(\'toString\', () {');
    out.writeln('expect(record.toString(), '
        'endsWith(\'(${chars.join(', ')})\'));');
    out.writeln('expect(other.toString(), '
        'endsWith(\'(${chars.reversed.join(', ')})\'));');
    out.writeln('});');
    out.writeln('});');
  }
  out.writeln('}');
  await out.close();
  await format(file);
}

Future<void> main() => Future.wait([
      for (var i = min; i <= max; i++) generateImplementation(i),
      generateTest(),
    ]);

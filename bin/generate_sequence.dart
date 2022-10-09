import 'dart:io';

/// Number of parsers that can be combined.
final int min = 2;
final int max = 9;

/// Export file.
final File exportFile = File('lib/src/parser/combinator/sequence_map.dart');

/// Implementation file.
File implementationFile(int i) =>
    File('lib/src/parser/combinator/generated/sequence_map_$i.dart');

/// Test file.
final File testFile = File('test/generated/sequence_map_test.dart');

/// Pretty prints and cleans up a dart file.
Future<void> format(File file) async =>
    Process.run('dart', ['format', '--fix', file.absolute.path]);

/// Generate the variable names.
List<String> generateValues(String prefix, int i) =>
    List.generate(i, (i) => '$prefix${i + 1}');

/// Generate the type names.
List<String> generateTypes(int i) => List.generate(i, (i) => 'R${i + 1}');

void generateWarning(StringSink out) {
  out.writeln('// AUTO-GENERATED CODE: DO NOT EDIT');
  out.writeln();
}

Future<void> generateExport() async {
  final file = exportFile;
  final out = file.openWrite();
  generateWarning(out);
  out.writeln('import \'../../core/parser.dart\';');
  for (var i = min; i <= max; i++) {
    out.writeln('import \'generated/sequence_map_$i.dart\';');
  }
  out.writeln();
  for (var i = min; i <= max; i++) {
    final resultTypes = generateTypes(i);
    final parserNames = generateValues('parser', i);
    out.writeln('/// Creates a parser that consumes a sequence of $i typed '
        'parsers and combines');
    out.writeln('/// the successful parse with a [callback] to a result of '
        'type [R].');
    out.writeln('Parser<R> seqMap$i<${resultTypes.join(', ')}, R>(');
    for (var j = 0; j < i; j++) {
      out.writeln('Parser<${resultTypes[j]}> ${parserNames[j]}, ');
    }
    out.writeln('R Function(${resultTypes.join(', ')}) callback,');
    out.writeln(') => SequenceMapParser$i<${resultTypes.join(', ')}, R>(');
    out.writeln('${parserNames.join(', ')}, callback);');
    out.writeln();
  }
  await out.close();
  await format(file);
}

Future<void> generateImplementation(int index) async {
  final file = implementationFile(index);
  final out = file.openWrite();
  final resultTypes = generateTypes(index);
  final parserNames = generateValues('parser', index);
  final resultNames = generateValues('result', index);
  final className = 'SequenceMapParser$index<${resultTypes.join(', ')}, R>';
  generateWarning(out);
  out.writeln('import \'../../../context/context.dart\';');
  out.writeln('import \'../../../context/result.dart\';');
  out.writeln('import \'../../../core/parser.dart\';');
  out.writeln();
  out.writeln('/// A parser that consumes a sequence of $index typed parsers '
      'and combines');
  out.writeln('/// the successful parse with a [callback] to a result of type '
      '[R].');
  out.writeln('class $className extends Parser<R> {');
  out.writeln('SequenceMapParser$index(');
  for (var i = 0; i < index; i++) {
    out.writeln('this.${parserNames[i]},');
  }
  out.writeln('this.callback');
  out.writeln(');');
  out.writeln();
  for (var i = 0; i < index; i++) {
    out.writeln('Parser<${resultTypes[i]}> ${parserNames[i]};');
  }
  out.writeln('final R Function(${resultTypes.join(', ')}) callback;');
  out.writeln();
  out.writeln('@override');
  out.writeln('Result<R> parseOn(Context context) {');
  for (var i = 0; i < index; i++) {
    out.writeln('final ${resultNames[i]} = ${parserNames[i]}'
        '.parseOn(${i == 0 ? 'context' : resultNames[i - 1]});');
    out.writeln('if (${resultNames[i]}.isFailure) '
        'return ${resultNames[i]}.failure(${resultNames[i]}.message);');
  }
  out.writeln('return ${resultNames[index - 1]}.success(callback('
      '${resultNames.map((each) => '$each.value').join(', ')}'
      '));');
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
  out.writeln('$className copy() => $className(${parserNames.join(', ')}, '
      'callback);');
  out.writeln('}');
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
    out.writeln('group(\'seqMap$i\', () {');
    out.writeln('final parser = seqMap$i('
        '${chars.map((each) => 'char(\'$each\')').join(', ')}, '
        '(${chars.join(', ')}) => '
        '\'${chars.map((each) => '\$$each').join()}\');');
    out.writeln('expectParserInvariants(parser);');
    out.writeln('test(\'success\', () {');
    out.writeln('expect(parser, isParseSuccess(\'$string\', \'$string\'));');
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
  }
  out.writeln('}');
  await out.close();
  await format(file);
}

Future<void> main() => Future.wait([
      generateExport(),
      for (var i = min; i <= max; i++) generateImplementation(i),
      generateTest(),
    ]);

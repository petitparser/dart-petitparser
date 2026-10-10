import 'package:checks/checks.dart';
import 'package:petitparser/petitparser.dart';
import 'package:petitparser/reflection.dart';
import 'package:test/scaffolding.dart';

import 'checks.dart';

/// Shared invariants for all parsers.
void expectParserInvariants<T>(Parser<T> parser) {
  test('copy', () {
    final copy = parser.copy();
    check(copy).not((it) => it.identicalTo(parser));
    check(copy.toString()).equals(parser.toString());
    check(copy.runtimeType).equals(parser.runtimeType);
    check(copy.children).pairwiseMatches(
      parser.children,
      (expected) =>
          (child) => child.identicalTo(expected),
      'identical children',
    );
    check(copy).isDeepEqualTo(parser);
  });
  test('transform', () {
    final copy = transformParser(parser, <P>(parser) => parser);
    check(copy).not((it) => it.identicalTo(parser));
    check(copy.toString()).equals(parser.toString());
    check(copy.runtimeType).equals(parser.runtimeType);
    check(copy.children).pairwiseMatches(
      parser.children,
      (expected) => (child) {
        child.not((it) => it.identicalTo(expected));
        child
            .has((p) => p.toString(), 'toString()')
            .equals(expected.toString());
        child
            .has((p) => p.runtimeType, 'runtimeType')
            .equals(expected.runtimeType);
      },
      'transformed children',
    );
    check(copy).isDeepEqualTo(parser);
  });
  test('isEqualTo', () {
    final copy = parser.copy();
    check(copy).isDeepEqualTo(parser);
    check(copy).isDeepEqualTo(copy);
    check(parser).isDeepEqualTo(copy);
  });
  test('replace', () {
    final copy = parser.copy();
    final replaced = <Parser>[];
    for (var i = 0; i < copy.children.length; i++) {
      final source = copy.children[i];
      final target = source.copy();
      check(source).not((it) => it.identicalTo(target));
      copy.replace(source, target);
      check(copy.children[i]).identicalTo(target);
      replaced.add(target);
    }
    check(copy.children).pairwiseMatches(
      replaced,
      (expected) =>
          (child) => child.identicalTo(expected),
      'replaced children',
    );
  });
  test('toString', () {
    check(parser.toString())
        .isCustomToString(name: parser.runtimeType.toString());
    if (parser case CharacterParser(predicate: final predicate)) {
      check(predicate.toString())
          .isCustomToString(name: predicate.runtimeType.toString());
    }
  });
}

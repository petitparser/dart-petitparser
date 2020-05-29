library petitparser.parser.character.constant;

import 'predicate.dart';

class ConstantCharPredicate extends CharacterPredicate {
  final bool constant;

  const ConstantCharPredicate(this.constant);

  @override
  bool test(int value) => constant;

  @override
  bool isEqualTo(CharacterPredicate other) =>
      other is ConstantCharPredicate && other.constant == constant;
}

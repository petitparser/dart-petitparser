import '../predicate.dart';

final class WhitespaceCharPredicate extends CharacterPredicate {
  const WhitespaceCharPredicate();

  @override
  bool test(int charCode) {
    // The following code is adapted from the Dart SDK:
    // https://github.com/dart-lang/sdk/blob/2ad44521dc99c2dfa924c3a7867e8baad6e78359/sdk/lib/_internal/wasm/lib/string.dart#L563
    if (charCode <= 32) {
      return (charCode == 32) || ((charCode <= 13) && (charCode >= 9));
    }
    if (charCode < 0x85) return false;
    if ((charCode == 0x85) || (charCode == 0xA0)) return true;
    return (charCode <= 0x200A)
        ? ((charCode == 0x1680) || (0x2000 <= charCode))
        : ((charCode == 0x2028) ||
            (charCode == 0x2029) ||
            (charCode == 0x202F) ||
            (charCode == 0x205F) ||
            (charCode == 0x3000) ||
            (charCode == 0xFEFF));
  }

  @override
  bool operator ==(Object other) => other is WhitespaceCharPredicate;

  @override
  int get hashCode => 8110499;
}

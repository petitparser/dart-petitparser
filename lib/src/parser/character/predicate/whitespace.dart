import '../predicate.dart';

class WhitespaceCharPredicate extends CharacterPredicate {
  const WhitespaceCharPredicate();

  @override
  bool test(int charCode) {
    if (charCode < 256) {
      switch (charCode) {
        case 0x09:
        case 0x0A:
        case 0x0B:
        case 0x0C:
        case 0x0D:
        case 0x20:
        case 0x85:
        case 0xA0:
          return true;
        default:
          return false;
      }
    }
    switch (charCode) {
      case 0x1680:
      case 0x2000:
      case 0x2001:
      case 0x2002:
      case 0x2003:
      case 0x2004:
      case 0x2005:
      case 0x2006:
      case 0x2007:
      case 0x2008:
      case 0x2009:
      case 0x200A:
      case 0x2028:
      case 0x2029:
      case 0x202F:
      case 0x205F:
      case 0x3000:
      case 0xFEFF:
        return true;
      default:
        return false;
    }
  }

  @override
  bool isEqualTo(CharacterPredicate other) => other is WhitespaceCharPredicate;
}

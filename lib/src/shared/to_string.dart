import 'pragma.dart';

/// Returns the print string of the runtime type of [object] if assertions are
/// enabled, otherwise return the second argument.
///
/// The reasons for this code is because `object.runtimeType.toString()` comes
/// at a significant cost.
@preferInline
String objectToString(Object object, [String otherwise = '<unknown>']) {
  assert(() {
    otherwise = object.runtimeType.toString();
    return true;
  }());
  return otherwise;
}

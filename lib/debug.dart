/**
 * This package contains some simple debugging tools.
 */
library debug;

import 'package:petitparser/petitparser.dart';
import 'package:petitparser/reflection.dart';

part 'src/debug/continuation.dart';
part 'src/debug/profile.dart';
part 'src/debug/progress.dart';
part 'src/debug/trace.dart';

typedef void OutputHandler(Object object);

String _repeat(int count, String value) {
  var result = new StringBuffer();
  for (var i = 0; i < count; i++) {
    result.write(value);
  }
  return result.toString();
}
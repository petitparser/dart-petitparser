import 'package:meta/meta.dart';

import '../../core/parser.dart';
import '../character/char.dart';
import '../character/pattern.dart';
import '../misc/epsilon.dart';
import 'string.dart';

extension ToParserStringExtension on String {
  /// Converts this string to a corresponding parser.
  @useResult
  Parser<String> toParser({
    bool isPattern = false,
    bool caseInsensitive = false,
    String? message,
  }) {
    if (isEmpty) {
      return epsilonWith<String>(this);
    } else if (length == 1) {
      return caseInsensitive
          ? charIgnoringCase(this, message: message)
          : char(this, message: message);
    } else {
      if (isPattern) {
        return caseInsensitive
            ? patternIgnoreCase(this, message: message)
            : pattern(this, message: message);
      } else {
        return caseInsensitive
            ? stringIgnoreCase(this, message: message)
            : string(this, message: message);
      }
    }
  }
}

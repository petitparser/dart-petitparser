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
          ? charIgnoringCase(this, message)
          : char(this, message);
    } else {
      if (isPattern) {
        return caseInsensitive
            ? patternIgnoreCase(this, message)
            : pattern(this, message);
      } else {
        return caseInsensitive
            ? stringIgnoreCase(this, message)
            : string(this, message);
      }
    }
  }
}

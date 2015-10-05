/**
 * This package contains the grammar of the Dart programming language.
 *
 * The grammar is adapted from [https://code.google.com/p/dart/source/browse/branches/bleeding_edge/dart/language/grammar/Dart.g].
 * Unfortunately, it is unable to parse all valid Dart programs yet.
 */
library dart;

import 'package:petitparser/petitparser.dart';

part 'src/dart/grammar.dart';

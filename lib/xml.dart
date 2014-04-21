/**
 * This package contained a reasonably complete implementation of an XML
 * parser and its associated AST.
 *
 * If you previously depended on this example, please instead use the
 * separate [xml](http://pub.dartlang.org/packages/xml) package. It contains
 * an improved and mostly compatible version of the XML library.
 */
@deprecated
library xml;

import 'dart:collection';
import 'package:petitparser/petitparser.dart';

part 'src/xml/grammar.dart';
part 'src/xml/parser.dart';
part 'src/xml/nodes.dart';

// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

/**
 * # XML grammar
 *
 * This package contains a reasonably complete implementation of an XML
 * parser and an associated AST. Escaped characters are currently not handled
 * completely according to the specification.
 */
library xml;

import 'package:petitparser/petitparser.dart';

part 'src/xml/grammar.dart';
part 'src/xml/parser.dart';
part 'src/xml/nodes.dart';

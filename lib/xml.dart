// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

/**
 * This package contains a reasonably complete implementation of an XML
 * parser and its associated AST.
 *
 * Example:
 *
 *     var xml = new XmlParser();
 *     var result = xml.parse('<xml attr="foo"><zork /></xml>');
 *     print(result.value);    // <xml attr="foo"><zork /></xml>
 */
library xml;

import 'dart:collection';
import 'package:meta/meta.dart';
import 'package:petitparser/petitparser.dart';

part 'src/xml/grammar.dart';
part 'src/xml/parser.dart';
part 'src/xml/nodes.dart';

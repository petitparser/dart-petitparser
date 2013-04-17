// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

/**
 * # JSON grammar
 *
 * This package contains a complete implementation of a JSON parser. The default
 * implementation in [JsonParser] builds a nested structure of [Map]s, [List]s,
 * [String]s, and [Number]s from a given JSON string:
 *
 *     var json = new JsonParser();
 *     var result = json.parse('{"a": 1, "b": [2, 3.4], "c": false}');
 *
 * Custom subclasses of [JsonGrammar] allow one to construct other output.
 */
library json;

import 'dart:math';
import 'dart:collection';
import 'package:petitparser/petitparser.dart';

part 'src/json/grammar.dart';
part 'src/json/parser.dart';

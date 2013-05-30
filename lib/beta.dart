// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

/**
 * This package contains a experimental features of PetitParser. The code here
 * might be removed or changed in incompatible ways without keeping backward
 * compatiblity.
 */
library beta;

import 'dart:mirrors';
import 'package:petitparser/petitparser.dart';

/**
 * Experimental helper to compose complex grammars from various primitive
 * parsers using variable references.
 *
 * The difference of this implementation to [CompositeParser] is that
 * subclasses can define and refer to productions using variables. The
 * variables themselves are not actually implement anywhere, but their
 * behavior is defined in [noSuchMethod] and mapped to a collection using
 * the methods defined in the superclass.
 *
 * Consider the following example to parse a list of numbers:
 *
 *     class NumberListGrammar2 extends CompositeParser2 {
 *       void initialize() {
 *         start = list.end();
 *         list = element.separatedBy(char(','), includeSeparators: false));
 *         element = digit().plus().flatten();
 *       }
 *     }
 *
 * Production actions can be attached in subclasses by calling the production,
 * as in the following example:
 *
 *     class NumberListParser2 extends NumberListGrammar2 {
 *       void initialize() {
 *         element((value) => int.parse(value));
 *       }
 *     }
 *
 * Creavats: Pay attention with production names that conflict with methods
 * defined in superclasses. The generated JavaScript code is slightly bigger,
 * due to the use of [noSuchMethod]. However, the resulting parser is identical.
 */
abstract class CompositeParser2 extends CompositeParser {

  dynamic noSuchMethod(Invocation mirror) {
    String name = MirrorSystem.getName(mirror.memberName);
    if (!name.startsWith('_')) {
      if (mirror.isGetter) {
        return ref(name);
      } else if (mirror.isSetter) {
        return def(name.substring(0, name.length - 1),
          mirror.positionalArguments.first);
      } else if (mirror.isMethod && mirror.positionalArguments.length == 1) {
        var argument = mirror.positionalArguments.first;
        return argument is Parser ? redef(name, argument) : action(name, argument);
      }
    }
    return super.noSuchMethod(mirror);
  }

}
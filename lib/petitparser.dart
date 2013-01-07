// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

/**
 * # Writing a Simple Grammar
 *
 * Writing grammars with PetitParser is simple as writing Dart code. For
 * example, to write a grammar that can parse identifiers that start with
 * a letter followed by zero or more letter or digits is defined as follows:
 *
 *     Parser id = letter().seq(word().star());
 *
 * If you look at the object [:identifier:] in the debugger, you'll notice
 * that the code above built a tree of parser objects:
 *
 *     Sequence: This parser accepts a sequence of parsers.
 *       Predicate: This parser accepts a single letter.
 *       Repeater: This parser accepts zero or more times another parser.
 *         Predicate: This parser accepts a single word character.
 *
 * # Parsing Some Input
 *
 * To actually parse a [String] (or [List]) we can use the method
 * [Parser#parse]:
 *
 *     Result id1 = id.parse('yeah');
 *     Result id2 = id.parse('f12');
 *
 * The method [Parser#parse] returns a parse [Result], which is either an
 * instance of [Success] or [Failure]. In the examples above we are
 * successful and can retrieve the parse result through [Result#result]:
 *
 *     print(id1.value);                   // ['y' ['e' 'a' 'h']]
 *     print(id2.value);                   // ['f' ['1' '2']]
 *
 * While it seems odd to get these nested arrays with characters as a return
 * value, this is the default decomposition of the input into a parse tree.
 * We'll see in a while how that can be customized.
 *
 * If we try to parse something invalid we get an instance of [Failure] as
 * an answer:
 *
 *     Result id3 = id.parse('123');
 *     print(id3.message)                  // 'letter expected at 0'
 *
 * Trying to retrieve the parse result by calling [Result#result] would throw
 * an exception. [Result#isSuccess] and [Result#isFailure] can be used to
 * decide if the parse was successful.
 *
 * If you are only interested if a given string matches or not you can use the
 * helper method [Parser#accept]:
 *
 *     print(id.accept('foo'));            // true
 *     print(id.accept('123'));            // false
 *
 * Furthermore, to find all matches in a given input string you can use
 * [Parser#matches]:
 *
 *     List matches = id.matches('foo 123 bar12'));
 *
 * # Different Kinds of Parsers
 *
 * PetitParser provide a large set of ready-made parser that you can compose
 * to consume and transform arbitrarily complex languages. The terminal parsers
 * are the most simple ones. We've already seen a few of those:
 *
 *   * [:char('a'):] parses the character a.
 *   * [:string('abc'):] parses the string =='abc'==.
 *   * [:any():] parses any character.
 *   * [:digit():] parses any digit from 0 to 9.
 *   * [:letter():] parses any letter from a to z and A to Z.
 *   * [:word():] parses any letter or digit.
 *
 * Petitparser provides some other factory methods that can be used to build
 * more complex terminal parsers.
 *
 * The next set of parsers are used to combine other parsers together:
 *
 *   * [:p1.seq(p2):] parses p1 followed by p2 (sequence).
 *   * [:p1.or(p2):] parses p1, if that doesn't work parses p2 (ordered choice).
 *   * [:p.star():] parses zero or more p.
 *   * [:p.plus():] parses one or more p.
 *   * [:p.optional():] parses p if possible.
 *   * [:p.and():] parses p but does not consume its input.
 *   * [:p.not():] parses p and succeed when p fails, but does not consume its input.
 *   * [:p.end():] parses p and succeed at the end of the input.
 *
 * So instead of using the [word()] predicated we could have written our
 * identifier parser like this:
 *
 *     Parser id = letter().seq(letter().or(digit()).star());
 *
 * To attach an action or transformation to a parser we can use the following
 * methods:
 *
 *   * [:p.map((value) => ...):] performs the transformation given the function.
 *   * [:p.flatten():] creates a string from the result of p.
 *   * [:p.token():] creates a token from the result of p.
 *   * [:p.trim():] trims whitespaces before and after p.
 *
 * To return a string of the parsed identifier, we can modify our parser like
 * this:
 *
 *     Parser id = letter().seq(word().star()).flatten();
 *
 * These are the basic elements to build parsers. There are a few more well
 * documented and tested factory methods in the [Parser] class. If you want
 * browse their documentation.
 *
 * # Writing a More Complicated Grammar
 *
 * Now we are able to write a more complicated grammar for evaluating simple
 * arithmetic expressions. Within a file we start with the grammar for a
 * number (actually an integer):
 *
 *     Parser number = digit().plus().flatten().trim().map(int.parse);
 *
 * Then we define the productions for addition and multiplication in order of
 * precedence. Note that we instantiate the productions with undefined parsers
 * upfront, because they recursively refer to each other. Later on we can
 * resolve this recursion by replacing the reference.
 *
 *     Parser term := undefined();
 *     Parser prod := undefined();
 *     Parser prim := undefined();
 *
 *     term.set(prod.seq(char('+').trim()).seq(term).map((values) {
 *       return values[0] + values[2];
 *     }).or(prod));
 *     prod.set(prim.seq(char('*').trim()).seq(prod).map((values) {
 *       return values[0] * values[2];
 *     }).or(prim));
 *     prim.set(char('(').trim().seq(term).seq(char(')'.trim()).map((values) {
 *       return values[1];
 *     }).or(number));
 *
 * To make sure that our parser consumes all input we wrap it with the [:end():]
 * parser into the start production:
 *
 *     Parser start = term.end();
 *
 * That's it, now we can test our parser and evaluator:
 *
 *     print(start.parse('1 + 2 * 3').result);       // 7
 *     print(start.parse('(1 + 2) * 3').result);     // 9
 *
 * As an exercise we could extend the parser to also accept negative numbers
 * and floating point numbers, not only integers. Furthermore it would be
 * useful to add support subtraction and division as well. All these features
 * can be added with a few lines of PetitParser code.
 */
library petitparser;

part 'src/core/actions.dart';
part 'src/core/characters.dart';
part 'src/core/combinators.dart';
part 'src/core/composite.dart';
part 'src/core/context.dart';
part 'src/core/parser.dart';
part 'src/core/parsers.dart';
part 'src/core/predicates.dart';
part 'src/core/reflection.dart';
part 'src/core/token.dart';
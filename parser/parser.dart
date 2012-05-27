// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

/**
 * An abstract parser that forms the root of all parsers in this package.
 */
interface Parser {

  /**
   * Apply the parser on the given parse context.
   */
  Result parse(Context context);

}
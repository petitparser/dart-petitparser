part of petitparser;

/**
 * A token represents a parsed part of the input stream.
 *
 * The token holds the resulting value of the input, the input buffer,
 * and the start and stop position in the input buffer. It provides many
 * convenience methods to access the state of the token.
 */
class Token {

  /**
   * The parsed value of the token.
   */
  final value;

  /**
   * The parsed buffer of the token.
   */
  final buffer;

  /**
   * The start position of the token in the buffer.
   */
  final int start;

  /**
   * The stop position of the token in the buffer.
   */
  final int stop;

  /**
   * Constructs a token from the parsed value, the input buffer, and the
   * start and stop position in the input buffer.
   */
  const Token(this.value, this.buffer, this.start, this.stop);

  /**
   * The consumed input of the token.
   */
  get input => buffer is String
      ? buffer.substring(start, stop)
      : buffer.sublist(start, stop);

  /**
   * The length of the token.
   */
  int get length => stop - start;

  /**
   * The line number of the token (only works for [String] buffers).
   */
  int get line => Token.lineAndColumnOf(buffer, start)[0];

  /**
   * The column number of this token (only works for [String] buffers).
   */
  int get column => Token.lineAndColumnOf(buffer, start)[1];

  @override
  String toString() => 'Token[${positionString(buffer, start)}]: $value';

  @override
  bool operator ==(other) {
    return other is Token && value == other.value && start == other.start && stop == other.stop;
  }

  @override
  int get hashCode => value.hashCode + start.hashCode + stop.hashCode;

  static final Parser _NEWLINE_PARSER = char('\n').or(char('\r').seq(char('\n').optional()));

  /**
   * Returns a parser for that detects newlines platform independently.
   */
  static Parser newlineParser() => _NEWLINE_PARSER;

  /**
   * Converts the [position] index in a [buffer] to a line and column tuple.
   */
  static List<int> lineAndColumnOf(String buffer, int position) {
    var line = 1, offset = 0;
    for (var token in newlineParser().token().matchesSkipping(buffer)) {
      if (position < token.stop) {
        return [line, position - offset + 1];
      }
      line++;
      offset = token.stop;
    }
    return [line, position - offset + 1];
  }

  /**
   * Returns a human readable string representing the [position] index in a [buffer].
   */
  static String positionString(buffer, int position) {
    if (buffer is String) {
      var lineAndColumn = Token.lineAndColumnOf(buffer, position);
      return '${lineAndColumn[0]}:${lineAndColumn[1]}';
    } else {
      return '${position}';
    }
  }

}

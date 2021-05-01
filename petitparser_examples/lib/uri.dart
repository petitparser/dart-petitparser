/// A simple URI parser based on RFC-3986.
///
/// The accepted inputs and decomposition matches the example given in
/// Appendix B of the standard: https://tools.ietf.org/html/rfc3986#appendix-B.
import 'package:petitparser/petitparser.dart';

final uri = _uri.map((values) => <Symbol, String?>{
      #scheme: values[0]?[0],
      #authority: values[1]?[1],
      #path: values[2],
      #query: values[3]?[1],
      #fragment: values[4]?[1],
    });

final _uri = (_scheme & ':'.toParser()).optional() &
    ('//'.toParser() & _authority).optional() &
    _path &
    ('?'.toParser() & _query).optional() &
    ('#'.toParser() & _fragment).optional();

final _scheme = pattern('^:/?#').plus().flatten('scheme');

final _authority = pattern('^/?#').star().flatten('authority');

final _path = pattern('^?#').star().flatten('path');

final _query = pattern('^#').star().flatten('query');

final _fragment = any().star().flatten('fragment');

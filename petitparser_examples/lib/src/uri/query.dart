/// Parsers an URI query.
///
/// Accepts input of the form "{key[=value]}&...".
import 'package:petitparser/petitparser.dart';

final query = _query.map((values) => values
    .map((each) => <String?>[each[0], each[1]?[1]])
    .where((each) => each[0] != '' || each[1] != null));

final _query = _param.separatedBy('&'.toParser(),
    optionalSeparatorAtEnd: true, includeSeparators: false);

final _param = _paramKey & ('='.toParser() & _paramValue).optional();

final _paramKey = pattern('^=&').star().flatten('param key');

final _paramValue = pattern('^&').star().flatten('param value');

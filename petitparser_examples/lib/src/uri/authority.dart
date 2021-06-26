/// Further parse the URI authority into username, password, hostname and port.
///
/// Accepts input of the form "[username[:password]@]hostname[:port]".
import 'package:petitparser/petitparser.dart';

final authority = _authority.map((values) => <Symbol, String?>{
      #username: values[0]?[0],
      #password: values[0]?[1]?[1],
      #hostname: values[1],
      #port: values[2]?[1],
    });

final _authority =
    (_username & (':'.toParser() & _password).optional() & '@'.toParser())
            .optional() &
        _hostname.optional() &
        (':'.toParser() & _port).optional();

final _username = pattern('^:@').plus().flatten('username');

final _password = pattern('^@').plus().flatten('password');

final _hostname = pattern('^:').plus().flatten('hostname');

final _port = any().plus().flatten('port');

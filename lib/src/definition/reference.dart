import 'package:meta/meta.dart';

import '../core/parser.dart';
import 'internal/reference.dart';
import 'resolve.dart';

/// Creates a [parser] from a [function] without arguments.
///
/// See [ref0] for details.
@useResult
Parser<T> ref<T>(Parser<T> Function() function) => ref0(function);

/// Creates a [Parser] from a [function] without arguments.
///
/// Reference parsers behave like normal parsers during construction, but can
/// recursively reference each other. Once the parser is assembled resolve all
/// references by passing the root of your parser to [resolve].
///
/// If you function takes arguments, consider one of the typed alternatives
/// [ref1], [ref2], [ref3], ... instead.
@useResult
Parser<T> ref0<T>(Parser<T> Function() function) =>
    ReferenceParser<T>(function, const []);

/// Reference to a production [function] parametrized with 1 argument.
///
/// See [ref0] for a detailed description.
@useResult
Parser<T> ref1<T, A1>(
  Parser<T> Function(A1) function,
  A1 arg1,
) =>
    ReferenceParser<T>(function, [arg1]);

/// Reference to a production [function] parametrized with 2 arguments.
///
/// See [ref0] for a detailed description.
@useResult
Parser<T> ref2<T, A1, A2>(
  Parser<T> Function(A1, A2) function,
  A1 arg1,
  A2 arg2,
) =>
    ReferenceParser<T>(function, [arg1, arg2]);

/// Reference to a production [function] parametrized with 3 arguments.
///
/// See [ref0] for a detailed description.
@useResult
Parser<T> ref3<T, A1, A2, A3>(
  Parser<T> Function(A1, A2, A3) function,
  A1 arg1,
  A2 arg2,
  A3 arg3,
) =>
    ReferenceParser<T>(function, [arg1, arg2, arg3]);

/// Reference to a production [function] parametrized with 4 arguments.
///
/// See [ref0] for a detailed description.
@useResult
Parser<T> ref4<T, A1, A2, A3, A4>(
  Parser<T> Function(A1, A2, A3, A4) function,
  A1 arg1,
  A2 arg2,
  A3 arg3,
  A4 arg4,
) =>
    ReferenceParser<T>(function, [arg1, arg2, arg3, arg4]);

/// Reference to a production [function] parametrized with 5 arguments.
///
/// See [ref0] for a detailed description.
@useResult
Parser<T> ref5<T, A1, A2, A3, A4, A5>(
  Parser<T> Function(A1, A2, A3, A4, A5) function,
  A1 arg1,
  A2 arg2,
  A3 arg3,
  A4 arg4,
  A5 arg5,
) =>
    ReferenceParser<T>(function, [arg1, arg2, arg3, arg4, arg5]);

/// Reference to a production [function] parametrized with 6 arguments.
///
/// See [ref0] for a detailed description.
@useResult
Parser<T> ref6<T, A1, A2, A3, A4, A5, A6>(
  Parser<T> Function(A1, A2, A3, A4, A5, A6) function,
  A1 arg1,
  A2 arg2,
  A3 arg3,
  A4 arg4,
  A5 arg5,
  A6 arg6,
) =>
    ReferenceParser<T>(function, [arg1, arg2, arg3, arg4, arg5, arg6]);

/// Reference to a production [function] parametrized with 7 arguments.
///
/// See [ref0] for a detailed description.
@useResult
Parser<T> ref7<T, A1, A2, A3, A4, A5, A6, A7>(
  Parser<T> Function(A1, A2, A3, A4, A5, A6, A7) function,
  A1 arg1,
  A2 arg2,
  A3 arg3,
  A4 arg4,
  A5 arg5,
  A6 arg6,
  A7 arg7,
) =>
    ReferenceParser<T>(function, [arg1, arg2, arg3, arg4, arg5, arg6, arg7]);

/// Reference to a production [function] parametrized with 8 arguments.
///
/// See [ref0] for a detailed description.
@useResult
Parser<T> ref8<T, A1, A2, A3, A4, A5, A6, A7, A8>(
  Parser<T> Function(A1, A2, A3, A4, A5, A6, A7, A8) function,
  A1 arg1,
  A2 arg2,
  A3 arg3,
  A4 arg4,
  A5 arg5,
  A6 arg6,
  A7 arg7,
  A8 arg8,
) =>
    ReferenceParser<T>(
        function, [arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8]);

/// Reference to a production [function] parametrized with 9 arguments.
///
/// See [ref0] for a detailed description.
@useResult
Parser<T> ref9<T, A1, A2, A3, A4, A5, A6, A7, A8, A9>(
  Parser<T> Function(A1, A2, A3, A4, A5, A6, A7, A8, A9) function,
  A1 arg1,
  A2 arg2,
  A3 arg3,
  A4 arg4,
  A5 arg5,
  A6 arg6,
  A7 arg7,
  A8 arg8,
  A9 arg9,
) =>
    ReferenceParser<T>(
        function, [arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9]);

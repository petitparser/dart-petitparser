import 'package:meta/meta.dart';

import '../../../parser.dart';
import '../../context/context.dart';

/// Returns a parser that detects newlines platform independently.
@useResult
Parser<String> newline([String message = 'newline expected']) =>
    NewlineParser(message);

/// A parser that consumes newlines platform independently.
class NewlineParser extends Parser<String> {
  NewlineParser(this.message);

  final String message;

  @override
  void parseOn(Context context) {
    final buffer = context.buffer;
    final position = context.position;
    if (position < context.end) {
      switch (buffer.codeUnitAt(position)) {
        case 10:
          // Unix and Unix-like systems (Linux, macOS, FreeBSD, AIX, Xenix, etc.),
          // Multics, BeOS, Amiga, RISC OS.
          context.isSuccess = true;
          context.value = '\n';
          context.position = position + 1;
          return;
        case 13:
          if (position + 1 < context.end &&
              buffer.codeUnitAt(position + 1) == 10) {
            // Microsoft Windows, DOS (MS-DOS, PC DOS, etc.), Atari TOS, DEC
            // TOPS-10, RT-11, CP/M, MP/M, OS/2, Symbian OS, Palm OS, Amstrad
            // CPC, and most other early non-Unix and non-IBM operating systems.
            context.isSuccess = true;
            context.value = '\r\n';
            context.position = position + 2;
            return;
          } else {
            // Commodore 8-bit machines (C64, C128), Acorn BBC, ZX Spectrum,
            // TRS-80, Apple II series, Oberon, the classic Mac OS, MIT Lisp
            // Machine and OS-9.
            context.isSuccess = true;
            context.value = '\r';
            context.position = position + 1;
            return;
          }
      }
    }
    context.isSuccess = false;
    context.message = message;
  }

  @override
  NewlineParser copy() => NewlineParser(message);
}

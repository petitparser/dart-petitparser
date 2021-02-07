import 'package:meta/meta.dart';

import '../../buffer.dart';

@immutable
class StringBuffer implements Buffer {
  final String string;

  const StringBuffer(this.string);

  @override
  int get length => string.length;

  @override
  String charAt(int position) => string[position];

  @override
  int codeUnitAt(int position) => string.codeUnitAt(position);

  @override
  String substring(int start, int end) => string.substring(start, end);
}

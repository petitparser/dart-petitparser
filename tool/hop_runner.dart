library hop_runner;

import 'dart:async';
import 'dart:io';
import 'package:bot/bot.dart';
import 'package:bot/bot_io.dart';
import 'package:bot/hop.dart';
import 'package:bot/hop_tasks.dart';
import '../test/all_tests.dart' as test;

void main() {
  addTask('test', createUnitTestTask(test.testCore));

  addTask('docs', createDartDocTask(_getLibs, linkApi: true));

  runHop();
}

Future<List<String>> _getLibs() {
  return new Directory('lib').list()
      .where((FileSystemEntity fse) => fse is File)
      .map((File file) => file.path)
      .toList();
}

// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

library smalltalk_test;

import 'package:petitparser/smalltalk.dart';
import 'package:unittest/unittest.dart';

void main() {
  var smalltalk = new SmalltalkGrammar();

  print(allParser(smalltalk).length);

}

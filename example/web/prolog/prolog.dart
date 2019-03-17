library petitparser.example.web.prolog;

import 'dart:html';

import 'package:example/prolog.dart';

final TextAreaElement rulesElement = querySelector('#rules');
final TextInputElement queryElement = querySelector('#query');
final askElement = querySelector('#ask');
final answersElement = querySelector('#answers');

void main() {
  askElement.onClick.listen((event) async {
    answersElement.innerHtml = '';

    Database db;
    try {
      db = Database.parse(rulesElement.value);
    } on Object catch (error) {
      appendMessage('Error parsing rules: $error', isError: true);
    }

    Term query;
    try {
      query = Term.parse(queryElement.value);
    } on Object catch (error) {
      appendMessage('Error parsing query: $error', isError: true);
    }

    if (db == null || query == null) {
      return;
    }

    await db.query(query).forEach((item) => appendMessage(item.toString()));

    if (answersElement.innerHtml.isEmpty) {
      appendMessage('No');
    }
  });
}

void appendMessage(String message, {bool isError = false}) {
  final element = document.createElement('li');
  element.innerHtml = message;
  if (isError) {
    element.classes.add('error');
  }
  answersElement.append(element);
}

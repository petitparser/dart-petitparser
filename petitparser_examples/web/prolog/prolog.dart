import 'dart:html';

import 'package:petitparser_examples/prolog.dart';

final rulesElement = querySelector('#rules') as TextAreaElement;
final queryElement = querySelector('#query') as TextInputElement;
final askElement = querySelector('#ask') as SubmitButtonInputElement;
final answersElement = querySelector('#answers') as UListElement;

void main() {
  askElement.onClick.listen((event) async {
    answersElement.innerHtml = '';

    Database? db;
    try {
      db = Database.parse(rulesElement.value ?? '');
    } on Object catch (error) {
      appendMessage('Error parsing rules: $error', isError: true);
    }

    Term? query;
    try {
      query = Term.parse(queryElement.value ?? '');
    } on Object catch (error) {
      appendMessage('Error parsing query: $error', isError: true);
    }

    if (db == null || query == null) {
      return;
    }

    var hasResult = false;
    await db.query(query).forEach((item) {
      appendMessage(item.toString());
      hasResult = true;
    });
    if (!hasResult) {
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

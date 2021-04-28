import 'dart:html';

import 'package:petitparser_examples/smalltalk.dart';

final input = querySelector('#input')! as TextAreaElement;
final output = querySelector('#output')! as ParagraphElement;
final parse = querySelector('#parse')! as SubmitButtonInputElement;

final parserDefinition = SmalltalkParserDefinition();
final methodParser = parserDefinition.build(start: parserDefinition.method);

void main() {
  parse.onClick.listen((event) {
    output.innerHtml = 'Evaluating...';
    output.classes.clear();
    try {
      final result = methodParser.parse(input.value ?? '');
      final visitor = PrintVisitor()..visit(result.value);
      output.innerHtml = visitor.buffer.toString();
    } on Object catch (exception) {
      output.text = exception.toString();
      output.classes.add('error');
    }
  });
}

class PrintVisitor extends Visitor {
  final buffer = StringBuffer();
  var _indent = '';

  void print(Object? object) => buffer.writeln('$_indent$object<br/>');

  void indent(void Function() callback) {
    final previous = _indent;
    _indent = '$previous&nbsp;&nbsp;';
    callback();
    _indent = previous;
  }

  String variables(List<VariableNode> variables) => variables
      .map((variable) => '<i title="${variable.token}">${variable.name}</i>')
      .join(', ');

  void visitMethodNode(MethodNode node) {
    print('<b>Method</b>: <i>${node.selector}</i>');
    indent(() {
      if (node.arguments.isNotEmpty) {
        print('Arguments: ${variables(node.arguments)}');
      }
      if (node.pragmas.isNotEmpty) {
        print('Pragmas');
        indent(() => node.pragmas.forEach(visit));
      }
      visit(node.body);
    });
  }

  void visitPragmaNode(PragmaNode node) {
    print('<b>Pragma</b>: <i>${node.selector}</i>');
    indent(() => node.arguments.forEach(visit));
  }

  void visitReturnNode(ReturnNode node) {
    print('<b>Return</b>');
    indent(() => visit(node.value));
  }

  void visitSequenceNode(SequenceNode node) {
    print('<b>Sequence</b>');
    indent(() {
      if (node.temporaries.isNotEmpty) {
        print('Temporaries: ${variables(node.temporaries)}');
      }
      node.statements.forEach(visit);
    });
  }

  void visitArrayNode(ArrayNode node) {
    print('<b>Array</b>');
    indent(() => node.statements.forEach(visit));
  }

  void visitAssignmentNode(AssignmentNode node) {
    print('<b>Assignment</b>: <i>${node.variable.name}</i>');
    indent(() => visit(node.value));
  }

  void visitBlockNode(BlockNode node) {
    print('<b>Block</b>');
    indent(() {
      if (node.arguments.isNotEmpty) {
        print('Arguments: ${variables(node.arguments)}');
      }
      visit(node.body);
    });
  }

  void visitCascadeNode(CascadeNode node) {
    print('<b>Cascade</b>');
    indent(() {
      visit(node.receiver);
      for (final message in node.messages) {
        print('Selector: <i>${message.selector}</i>');
        if (message.arguments.isNotEmpty) {
          print('Arguments');
          indent(() => message.arguments.forEach(visit));
        }
      }
    });
  }

  void visitLiteralArrayNode(LiteralArrayNode node) {
    print('<b>Literal Array</b>: <i>${node.value}</i>');
  }

  void visitLiteralValueNode(LiteralValueNode node) {
    print('<b>Literal Value</b>: <i>${node.value}</i>');
  }

  void visitMessageNode(MessageNode node) {
    print('<b>Message</b>: <i>${node.selector}</i>');
    indent(() {
      visit(node.receiver);
      if (node.arguments.isNotEmpty) {
        print('Arguments');
        indent(() => node.arguments.forEach(visit));
      }
    });
  }

  void visitVariableNode(VariableNode node) {
    print('<b>Variable</b>: <i>${node.name}</i>');
  }
}

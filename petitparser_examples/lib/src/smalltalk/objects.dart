// Basic classes
final objectBehavior = Behavior('Object');
final classBehavior = Behavior('Class');

// Native classes
final arrayBehavior = Behavior('Array');
final falseBehavior = Behavior('False');
final numberBehavior = Behavior('Number');
final stringBehavior = Behavior('String');
final trueBehavior = Behavior('True');
final undefinedBehavior = Behavior('Undefined');

extension BehaviorAccessor on dynamic {
  Behavior get behavior {
    final self = this;
    if (self == null) {
      return undefinedBehavior;
    } else if (self == true) {
      return trueBehavior;
    } else if (self == false) {
      return falseBehavior;
    } else if (self is num) {
      return numberBehavior;
    } else if (self is String) {
      return stringBehavior;
    } else if (self is List) {
      return arrayBehavior;
    } else if (self is SmalltalkObject) {
      return self.behavior;
    } else {
      throw UnsupportedError('Unsupported object type: ${self.runtimeType}');
    }
  }
}

class SmalltalkObject {
  Behavior behavior;
  Map<String, Object> fields = {};

  SmalltalkObject(this.behavior);
}

class Behavior extends SmalltalkObject {
  String name;
  Map<String, Function> methods = {};

  Behavior(this.name) : super(classBehavior);

  void addMethod(String selector, Function function) =>
      methods[selector] = function;
}

void bootstrap() {
  objectBehavior.addMethod('printString', (self) => self.toString());
  objectBehavior.addMethod('class', (self) => self.behavior);
  objectBehavior.addMethod('isNil', (self) => false);

  undefinedBehavior.addMethod('isNil', (self) => true);

  trueBehavior.addMethod('ifTrue:', (self, trueBranch) => trueBranch());
  trueBehavior.addMethod(
      'ifTrue:ifFalse:', (self, trueBranch, falseBranch) => trueBranch());
  trueBehavior.addMethod('ifFalse:', (self, falseBranch) => null);
  trueBehavior.addMethod(
      'ifFalse:ifTrue:', (self, falseBranch, trueBranch) => trueBranch());
  trueBehavior.addMethod('not', (self) => false);
  trueBehavior.addMethod('and:', (self, other) => other());
  trueBehavior.addMethod('or:', (self, other) => true);

  falseBehavior.addMethod('ifTrue:', (self, trueBranch) => null);
  falseBehavior.addMethod(
      'ifTrue:ifFalse:', (self, trueBranch, falseBranch) => falseBranch());
  falseBehavior.addMethod('ifFalse:', (self, falseBranch) => falseBranch());
  falseBehavior.addMethod(
      'ifFalse:ifTrue:', (self, falseBranch, trueBranch) => falseBranch());
  falseBehavior.addMethod('not', (self) => true);
  falseBehavior.addMethod('and:', (self, other) => false);
  falseBehavior.addMethod('or:', (self, other) => other());

  numberBehavior.addMethod('+', (self, other) => self + other);
  numberBehavior.addMethod('-', (self, other) => self - other);
  numberBehavior.addMethod('*', (self, other) => self * other);
  numberBehavior.addMethod('/', (self, other) => self / other);
  numberBehavior.addMethod('//', (self, other) => self ~/ other);
  numberBehavior.addMethod('\\', (self, other) => self % other);
  numberBehavior.addMethod('negate', (self) => -self);
  numberBehavior.addMethod('<', (self, other) => self < other);
  numberBehavior.addMethod('<=', (self, other) => self <= other);
  numberBehavior.addMethod('>', (self, other) => self > other);
  numberBehavior.addMethod('>=', (self, other) => self >= other);
  numberBehavior.addMethod('=', (self, other) => self < other);

  stringBehavior.addMethod('+', (self, other) => self + other);
  stringBehavior.addMethod('size', (self, other) => self.length);
  stringBehavior.addMethod('at:', (self, index) => self[index]);
  stringBehavior.addMethod('<', (self, other) => self < other);
  stringBehavior.addMethod('<=', (self, other) => self <= other);
  stringBehavior.addMethod('>', (self, other) => self > other);
  stringBehavior.addMethod('>=', (self, other) => self >= other);
  stringBehavior.addMethod('=', (self, other) => self < other);

  arrayBehavior.addMethod('size', (self) => self.length);
  arrayBehavior.addMethod('at:', (self, index) => self[index]);
  arrayBehavior.addMethod(
      'at:put:', (self, index, object) => self[index] = object);

  classBehavior.addMethod('new', (self) => SmalltalkObject(self));
}

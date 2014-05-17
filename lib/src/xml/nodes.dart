part of xml;

/**
 * Mixin to serialize XML to a [StringBuffer].
 */
abstract class _XmlWritable {

  /**
   * Answer a print string of the receiver.
   */
  @override
  String toString() {
    var buffer = new StringBuffer();
    writeTo(buffer);
    return buffer.toString();
  }

  /**
   * Writes the XML string of the receiver to a {@code buffer}.
   */
  void writeTo(StringBuffer buffer);

}

/**
 * Iterator over XML sub-trees of nodes and attributes.
 */
class _XmlNodeIterator extends Iterator<XmlNode> {

  final List<XmlNode> _todo = new List();
  XmlNode _current;

  _XmlNodeIterator(XmlNode root) {
    _todo.add(root);
  }

  XmlNode get current => _current;

  @override
  bool moveNext() {
    if (_todo.isEmpty) {
      return false;
    } else {
      _current = _todo.removeLast();
      _todo.addAll(_current.children.reversed);
      _todo.addAll(_current.attributes.reversed);
      return true;
    }
  }

}

/**
 * Abstract XML node.
 */
abstract class XmlNode extends IterableBase<XmlNode> with _XmlWritable {

  XmlNode _parent;

  /**
   * Answer the parent node of the receiver, or [null] if there is none.
   */
  XmlNode get parent => _parent;

  /**
   * Answer the attribute nodes of the receiver.
   */
  List<XmlAttribute> get attributes => [];

  /**
   * Answer the child nodes of the receiver.
   */
  List<XmlNode> get children => [];

  /**
   * Answer an iterator over the receiver, all attributes and nested children.
   */
  @override
  Iterator<XmlNode> get iterator => new _XmlNodeIterator(this);

  /**
   * Answer the root of the subtree in which this node is found, whether that's
   * a document or another element.
   */
  XmlNode get root {
    return parent == null ? this : parent.root;
  }

  /**
   * Answer the document that contains this node, or [null] if the node is
   * not part of a document.
   */
  XmlDocument get document {
    return parent == null ? null : parent.document;
  }

  /**
   * Answer the first child of the receiver or [null].
   */
  XmlNode get firstChild {
    return children.length > 0 ? children[0] : null;
  }

  /**
   * Answer the last child of the receiver or [null].
   */
  XmlNode get lastChild {
    return children.length > 0 ? children[children.length - 1] : null;
  }

  /**
   * Answer the next sibling of the receiver or [null].
   */
  XmlNode get nextSibling {
    if (parent != null) {
      var siblings = parent.children;
      for (var i = 0; i < siblings.length - 1; i++) {
        if (siblings[i] == this) {
          return siblings[i + 1];
        }
      }
    }
    return null;
  }

  /**
   * Answer the previous sibling of the receiver or [null].
   */
  XmlNode get previousSibling {
    if (parent != null) {
      var siblings = parent.children;
      for (var i = 1; i < siblings.length; i++) {
        if (siblings[i] == this) {
          return siblings[i - 1];
        }
      }
    }
    return null;
  }

}

/**
 * XML attribute node.
 */
class XmlAttribute extends XmlNode {

  final XmlName _name;
  final String _value;

  XmlAttribute(this._name, this._value);

  XmlName get name => _name;
  String get value => _value;

  @override
  void writeTo(StringBuffer buffer) {
    name.writeTo(buffer);
    buffer.write('="');
    buffer.write(value);
    buffer.write('"');
  }

}

/**
 * Abstract XML data node.
 */
abstract class XmlData extends XmlNode {

  final String _data;

  XmlData(this._data);

  String get data => _data;

}

/**
 * XML comment node.
 */
class XmlComment extends XmlData {

  XmlComment(String data): super(data);

  @override
  void writeTo(StringBuffer buffer) {
    buffer.write('<!--');
    buffer.write(data);
    buffer.write('-->');
  }

}

/**
 * XML CDATA node.
 */
class XmlCDATA extends XmlData {

  XmlCDATA(String data): super(data);

  @override
  void writeTo(StringBuffer buffer) {
    buffer.write('<![CDATA[');
    buffer.write(data);
    buffer.write(']]>');
  }
}

/**
 * XML doctype node.
 */
class XmlDoctype extends XmlData {

  XmlDoctype(String data): super(data);

  @override
  void writeTo(StringBuffer buffer) {
    buffer.write('<!DOCTYPE');
    buffer.write(data);
    buffer.write('>');
  }

}

/**
 * XML processing instruction.
 */
class XmlProcessing extends XmlData {

  final String _target;

  XmlProcessing(this._target, String data): super(data);

  String get target => _target;

  @override
  void writeTo(StringBuffer buffer) {
    buffer.write('<?');
    buffer.write(target);
    buffer.write(data);
    buffer.write('?>');
  }

}

/**
 * XML text node.
 */
class XmlText extends XmlData {

  XmlText(String data): super(data);

  @override
  void writeTo(StringBuffer buffer) {
    buffer.write(data);
  }

}

/**
 * Abstract XML node with actual children.
 */
abstract class XmlParent extends XmlNode {

  final List<XmlNode> _children;

  XmlParent(Iterable<XmlNode> children)
      : _children = children.toList() {
    for (var child in children) {
      child._parent = this;
    }
  }

  @override
  List<XmlNode> get children => _children;

  @override
  void writeTo(StringBuffer buffer) {
    for (var node in children) {
      node.writeTo(buffer);
    }
  }

}

/**
 * XML document node.
 */
class XmlDocument extends XmlParent {

  XmlDocument(Iterable<XmlNode> children): super(children);

  @override
  XmlDocument get document => this;

  XmlElement get rootElement {
    for (var node in children) {
      if (node is XmlElement) {
        return node;
      }
    }
    return null;
  }

}

/**
 * XML element node.
 */
class XmlElement extends XmlParent {

  final XmlName _name;
  final List<XmlAttribute> _attributes;

  XmlElement(XmlName name, Iterable<XmlAttribute> attributes, Iterable<XmlNode> children)
      : super(children),
        _name = name,
        _attributes = attributes.toList() {
    for (var attribute in attributes) {
      attribute._parent = this;
    }
  }

  XmlName get name => _name;
  List<XmlAttribute> get attributes => _attributes;

  String getAttribute(String key) {
    var attribute = getAttributeNode(key);
    return attribute != null ? attribute.value : null;
  }

  XmlAttribute getAttributeNode(String key) {
    for (var attribute in attributes) {
      if (attribute.name.local == key) {
        return attribute;
      }
    }
    return null;
  }

  @override
  void writeTo(StringBuffer buffer) {
    buffer.write('<');
    name.writeTo(buffer);
    for (var attribute in attributes) {
      buffer.write(' ');
      attribute.writeTo(buffer);
    }
    if (children.isEmpty) {
      buffer.write(' />');
    } else {
      buffer.write('>');
      super.writeTo(buffer);
      buffer.write('</');
      name.writeTo(buffer);
      buffer.write('>');
    }
  }

}

/**
 * XML entity name.
 */
class XmlName extends Object with _XmlWritable {

  final String _prefix;
  final String _local;

  XmlName._internal(this._prefix, this._local);

  factory XmlName(String name) {
    var index = name.indexOf(':');
    if (index < 0) {
      return new XmlName._internal(null, name);
    } else {
      return new XmlName._internal(name.substring(0, index), name.substring(index + 1, name.length)
          );
    }
  }

  String get local => _local;
  String get prefix => _prefix;
  String get qualified => toString();

  @override
  void writeTo(StringBuffer buffer) {
    if (prefix != null) {
      buffer.write(prefix);
      buffer.write(':');
    }
    buffer.write(local);
  }

  @override
  get hashCode => 17 + 37 * _prefix.hashCode + 37 * _local.hashCode;

  @override
  bool operator ==(other) {
    return other is XmlName && other.local == local && other.prefix == prefix;
  }

}

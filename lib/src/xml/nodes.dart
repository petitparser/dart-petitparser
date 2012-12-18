// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

part of xml;

/**
 * Abstract XML node.
 */
class XmlNode implements Iterable<XmlNode> {

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
  Iterator<XmlNode> iterator() {
    var nodes = new List();
    _allAllNodesTo(nodes);
    return nodes.iterator();
  }

  void _allAllNodesTo(List<XmlNode> nodes) {
    nodes.add(this);
    nodes.addAll(attributes);
    for (var node in children) {
      node._allAllNodesTo(nodes);
    }
  }

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

  /**
   * Answer a print string of the receiver.
   */
  String toString() {
    var buffer = new StringBuffer();
    writeTo(buffer);
    return buffer.toString();
  }

  /**
   * Writes the XML string of the receiver to a {@code buffer}.
   */
  abstract void writeTo(StringBuffer buffer);

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

  void writeTo(StringBuffer buffer) {
    name.writeTo(buffer);
    buffer.add('="').add(value).add('"');
  }

}

/**
 * Abstract XML data node.
 */
class XmlData extends XmlNode {

  final String _data;

  XmlData(this._data);

  String get data => _data;

}

/**
 * XML comment node.
 */
class XmlComment extends XmlData {

  XmlComment(String data) : super(data);

  void writeTo(StringBuffer buffer) {
    buffer.add('<!--').add(data).add('-->');
  }

}

/**
 * XML doctype node.
 */
class XmlDoctype extends XmlData {

  XmlDoctype(String data) : super(data);

  void writeTo(StringBuffer buffer) {
    buffer.add('<!DOCTYPE').add(data).add('>');
  }

}

/**
 * XML processing instruction.
 */
class XmlProcessing extends XmlData {

  final String _target;

  XmlProcessing(this._target, String data) : super(data);

  String get target => _target;

  void writeTo(StringBuffer buffer) {
    buffer.add('<?').add(target).add(data).add('?>');
  }

}

/**
 * XML text node.
 */
class XmlText extends XmlData {

  XmlText(String data) : super(data);

  void writeTo(StringBuffer buffer) {
    buffer.add(data);
  }

}

/**
 * Abstract XML node with actual children.
 */
class XmlParent extends XmlNode {

  final List<XmlNode> _children;

  XmlParent(Collection<XmlNode> children)
      : _children = new List.from(children) {
    for (var child in children) {
      child._parent = this;
    }
  }

  List<XmlNode> get children => _children;

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

  XmlDocument(Collection<XmlNode> children) : super(children);

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

  XmlElement(XmlName name, Collection<XmlAttribute> attributes, Collection<XmlNode> children)
      : super(children), _name = name, _attributes = new List.from(attributes) {
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

  void writeTo(StringBuffer buffer) {
    buffer.add('<');
    name.writeTo(buffer);
    for (var attribute in attributes) {
      buffer.add(' ');
      attribute.writeTo(buffer);
    }
    if (children.isEmpty) {
      buffer.add(' />');
    } else {
      buffer.add('>');
      super.writeTo(buffer);
      buffer.add('</');
      name.writeTo(buffer);
      buffer.add('>');
    }
  }

}

/**
 * XML entity name.
 */
class XmlName {

  final String _prefix;
  final String _local;

  XmlName._internal(this._prefix, this._local);

  factory XmlName(String name) {
    var index = name.indexOf(':');
    if (index < 0) {
      return new XmlName._internal(null, name);
    } else {
      return new XmlName._internal(
        name.substring(0, index),
        name.substring(index + 1, name.length));
    }
  }

  String get local => _local;
  String get prefix => _prefix;
  String get qualified => toString();

  String toString() {
    var buffer = new StringBuffer();
    writeTo(buffer);
    return buffer.toString();
  }

  void writeTo(StringBuffer buffer) {
    if (prefix != null) {
      buffer.add(prefix).add(':');
    }
    buffer.add(local);
  }

  bool operator == (XmlName obj) {
    return obj is XmlName && obj.local == local && obj.prefix == prefix;
  }

}
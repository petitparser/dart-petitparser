// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

part of xml;

/**
 * Abstract XML node.
 */
abstract class XmlNode implements Iterable<XmlNode> {

  XmlNode _parent;

  /**
   * Answer the parent node of the receiver, or [null] if there is none.
   */
  XmlNode getParent() => _parent;

  /**
   * Answer the attribute nodes of the receiver.
   */
  List<XmlAttribute> getAttributes() => [];

  /**
   * Answer the child nodes of the receiver.
   */
  List<XmlNode> getChildren() => [];

  /**
   * Answer an iterator over the receiver, all attributes and nested children.
   */
  Iterator<XmlNode> iterator() {
    List<XmlNode> nodes = new List();
    _allAllNodesTo(nodes);
    return nodes.iterator();
  }

  void _allAllNodesTo(List<XmlNode> nodes) {
    nodes.add(this);
    nodes.addAll(getAttributes());
    for (XmlNode node in getChildren()) {
      node._allAllNodesTo(nodes);
    }
  }

  /**
   * Answer the root of the subtree in which this node is found, whether that's
   * a document or another element.
   */
  XmlNode getRoot() {
    return _parent == null ? this : _parent.getRoot();
  }

  /**
   * Answer the document that contains this node, or [null] if the node is
   * not part of a document.
   */
  XmlDocument getDocument() {
    return _parent == null ? null : _parent.getDocument();
  }

  /**
   * Answer the first child of the receiver or [null].
   */
  XmlNode getFirstChild() {
    List<XmlNode> children = getChildren();
    return children.length > 0 ? children[0] : null;
  }

  /**
   * Answer the last child of the receiver or [null].
   */
  XmlNode getLastChild() {
    List<XmlNode> children = getChildren();
    return children.length > 0 ? children[children.length - 1] : null;
  }

  /**
   * Answer the next sibling of the receiver or [null].
   */
  XmlNode getNextSibling() {
    XmlNode parent = getParent();
    if (parent == null) {
      return null;
    }
    List<XmlNode> children = parent.getChildren();
    for (int i = 0; i < children.length - 1; i++) {
      if (children[i] == this) {
        return children[i + 1];
      }
    }
    return null;
  }

  /**
   * Answer the previous sibling of the receiver or [null].
   */
  XmlNode getPreviousSibling() {
    XmlNode parent = getParent();
    if (parent == null) {
      return null;
    }
    List<XmlNode> children = parent.getChildren();
    for (int i = 1; i < children.length; i++) {
      if (children[i] == this) {
        return children[i - 1];
      }
    }
    return null;
  }

  /**
   * Answer a print string of the receiver.
   */
  String toString() {
    StringBuffer buffer = new StringBuffer();
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

  XmlName getName() => _name;
  String getValue() => _value;

  void writeTo(StringBuffer buffer) {
    getName().writeTo(buffer);
    buffer.add('="').add(getValue()).add('"');
  }

}

/**
 * Abstract XML data node.
 */
abstract class XmlData extends XmlNode {

  final String _data;

  XmlData(this._data);

  String getData() => _data;

}

/**
 * XML comment node.
 */
class XmlComment extends XmlData {

  XmlComment(String data) : super(data);

  void writeTo(StringBuffer buffer) {
    buffer.add('<!--').add(getData()).add('-->');
  }

}

/**
 * XML doctype node.
 */
class XmlDoctype extends XmlData {

  XmlDoctype(String data) : super(data);

  void writeTo(StringBuffer buffer) {
    buffer.add('<!DOCTYPE').add(getData()).add('>');
  }

}

/**
 * XML processing instruction.
 */
class XmlProcessing extends XmlData {

  final String _target;

  XmlProcessing(this._target, String data) : super(data);

  String getTarget() => _target;

  void writeTo(StringBuffer buffer) {
    buffer.add('<?').add(getTarget()).add(getData()).add('?>');
  }

}

/**
 * XML text node.
 */
class XmlText extends XmlData {

  XmlText(String data) : super(data);

  void writeTo(StringBuffer buffer) {
    buffer.add(getData());
  }

}

/**
 * Abstract XML node with actual children.
 */
abstract class XmlParent extends XmlNode {

  final List<XmlNode> _children;

  XmlParent(Collection<XmlNode> children)
      : _children = new List.from(children) {
    for (XmlNode child in children) {
      child._parent = this;
    }
  }

  List<XmlNode> getChildren() => _children;

  void writeTo(StringBuffer buffer) {
    for (XmlNode node in getChildren()) {
      node.writeTo(buffer);
    }
  }

}

/**
 * XML document node.
 */
class XmlDocument extends XmlParent {

  XmlDocument(Collection<XmlNode> children) : super(children);

  XmlDocument getDocument() => this;

  XmlElement getRootElement() {
    for (XmlNode node in getChildren()) {
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
    for (XmlAttribute attribute in attributes) {
      attribute._parent = this;
    }
  }

  XmlName getName() => _name;
  List<XmlAttribute> getAttributes() => _attributes;

  String getAttribute(String key) {
    XmlAttribute attribute = getAttributeNode(key);
    return attribute != null ? attribute.getValue() : null;
  }

  XmlAttribute getAttributeNode(String key) {
    for (XmlAttribute attribute in getAttributes()) {
      if (attribute.getName().getLocal() == key) {
        return attribute;
      }
    }
    return null;
  }

  void writeTo(StringBuffer buffer) {
    buffer.add('<');
    getName().writeTo(buffer);
    for (XmlAttribute attribute in getAttributes()) {
      buffer.add(' ');
      attribute.writeTo(buffer);
    }
    if (getChildren().isEmpty()) {
      buffer.add(' />');
    } else {
      buffer.add('>');
      super.writeTo(buffer);
      buffer.add('</');
      getName().writeTo(buffer);
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
    int index = name.indexOf(':');
    if (index < 0) {
      return new XmlName._internal(null, name);
    } else {
      return new XmlName._internal(
        name.substring(0, index),
        name.substring(index + 1, name.length));
    }
  }

  String getLocal() => _local;
  String getPrefix() => _prefix;
  String getQualified() => toString();

  String toString() {
    StringBuffer buffer = new StringBuffer();
    writeTo(buffer);
    return buffer.toString();
  }

  void writeTo(StringBuffer buffer) {
    if (_prefix != null) {
      buffer.add(_prefix).add(':');
    }
    buffer.add(_local);
  }

  bool operator == (XmlName obj) {
    return obj is XmlName && obj._local == _local && obj._prefix == _prefix;
  }

}
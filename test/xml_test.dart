library xml_test;

import 'package:petitparser/xml.dart';
import 'package:unittest/unittest.dart';

void validate(XmlParser parser, String input) {
  var tree = parser.parse(input).value;
  assertTreeInvariants(tree);
  var copy = parser.parse(tree.toString()).value;
  expect(tree.toString(), copy.toString());
}

void assertTreeInvariants(XmlNode xml) {
  assertDocumentInvariant(xml);
  assertParentInvariant(xml);
  assertForwardInvariant(xml);
  assertBackwardInvariant(xml);
  assertNameInvariant(xml);
  assertAttributeInvariant(xml);
}

void assertDocumentInvariant(XmlNode xml) {
  var root = xml.root;
  for (var child in xml) {
    expect(root, same(child.root));
    expect(root, same(child.document));
  }
  var document = xml.document;
  expect(document.children, contains(document.rootElement));
}

void assertParentInvariant(XmlNode xml) {
  for (var node in xml) {
    if (node is XmlDocument) {
      expect(node.parent, isNull);
    }
    for (var child in node.children) {
      expect(child.parent, same(node));
    }
    for (var attribute in node.attributes) {
      expect(attribute.parent, same(node));
    }
  }
}

void assertForwardInvariant(XmlNode xml) {
  for (var node in xml) {
    var current = node.firstChild;
    for (var i = 0; i < node.children.length; i++) {
      expect(node.children[i], same(current));
      current = current.nextSibling;
    }
    expect(current, isNull);
  }
}

void assertBackwardInvariant(XmlNode xml) {
  for (var node in xml) {
    var current = node.lastChild;
    for (var i = node.children.length - 1; i >= 0; i--) {
      expect(node.children[i], same(current));
      current = current.previousSibling;
    }
    expect(current, isNull);
  }
}

void assertNameInvariant(XmlNode xml) {
  for (var node in xml) {
    if (node is XmlElement) {
      var element = node;
      assertQualifiedInvariant(element.name);
    }
    if (node is XmlAttribute) {
      var attribute = node;
      assertQualifiedInvariant(attribute.name);
    }
  }
}

void assertQualifiedInvariant(XmlName name) {
  expect(name.local, isNot(isEmpty));
  expect(name.qualified, endsWith(name.local));
  if (name.prefix != null) {
    expect(name.qualified, startsWith(name.prefix));
  }
  expect(name.qualified, name.toString());
}

void assertAttributeInvariant(XmlNode xml) {
  for (var node in xml) {
    if (node is XmlElement) {
      var element = node;
      for (var attribute in element.attributes) {
        expect(attribute.value, same(element.getAttribute(attribute.name.local)));
        expect(attribute, same(element.getAttributeNode(attribute.name.local)));
      }
      if (element.attributes.isEmpty) {
        expect(element.getAttribute('foo'), isNull);
        expect(element.getAttributeNode('foo'), isNull);
      }
    }
  }
}

void main() {
  final parser = new XmlParser();

  test('comment', () {
    validate(parser, '<?xml version="1.0" encoding="UTF-8"?><schema><!-- comment --></schema>');
  });
  test('comment with xml', () {
    validate(parser, '<?xml version="1.0" encoding="UTF-8"?><schema><!-- <foo></foo> --></schema>');
  });
  test('complicated', () {
    validate(parser, '<?xml foo?>\n'
      '<foo>\n'
      '  <bar a="fasdfasdf">\n'
      '    <zork/>\n'
      '    <zonk/>\n'
      '  </bar>\n'
      '  <!-- with comment -->\n'
      '</foo>');
  });
  test('doctype', () {
    validate(parser, '<?xml version="1.0" encoding="UTF-8"?>\n'
      '  <!DOCTYPE freaking <schema> [ <!-- schema --> ]  >\n'
      '  <schema></schema>');
  });
  test('empty element', () {
    validate(parser, '<?xml version="1.0" encoding="UTF-8"?><schema/>');
  });
  test('namespace', () {
    validate(parser, '<?xml version="1.0" encoding="UTF-8"?><xs:schema></xs:schema>');
  });
  test('simple', () {
    validate(parser, '<?xml version="1.0" encoding="UTF-8"?><schema></schema>');
  });
  test('simple attribute', () {
    validate(parser, '<?xml version="1.0" encoding="UTF-8"?><schema foo="bar"></schema>');
  });
  test('simple single quote attribute', () {
    validate(parser, '<?xml version="1.0" encoding="UTF-8"?><schema foo=\'bar\'></schema>');
  });
  test('whitespace after prolog', () {
    validate(parser, '<?xml version="1.0" encoding="UTF-8"?>\n'
      '  <schema></schema>\n');
  });
  test('cdata', () {
    var cdataInput = '<?xml version="1.0" encoding="UTF-8"?>'
      '<data><![CDATA[Methinks <word> it <word> is like a weasel!]]></data>';
    validate(parser, cdataInput);
  });
  test('bookstore', () {
    validate(parser, '<?xml version="1.0" encoding="ISO-8859-1"?>\n'
      '<bookstore>\n'
      '  <book>\n'
      '    <title lang="eng">Harry Potter</title>\n'
      '    <price>29.99</price>\n'
      '  </book>\n'
      '  <book>\n'
      '    <title lang="eng">Learning XML</title>\n'
      '    <price>39.95</price>\n'
      '  </book>\n'
      '</bookstore>');
  });
  test('shiporder', () {
    validate(parser, '<?xml version="1.0"?>\n'
      '<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema">\n'
      '\n'
      '  <xsd:annotation>\n'
      '    <xsd:documentation xml:lang="en">\n'
      '     Purchase order schema for Example.com.\n'
      '     Copyright 2000 Example.com. All rights reserved.\n'
      '    </xsd:documentation>\n'
      '  </xsd:annotation>\n'
      '\n'
      '  <xsd:element name="purchaseOrder" type="PurchaseOrderType"/>\n'
      '\n'
      '  <xsd:element name="comment" type="xsd:string"/>\n'
      '\n'
      '  <xsd:complexType name="PurchaseOrderType">\n'
      '    <xsd:sequence>\n'
      '      <xsd:element name="shipTo" type="USAddress"/>\n'
      '      <xsd:element name="billTo" type="USAddress"/>\n'
      '      <xsd:element ref="comment" minOccurs="0"/>\n'
      '      <xsd:element name="items"  type="Items"/>\n'
      '    </xsd:sequence>\n'
      '    <xsd:attribute name="orderDate" type="xsd:date"/>\n'
      '  </xsd:complexType>\n'
      '\n'
      '  <xsd:complexType name="USAddress">\n'
      '    <xsd:sequence>\n'
      '      <xsd:element name="name"   type="xsd:string"/>\n'
      '      <xsd:element name="street" type="xsd:string"/>\n'
      '      <xsd:element name="city"   type="xsd:string"/>\n'
      '      <xsd:element name="state"  type="xsd:string"/>\n'
      '      <xsd:element name="zip"    type="xsd:decimal"/>\n'
      '    </xsd:sequence>\n'
      '    <xsd:attribute name="country" type="xsd:NMTOKEN"\n'
      '                   fixed="US"/>\n'
      '  </xsd:complexType>\n'
      '\n'
      '  <xsd:complexType name="Items">\n'
      '    <xsd:sequence>\n'
      '      <xsd:element name="item" minOccurs="0" maxOccurs="unbounded">\n'
      '        <xsd:complexType>\n'
      '          <xsd:sequence>\n'
      '            <xsd:element name="productName" type="xsd:string"/>\n'
      '            <xsd:element name="quantity">\n'
      '              <xsd:simpleType>\n'
      '                <xsd:restriction base="xsd:positiveInteger">\n'
      '                  <xsd:maxExclusive value="100"/>\n'
      '                </xsd:restriction>\n'
      '              </xsd:simpleType>\n'
      '            </xsd:element>\n'
      '            <xsd:element name="USPrice"  type="xsd:decimal"/>\n'
      '            <xsd:element ref="comment"   minOccurs="0"/>\n'
      '            <xsd:element name="shipDate" type="xsd:date" minOccurs="0"/>\n'
      '          </xsd:sequence>\n'
      '          <xsd:attribute name="partNum" type="SKU" use="required"/>\n'
      '        </xsd:complexType>\n'
      '      </xsd:element>\n'
      '    </xsd:sequence>\n'
      '  </xsd:complexType>\n'
      '\n'
      '  <!-- Stock Keeping Unit, a code for identifying products -->\n'
      '  <xsd:simpleType name="SKU">\n'
      '    <xsd:restriction base="xsd:string">\n'
      '      <xsd:pattern value="\\d{3}-[A-Z]{2}"/>\n'
      '    </xsd:restriction>\n'
      '  </xsd:simpleType>\n'
      '\n'
      '</xsd:schema>');
  });
  test('atom', () {
    validate(parser, '<?xml version="1.0" encoding="UTF-8"?>'
      '<app:service>'
        '<app:workspace>'
          '<cmisra:repositoryInfo xmlns:ns3="http://docs.oasis-open.org/ns/cmis/messaging/200908/">'
          '</cmisra:repositoryInfo>'
        '</app:workspace>'
      '</app:service>');
  });
}

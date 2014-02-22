part of xml;

/**
 * XML parser definition.
 */
class XmlParser extends XmlGrammar {

  @override
  void initialize() {
    super.initialize();

    action('attribute', (each) => new XmlAttribute(each[0], each[1]));
    action('comment', (each) => new XmlComment(each));
    action('cdata', (each) => new XmlCDATA(each));
    action('doctype', (each) => new XmlDoctype(each));
    action('document', (each) => new XmlDocument(each));
    action('element', (each) => new XmlElement(each[0], each[1], each[2]));
    action('processing', (each) => new XmlProcessing(each[0], each[1]));
    action('qualified', (each) => new XmlName(each));
    action('characterData', (each) => new XmlText(each));
  }

}

package xsd;

import xsd.Xsd;
import sys.io.File;

using Std;
using tools.TextTools;

class XsdParser {
	final xsdFile:String;

	public function new(xsdFile:String) {
		this.xsdFile = xsdFile;
	}

	public function parse() {
		final content = File.getContent(this.xsdFile);
		final xml = Xml.parse(content);
		final schema = Schema.parse(xml);

		var tree = parseItems(xml);
		trace(tree);
		// build(tree, '');
		findTypeNames(tree);
	}

	function parseItems(xml:Xml, schemaNS:String = 'MusicXML'):XsdTree {
		function _parseItems(xml:Xml):XsdTree {
			final children:XsdTree = [];
			for (child in xml.elements()) {
				final name = child.get('name').pascalCase();
				final type = child.get('type');
				final ref = child.get('ref');
				final base = child.get('base');

				final items = _parseItems(child);

				switch child.nodeName {
					case 'xs:schema':
						children.push(NodeSchema(items, schemaNS));
					case 'xs:element':
						children.push(NodeElement(items, name, type));
					case 'xs:annotation':
						children.push(NodeAnnotation(items));
					case 'xs:documentation':
						final doc = child.firstChild().string();
						children.push(NodeDocumentation(doc));
					case 'xs:complexType':
						children.push(NodeComplexType(items, name));
					case 'xs:sequence':
						children.push(NodeSequence(items));
					case 'xs:group':
						children.push(NodeGroup(items, name, ref));
					case 'xs:attributeGroup':
						children.push(NodeAttributeGroup(items, ref));
					case 'xs:attribute':
						children.push(NodeAttribute(items, name, type));
					case 'xs:extension':
						children.push(NodeExtension(items, base));
					case 'xs:simpleContent':
						children.push(NodeSimpleContent(items));
					default:
						throw 'Unimplemented node type: ${child.nodeName}';
				}
			}
			return children;
		}
		return _parseItems(xml);
	}

	function findTypeNames(tree:XsdTree) {
		final typeNames = [];
		function _findTypeNames(tree:XsdTree) {
			for (node in tree) {
				switch node {
					case NodeSchema(items, name):
						typeNames.push(name);
						_findTypeNames(items);
					case NodeElement(items, name, type):
						switch type {
							case null:
								typeNames.push(name);
							case 'xs:string':
							default:
						}
					case NodeComplexType(items, name):
						if (name != null) {
							typeNames.push(name);
						} else {}
					case NodeGroup(items, name, ref):
						if (name != null && ref == null) {
							typeNames.push(name);
							if (hasNodeSequence(items)) {
								final elementsName = name + 'Element';
								trace('Group has sequence ' + elementsName);
								final sequenceItems = getNodeSequenceItems(items);
								if (sequenceItems != null) {
									trace('- sequence: ' + sequenceItems);
									for (item in sequenceItems) {
										switch item {
											case NodeElement(items, name, type):
												final altName = elementsName + name;
												final itemName = name.toLowerCase();
												if (type != null) {
													final typeName = type == 'xs:string' ? 'String' : name;
													trace('- - $altName($itemName:$typeName)');
												}

											default:
										}
									}
								}
							}
						}

					default:
				}
			}
		}
		_findTypeNames(tree);
		trace('Typenames:');
		for (tn in typeNames)
			trace('- $tn');
		return typeNames;
	}

	function build(tree:XsdTree, s:String) {
		for (node in tree) {
			switch node {
				case NodeSchema(items, name):
					trace('Create type Schema ' + name.pascalCase());
					build(items, s);

				case NodeElement(items, name, type):
					trace('Create type Element ' + name.pascalCase());

				case NodeComplexType(items, name):
					if (name != null) {
						trace('Create type ComplexType ' + name.pascalCase());
					} else {
						trace('Create type ComplexType (anonymous)');
					}
					final sequenceItems = getNodeSequenceItems(items);
					if (sequenceItems != null) {
						trace('- sequence: ' + sequenceItems);
					}

				default:
			}
		}
	}

	function hasNodeSequence(items:XsdTree):Bool {
		for (item in items) {
			final has = switch item {
				case NodeSequence(items): true;
				default: false;
			}
			if (has)
				return true;
		}
		return false;
	}

	function getNodeSequenceItems(items:XsdTree):XsdTree {
		for (item in items) {
			final sequenceItems = switch item {
				case NodeSequence(sequenceItems): sequenceItems;
				default: null;
			}
			if (sequenceItems != null)
				return sequenceItems;
		}
		return null;
	}

	function hasNodeGroup(items:XsdTree):Bool {
		for (item in items) {
			final has = switch item {
				case NodeGroup(items, name, ref): true;
				default: false;
			}
			if (has)
				return true;
		}
		return false;
	}
}

package xsd;

import haxe.Exception;

using Std;

class Schema {
	final children:Array<SchemaChild>;

	public function new(children:Array<SchemaChild>) {
		this.children = children;
	}

	function toString()
		return 'Schema(' + children.map(c -> c.string()) + ')';

	static public function parse(xsd:Xml) {
		if (xsd.firstElement().nodeName != 'xs:schema')
			throw new Exception('xml first element type is not "xs:schema" but ' + xsd.firstElement().nodeName);

		final children:Array<SchemaChild> = [];
		for (element in xsd.firstElement().elements()) {
			switch element.nodeName {
				case 'xs:element':
					children.push(SchemaChildElement(Element.parse(element)));
				case 'xs:complexType':
					children.push(SchemaChildComplexType(ComplexType.parse(element)));
				case 'xs:simpleType':
					children.push(SchemaChildSimpleType(SimpleType.parse(element)));
				default:
					throw new Exception('Schema child "${element.nodeName}" not implemented');
					null;
			}
		}
		return new Schema(children);
	}
}

enum SchemaChild {
	SchemaChildElement(item:Element);
	SchemaChildComplexType(item:ComplexType);
	SchemaChildSimpleType(item:SimpleType);
}

class Element {
	final name:String;
	final type:String;

	final children:Array<ElementChild>;

	public function new(name:String, type:String, children:Array<ElementChild>) {
		this.name = name;
		this.type = type;
		this.children = children;
	}

	function toString()
		return 'Element(${this.name}, ${this.type}, ' + children.map(c -> c.string()) + ')';

	static public function parse(item:Xml) {
		final name = item.get('name');
		final type = item.get('type');
		final children = [];
		for (child in item.elements()) {
			switch child.nodeName {
				case 'xs:complexType':
					children.push(ElementChildComplexType(ComplexType.parse(child)));
				default:
					throw new Exception('Element child "${child.nodeName}" not implemented');
			}
		}

		return new Element(name, type, cast children);
	}
}

enum ElementChild {
	ElementChildComplexType(item:ComplexType);
}

class ComplexType {
	final name:String;

	// final type:String;
	final children:Array<ComplexTypeChild>;

	public function new(name:String, children:Array<ComplexTypeChild>) {
		this.name = name;
		// this.type = type;
		this.children = children;
	}

	function toString()
		return 'ComplexType(' + children.map(c -> c.string()) + ')';

	static public function parse(item:Xml) {
		final name = item.get('name');
		final children = [];
		for (child in item.elements()) {
			switch child.nodeName {
				case 'xs:sequence':
					children.push(ComplexTypeChildSequence(Sequence.parse(child)));
				case 'xs:attribute':
					children.push(ComplexTypeChildAttribute(Attribute.parse(child)));
				case 'xs:complexContent':
					children.push(ComplexTypeChildComplexContent(ComplexContent.parse(child)));

				default:
					throw new Exception('ComplexType child "${child.nodeName}" not implemented');
			}
		}

		return new ComplexType(name, cast children);
	}
}

enum ComplexTypeChild {
	ComplexTypeChildSequence(item:Sequence);
	ComplexTypeChildAttribute(item:Attribute);
	ComplexTypeChildComplexContent(item:ComplexContent);
}

class Sequence {
	final children:Array<SequenceChild>;

	public function new(children:Array<SequenceChild>) {
		this.children = children;
	}

	function toString()
		return 'Sequence(' + children.map(c -> c.string()) + ')';

	static public function parse(item:Xml) {
		final children = [];
		for (child in item.elements()) {
			switch child.nodeName {
				case 'xs:element':
					children.push(SequenceChildElement(Element.parse(child)));
				default:
					throw new Exception('Sequence child "${child.nodeName}" not implemented');
			}
		}
		return new Sequence(children);
	}
}

enum SequenceChild {
	SequenceChildElement(item:Element);
}

class Attribute {
	final name:String;
	final type:String;
	final use:String;
	final children:Array<AttributeChild>;

	public function new(name:String, type:String, use:String, children:Array<AttributeChild>) {
		this.name = name;
		this.type = type;
		this.use = use;
		this.children = children;
	}

	function toString()
		return 'Attribute(${this.name}, ${this.type}, ${this.use}, $children)';

	static public function parse(item:Xml) {
		final name = item.get('name');
		final type = item.get('type');
		final use = item.get('use');
		final children = [];
		for (child in item.elements()) {
			switch child.nodeName {
				case 'xs:simpleType':
					children.push(AttributeChildSimpleType(SimpleType.parse(child)));
				default:
					throw new Exception('Attribute child "${child.nodeName}" not implemented');
			}
		}

		return new Attribute(name, type, use, cast children);
	}
}

enum AttributeChild {
	AttributeChildSimpleType(item:SimpleType);
}

class ComplexContent {
	final children:Array<ComplexContentChild>;

	public function new(children:Array<ComplexContentChild>) {
		this.children = children;
	}

	function toString()
		return 'ComplexContent($children)';

	static public function parse(item:Xml) {
		final children = [];
		for (child in item.elements()) {
			switch child.nodeName {
				case 'xs:restriction':
					children.push(ComplexContentChildRestriction(Restriction.parse(child)));
				case 'xs:extension':
					children.push(ComplexContentChildExtension(Extension.parse(child)));
				default:
					throw new Exception('ComplexContent child "${child.nodeName}" not implemented');
			}
		}
		return new ComplexContent(cast children);
	}
}

enum ComplexContentChild {
	ComplexContentChildRestriction(item:Restriction);
	ComplexContentChildExtension(item:Extension);
}

class SimpleType {
	final children:Array<SimpleTypeChild>;

	public function new(children:Array<SimpleTypeChild>) {
		this.children = children;
	}

	function toString()
		return 'SimpleType($children)';

	static public function parse(item:Xml) {
		final children = [];
		for (child in item.elements()) {
			switch child.nodeName {
				case 'xs:restriction':
					children.push(SimpleTypeChildRestriction(Restriction.parse(child)));

				default:
					throw new Exception('SimpleType child "${child.nodeName}" not implemented');
			}
		}
		return new SimpleType(children);
	}
}

enum SimpleTypeChild {
	SimpleTypeChildRestriction(item:Restriction);
}

class Restriction {
	final base:String;
	final children:Array<RestrictionChild>;

	public function new(base:String, children:Array<RestrictionChild>) {
		this.base = base;
		this.children = children;
	}

	function toString()
		return 'Restriction($base, $children)';

	static public function parse(item:Xml) {
		final base = item.get('base');
		final children = [];
		for (child in item.elements()) {
			switch child.nodeName {
				case 'xs:enumeration':
					children.push(RestrictionChildEnumeration(Enumeration.parse(child)));
				case 'xs:sequence':
					children.push(RestrictionChildSequence(Sequence.parse(child)));
				case 'xs:attribute':
					children.push(RestrictionChildAttribute(Attribute.parse(child)));
				case 'xs:pattern':
					children.push(RestrictionChildPattern(Pattern.parse(child)));
				default:
					throw new Exception('Restriction child "${child.nodeName}" not implemented');
			}
		}
		return new Restriction(base, children);
	}
}

enum RestrictionChild {
	RestrictionChildEnumeration(item:Enumeration);
	RestrictionChildSequence(item:Sequence);
	RestrictionChildAttribute(item:Attribute);
	RestrictionChildPattern(item:Pattern);
}

class Extension {
	final base:String;
	final children:Array<ExtensionChild>;

	public function new(base:String, children:Array<ExtensionChild>) {
		this.base = base;
		this.children = children;
	}

	function toString()
		return 'Extension($base, $children)';

	static public function parse(item:Xml) {
		final base = item.get('base');
		final children = [];
		for (child in item.elements()) {
			switch child.nodeName {
				// case 'xs:enumeration':
				// 	final e = Enumeration.parse(child);
				// 	children.push(cast e);
				case 'xs:sequence':
					children.push(ExtensionChildSequence(Sequence.parse(child)));
				case 'xs:attribute':
					children.push(ExtensionChildAttribute(Attribute.parse(child)));
				default:
					throw new Exception('Extension child "${child.nodeName}" not implemented');
			}
		}
		return new Extension(base, cast children);
	}
}

enum ExtensionChild {
	ExtensionChildSequence(item:Sequence);
	ExtensionChildAttribute(item:Attribute);
}

class Enumeration {
	final value:String;

	public function new(value:String) {
		this.value = value;
	}

	function toString()
		return 'Enumeration($value)';

	static public function parse(item:Xml) {
		final value = item.get('value');
		return new Enumeration(value);
	}
}

class Pattern {
	final value:String;

	public function new(value:String) {
		this.value = value;
	}

	function toString()
		return 'Pattern($value)';

	static public function parse(item:Xml) {
		final value = item.get('value');
		return new Pattern(value);
	}
}

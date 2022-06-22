package xsd;

import utest.Dispatcher.Notifier;

using Std;

import haxe.exceptions.NotImplementedException;

class Schema implements ISchema {
	final children:Array<ISchemaChild>;

	public function new(children:Array<ISchemaChild>) {
		this.children = children;
	}

	function toString()
		return 'Schema(' + children.map(c -> c.string()) + ')';

	static public function parse(xsd:Xml) {
		if (xsd.firstElement().nodeName != 'xs:schema')
			throw NotImplementedException;

		final children = [];
		for (element in xsd.firstElement().elements()) {
			switch element.nodeName {
				case 'xs:element':
					final e = Element.parse(element);
					children.push(cast e);
				case 'xs:complexType':
					final e = ComplexType.parse(element);
					children.push(cast e);
				default:
					throw NotImplementedException;
					null;
			}
		}
		return new Schema(cast children);
	}
}

class Element implements ISchemaChild implements ISequenceChild {
	final name:String;
	final type:String;

	final children:Array<IElementChild>;

	public function new(name:String, type:String, children:Array<IElementChild>) {
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
					children.push(ComplexType.parse(child));
				default:
					throw NotImplementedException;
			}
		}

		return new Element(name, type, cast children);
	}
}

class ComplexType implements ISchemaChild {
	final name:String;

	// final type:String;
	final children:Array<IComplexTypeChild>;

	public function new(name:String, children:Array<IComplexTypeChild>) {
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
					final e = Sequence.parse(child);
					children.push(cast e);
				case 'xs:attribute':
					final e = Attribute.parse(child);
					children.push(cast e);
				case 'xs:complexContent':
					final e = ComplexContent.parse(child);
					children.push(cast e);

				default:
					throw child.nodeName;
			}
		}

		return new ComplexType(name, cast children);
	}
}

class Sequence implements IComplexTypeChild implements IRestrictionChild {
	final children:Array<ISequenceChild>;

	public function new(children:Array<ISequenceChild>) {
		this.children = children;
	}

	function toString()
		return 'Sequence(' + children.map(c -> c.string()) + ')';

	static public function parse(item:Xml) {
		final children = [];
		for (child in item.elements()) {
			switch child.nodeName {
				case 'xs:element':
					final e = Element.parse(child);
					children.push(e);
				default:
					throw NotImplementedException;
			}
		}
		return new Sequence(cast children);
	}
}

class Attribute implements IComplexTypeChild implements IRestrictionChild {
	final name:String;
	final type:String;
	final children:Array<IAttributeChild>;

	public function new(name:String, type:String, children:Array<IAttributeChild>) {
		this.name = name;
		this.type = type;
		this.children = children;
	}

	function toString()
		return 'Attribute(${this.name}, ${this.type}, $children)';

	static public function parse(item:Xml) {
		final name = item.get('name');
		final type = item.get('type');
		final children = [];
		for (child in item.elements()) {
			switch child.nodeName {
				case 'xs:simpleType':
					final e = SimpleType.parse(child);
					children.push(e);
				default:
					throw NotImplementedException;
			}
		}

		return new Attribute(name, type, cast children);
	}
}

class ComplexContent implements IComplexTypeChild {
	final children:Array<IComplexContentChild>;

	public function new(children:Array<IComplexContentChild>) {
		this.children = children;
	}

	function toString()
		return 'ComplexContent($children)';

	static public function parse(item:Xml) {
		final children = [];
		for (child in item.elements()) {
			switch child.nodeName {
				case 'xs:restriction':
					final e = Restriction.parse(child);
					children.push(e);
				default:
					throw 'Error ComplexContent ' + child.nodeName;
			}
		}
		return new ComplexContent(cast children);
	}
}

class SimpleType implements IAttributeChild {
	final children:Array<ISimpleTypeChild>;

	public function new(children:Array<ISimpleTypeChild>) {
		this.children = children;
	}

	function toString()
		return 'SimpleType($children)';

	static public function parse(item:Xml) {
		final children = [];
		for (child in item.elements()) {
			switch child.nodeName {
				case 'xs:restriction':
					final e = Restriction.parse(child);
					children.push(e);
				default:
					throw NotImplementedException;
			}
		}
		return new SimpleType(cast children);
	}
}

class Restriction implements ISimpleTypeChild implements IComplexContentChild {
	final base:String;
	final children:Array<IRestrictionChild>;

	public function new(base:String, children:Array<IRestrictionChild>) {
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
					final e = Enumeration.parse(child);
					children.push(cast e);
				case 'xs:sequence':
					final e = Sequence.parse(child);
					children.push(cast e);
				case 'xs:attribute':
					final e = Attribute.parse(child);
					children.push(cast e);
				default:
					throw child.nodeName;
			}
		}
		return new Restriction(base, cast children);
	}
}

class Enumeration implements IRestrictionChild {
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

// enum Xsd {
// 	Schema(elements:Array<SchemaChild>);
// }
// enum SchemaChild {
// 	XsElement(name:String, type:String, children:Array<SchemaChild>);
// 	XsComplexType(name:String);
// }

interface ISchema {}
interface ISchemaChild {}
interface IComplexTypeChild {}
interface IElementChild {}
interface ISequenceChild {}
interface IAttributeChild {}
interface ISimpleTypeChild {}
interface IRestrictionChild {}
interface IComplexContentChild {}

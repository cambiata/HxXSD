package xsd;

import haxe.ds.StringMap;
import tools.AbstractEnumTools;
import haxe.Exception;

using Std;
using StringTools;

class Schema {
	public final children:Array<SchemaChild>;
	public final childmap:StringMap<IName>;

	public function new(children:Array<SchemaChild>, childmap:StringMap<IName>) {
		this.children = children;
		this.childmap = new StringMap();
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
					children.push(ChildElement(Element.parse(element)));
				case 'xs:complexType':
					children.push(ChildComplexType(ComplexType.parse(element)));
				case 'xs:simpleType':
					children.push(ChildSimpleType(SimpleType.parse(element)));
				case 'xs:annotation':
				// children.push(ChildAnnotation(Annotation.parse(element)));
				case 'xs:import':
					children.push(ChildImport(Import.parse(element)));
				case 'xs:attributeGroup':
					children.push(ChildAttributeGroup(AttributeGroup.parse(element)));
				case 'xs:group':
					children.push(ChildGroup(Group.parse(element)));
				default:
					throw new Exception('Schema child "${element.nodeName}" not implemented');
					null;
			}
		}

		var childmap:StringMap<IName> = new StringMap();

		for (child in children) {
			switch child {
				case ChildElement(item):
					childmap.set(item.name, item);
				case ChildComplexType(item):
					childmap.set(item.name, item);
				case ChildGroup(item):
					childmap.set(item.name, item);
				default:
			}
		}

		return new Schema(children, childmap);
	}

	// public function getChildrenMap() {
	// 	for (child in this.children) {
	// 		final name = switch child {
	// 			case ChildElement(item):
	// 				item.name;
	// 			case ChildComplexType(item):
	// 				item.name;
	// 			case ChildGroup(item):
	// 				item.name;
	// 			default:
	// 				'---';
	// 		}
	// 		trace(name);
	// 	}
	// }
}

enum SchemaChild {
	ChildElement(item:Element);
	ChildComplexType(item:ComplexType);
	ChildSimpleType(item:SimpleType);
	ChildAnnotation(item:Annotation);
	ChildImport(item:Import);
	ChildAttributeGroup(item:AttributeGroup);
	ChildGroup(item:Group);
}

class AttributeGroup {
	final children:Array<AttributeGroupChild>;

	public function new(children:Array<AttributeGroupChild>) {
		this.children = children;
	}

	public function toString()
		return 'AttributeGroup($children)';

	static public function parse(item:Xml) {
		final children = [];
		for (child in item.elements()) {
			switch child.nodeName {
				case 'xs:attribute':
					children.push(AttributeGroupChild.ChildAttribute(Attribute.parse(child)));
				case 'xs:annotation':
					children.push(AttributeGroupChild.ChildAnnotation(Annotation.parse(child)));
			}
		}

		return new AttributeGroup(children);
	}
}

enum AttributeGroupChild {
	ChildAttribute(item:Attribute);
	ChildAnnotation(item:Annotation);
}

interface IName {
	final name:String;
}

class Element implements IName {
	public final name:String;
	public final type:String;

	public final children:Array<ElementChild>;

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
					children.push(ChildComplexType(ComplexType.parse(child)));
				case 'xs:annotation':
					children.push(ChildAnnotation(Annotation.parse(child)));
				default:
					throw new Exception('Element child "${child.nodeName}" not implemented');
			}
		}

		return new Element(name, type, cast children);
	}
}

enum ElementChild {
	ChildComplexType(item:ComplexType);
	ChildAnnotation(item:Annotation);
}

class Annotation {
	final children:Array<AnnotationChild>;

	public function new(children:Array<AnnotationChild>) {
		this.children = children;
	}

	function toString()
		return 'Annotation(' + children.map(c -> c.string()) + ')';

	static public function parse(item:Xml) {
		final children = [];
		for (child in item.elements()) {
			switch child.nodeName {
				case 'xs:documentation':
					children.push(ChildDocumentation(Documentation.parse(child)));
				default:
					throw new Exception('Annotation child "${child.nodeName}" not implemented');
			}
		}
		return new Annotation(children);
	}
}

enum AnnotationChild {
	ChildDocumentation(item:Documentation);
}

class Import {
	final namespace:String;
	final schemaLocation:String;

	public function new(namespace:String, schemaLocation:String) {
		this.namespace = namespace;
		this.schemaLocation = schemaLocation;
	}

	static public function parse(xml:Xml) {
		final namespace = xml.get('namespace');
		final schemaLocation = xml.get('schemaLocation');

		return new Import(namespace, schemaLocation);
	}
}

class Documentation {
	final doc:String;

	public function new(doc:String) {
		this.doc = doc;
	}

	static public function parse(item:Xml) {
		final doc = item.firstChild().string();
		return new Documentation(doc);
	}
}

class ComplexType implements IName {
	public final name:String;

	// final type:String;
	final children:Array<ComplexTypeChild>;

	public function new(name:String, children:Array<ComplexTypeChild>) {
		this.name = name;
		// this.type = type;
		this.children = children;
	}

	function toString()
		return 'ComplexType($name, ' + children.map(c -> c.string()) + ')';

	static public function parse(item:Xml) {
		final name = item.get('name');
		final children = [];
		for (child in item.elements()) {
			switch child.nodeName {
				case 'xs:sequence':
					children.push(ComplexTypeChild.ChildSequence(Sequence.parse(child)));
				case 'xs:attribute':
					children.push(ComplexTypeChild.ChildAttribute(Attribute.parse(child)));
				case 'xs:complexContent':
					children.push(ComplexTypeChild.ChildComplexContent(ComplexContent.parse(child)));
				case 'xs:annotation':
					children.push(ComplexTypeChild.ChildAnnotation(Annotation.parse(child)));
				case 'xs:simpleContent':
					children.push(ComplexTypeChild.ChildSimpleContent(SimpleContent.parse(child)));
				case 'xs:attributeGroup':
					children.push(ComplexTypeChild.ChildAttributeGroup(AttributeGroup.parse(child)));
				case 'xs:choice':
					children.push(ComplexTypeChild.ChildChoice(Choice.parse(child)));
				case 'xs:group':
					children.push(ComplexTypeChild.ChildGroup(Group.parse(child)));
				default:
					throw new Exception('ComplexType child "${child.nodeName}" not implemented');
			}
		}

		return new ComplexType(name, cast children);
	}
}

enum ComplexTypeChild {
	ChildSequence(item:Sequence);
	ChildAttribute(item:Attribute);
	ChildComplexContent(item:ComplexContent);
	ChildAnnotation(item:Annotation);
	ChildSimpleContent(item:SimpleContent);
	ChildAttributeGroup(item:AttributeGroup);
	ChildChoice(item:Choice);
	ChildGroup(item:Group);
}

class Choice {
	final children:Array<Element>;

	public function new(children:Array<Element>) {
		this.children = children;
	}

	function toString()
		return 'Choice($children)';

	static public function parse(item:Xml) {
		final children = [];
		for (child in item.elements()) {
			switch child.nodeName {
				case 'xs:element':
					children.push(Element.parse(child));
			}
		}
		return new Choice(children);
	}
}

class SimpleContent {
	final children:Array<SimpleContentChild>;

	public function new(children:Array<SimpleContentChild>) {
		this.children = children;
	}

	function toString()
		return 'SimpleContent($children)';

	static public function parse(item:Xml) {
		final children = [];
		for (child in item.elements()) {
			switch child.nodeName {
				case 'xs:extension':
					children.push(SimpleContentChild.ChildExtension(Extension.parse(child)));
				default:
					throw 'ComplexType child "${child.nodeName}" not implemented';
			}
		}

		return new SimpleContent(children);
	}
}

enum SimpleContentChild {
	ChildExtension(item:Extension);
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
					children.push(ChildElement(Element.parse(child)));
				case 'xs:choice':
					children.push(ChildChoice(Choice.parse(child)));
				case 'xs:group':
					children.push(ChildGroup(Group.parse(child)));
				case 'xs:sequence':
					children.push(ChildSequence(Sequence.parse(child)));
				default:
					throw new Exception('Sequence child "${child.nodeName}" not implemented');
			}
		}
		return new Sequence(children);
	}
}

enum SequenceChild {
	ChildElement(item:Element);
	ChildChoice(item:Choice);
	ChildGroup(item:Group);
	ChildSequence(item:Sequence);
}

class Group implements IName {
	final ref:String;

	public final name:String;

	public function new(ref:String, name:String) {
		this.ref = ref;
		this.name = name;
	}

	static public function parse(item:Xml) {
		final ref = item.get('ref');
		final name = item.get('name');
		return new Group(ref, name);
	}
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
					children.push(ChildSimpleType(SimpleType.parse(child)));
				default:
					throw new Exception('Attribute child "${child.nodeName}" not implemented');
			}
		}

		return new Attribute(name, type, use, cast children);
	}
}

enum AttributeChild {
	ChildSimpleType(item:SimpleType);
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
					children.push(ComplexContentChild.ChildRestriction(Restriction.parse(child)));
				case 'xs:extension':
					children.push(ComplexContentChild.ChildExtension(Extension.parse(child)));
				default:
					throw new Exception('ComplexContent child "${child.nodeName}" not implemented');
			}
		}
		return new ComplexContent(cast children);
	}
}

enum ComplexContentChild {
	ChildRestriction(item:Restriction);
	ChildExtension(item:Extension);
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
					children.push(ChildRestriction(Restriction.parse(child)));
				case 'xs:annotation':
					children.push(ChildAnnotation(Annotation.parse(child)));
				case 'xs:union':
					children.push(ChildUnion(Union.parse(child)));
				default:
					throw new Exception('SimpleType child "${child.nodeName}" not implemented');
			}
		}
		return new SimpleType(children);
	}
}

enum SimpleTypeChild {
	ChildRestriction(item:Restriction);
	ChildAnnotation(item:Annotation);
	ChildUnion(item:Union);
}

class Union {
	final memberTypes:Array<String>;

	public function new(memberTypes:Array<String>) {
		this.memberTypes = memberTypes;
	}

	function toString()
		return 'SimpleType($memberTypes)';

	static public function parse(xml:Xml) {
		var s = xml.get('memberTypes');
		var memberTypes = s.split(' ');
		return new Union(memberTypes);
	}
}

class Restriction {
	final base:RestrictionBase;
	final children:Array<RestrictionChild>;

	public function new(base:RestrictionBase, children:Array<RestrictionChild>) {
		this.base = base;
		this.children = children;
	}

	function toString()
		return 'Restriction($base, $children)';

	static public function parse(item:Xml) {
		final base:RestrictionBase = RestrictionBaseTools.fromString(item.get('base'));
		final children = [];
		for (child in item.elements()) {
			switch child.nodeName {
				case 'xs:enumeration':
					children.push(ChildEnumeration(Enumeration.parse(child)));
				case 'xs:sequence':
					children.push(ChildSequence(Sequence.parse(child)));
				case 'xs:attribute':
					children.push(ChildAttribute(Attribute.parse(child)));
				case 'xs:pattern':
					children.push(ChildPattern(Pattern.parse(child)));
				case 'xs:minInclusive':
					children.push(MinInclusive(Std.parseFloat(child.get('value'))));
				case 'xs:maxInclusive':
					children.push(MaxInclusive(Std.parseFloat(child.get('value'))));
				case 'xs:minExclusive':
					children.push(MinExclusive(Std.parseFloat(child.get('value'))));
				case 'xs:minLength':
					children.push(MinLength(Std.parseInt(child.get('value'))));
				default:
					throw new Exception('Restriction child "${child.nodeName}" not implemented');
			}
		}
		return new Restriction(base, children);
	}
}

enum RestrictionBase {
	Date;
	Token;
	PositiveInteger;
	Decimal;
	String;
	NonNegativeInteger;
	Integer;
	NMToken;
	Other(value:String);
}

class RestrictionBaseTools {
	static public function fromString(s:String):RestrictionBase {
		if (!s.startsWith('xs:')) {
			return Other(s);
		}
		return switch s {
			case 'xs:date': Date;
			case 'xs:token': Token;
			case 'xs:positiveInteger': PositiveInteger;
			case 'xs:decimal': Decimal;
			case 'xs:string': String;
			case 'xs:nonNegativeInteger': NonNegativeInteger;
			case 'xs:integer': Integer;
			case 'xs:NMTOKEN': NMToken;
			default:
				throw 'RestrictionBase error: $s is not a valid type';
				null;
		}
	}
}

enum RestrictionChild {
	ChildEnumeration(item:Enumeration);
	ChildSequence(item:Sequence);
	ChildAttribute(item:Attribute);
	ChildPattern(item:Pattern);
	MinInclusive(value:Float);
	MaxInclusive(value:Float);
	MinExclusive(value:Float);
	MinLength(value:Int);
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
					children.push(ChildSequence(Sequence.parse(child)));
				case 'xs:attribute':
					children.push(ChildAttribute(Attribute.parse(child)));
				case 'xs:attributeGroup':
					children.push(ChildAttributeGroup(AttributeGroup.parse(child)));
				default:
					throw new Exception('Extension child "${child.nodeName}" not implemented');
			}
		}
		return new Extension(base, cast children);
	}
}

enum ExtensionChild {
	ChildSequence(item:Sequence);
	ChildAttribute(item:Attribute);
	ChildAttributeGroup(item:AttributeGroup);
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

typedef XsdTree = Array<XsdNode>;

enum XsdNode {
	NodeSchema(items:XsdTree, name:String);
	NodeElement(items:XsdTree, name:String, type:String);
	NodeAnnotation(items:XsdTree);
	NodeDocumentation(text:String);
	NodeComplexType(items:XsdTree, name:String);
	NodeSequence(items:XsdTree);
	NodeGroup(items:XsdTree, name:String, ref:String);
	NodeAttributeGroup(items:XsdTree, ref:String);
	NodeAttribute(items:XsdTree, name:String, type:String);
	NodeSimpleContent(items:XsdTree);
	NodeExtension(items:XsdTree, base:String);
}
/*
	enum SchemaItems {
	Work;
	ScoreHeader(items:Array<ScoreHeaderItem>);
	}

	enum ScoreHeaderItem {
	ScoreHeaderItemWork(item:Work);
	ScoreHeaderItemMovementNumber(str:String);
	ScoreHeaderItemMovementTitle(str:String);


	}
 */

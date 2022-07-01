import xsd.XsdParser;
import haxe.io.Path;
import sys.io.File;
import sys.FileSystem;
import xsd.Xsd;

using tools.TextTools;

function main() {
	utest.UTest.run([new Test1()]);
}

class Test1 implements utest.ITest {
	public function new() {}

	public function Xtest1() {
		final path = './testfiles';
		final xsdFiles = FileSystem.readDirectory(path).filter(i -> Path.extension(i) == 'xsd');
		for (file in xsdFiles) {
			final content = File.getContent(Path.join([path, file]));
			final xml = Xml.parse(content);

			final schema = Schema.parse(xml);
			trace('==================================');
			trace(file);
			trace('----------------------------------');
			trace(schema);
		}
	}

	public function test2() {
		final file = 'testfiles/test.xsd';
		final parser = new XsdParser(file);
		parser.parse();

		trace('hello-world'.pascalCase());
	}
}

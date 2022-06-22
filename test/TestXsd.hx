import haxe.io.Path;
import sys.io.File;
import sys.FileSystem;
import xsd.XsdTools;

function main() {
	utest.UTest.run([new Test1()]);
}

class Test1 implements utest.ITest {
	public function new() {}

	public function test1() {
		final path = './testfiles';
		final xsdFiles = FileSystem.readDirectory(path).filter(i -> Path.extension(i) == 'xsd');
		for (file in xsdFiles) {
			final content = File.getContent(Path.join([path, file]));
			final xml = Xml.parse(content);
			// trace(xml.firstElement());
			final schema = Schema.parse(xml);
			trace(schema);
		}
	}
}

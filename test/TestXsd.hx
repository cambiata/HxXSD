import haxe.io.Path;
import sys.io.File;
import sys.FileSystem;
import xsd.Xsd;

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

			final schema = Schema.parse(xml);
			trace('==================================');
			trace(file);
			trace('----------------------------------');
			trace(schema);
		}
	}
}

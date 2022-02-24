package fbp;

import fbp.grammar.FBPGrammar;
import fbp.grammar.FBPParser;
import zenflo.graph.Graph;

using haxe.EnumTools;

class FBP {
	static var options:zenflo.graph.GraphOptions;
	static var graph:Graph;

	public static function load(source:String, name:String = "", ?opt:Null<zenflo.graph.GraphOptions>):Graph {
		final parser = new FBPParser(byte.ByteData.ofString(source));
		graph = new Graph(name, options);
		options = opt;
		return start(parser);
	}

	static function start(parser:FBPParser):Graph {
		var current = parser.parseFBP();
		while (current != Eof) {
			switch (current) {
				case INPORT(node, port, as):
					{
						registerInports(node, port, as);
					}
				case OUTPORT(node, port, as):
					{
						registerOutports(node, port, as);
					}
				case Annotation(k, v):
					{
						registerAnnotation(k, v);
					}
				case _:
			}
			current = parser.parseFBP();
		}

		return graph;
	}

	static function registerInports(node:String, port:TPort, as:String) {
		var portName = port.name;
		var nodeName = node;
		if (!options.caseSensitive) {
			portName = port.name.toLowerCase();
			nodeName = node.toLowerCase();
			as = as.toLowerCase();
		}
		graph.inports.set(as, {process: nodeName, port: portName});
	}

	static function registerOutports(node:String, port:TPort, as:String) {
		var portName = port.name;
		var nodeName = node;
		if (!options.caseSensitive) {
			portName = port.name.toLowerCase();
			nodeName = node.toLowerCase();
			as = as.toLowerCase();
		}
		graph.outports.set(as, {process: nodeName, port: portName});
	}

	static function registerAnnotation(key:String, value:String) {
		if (graph.properties == null) {
			graph.properties = {};
		}

		if (key == 'runtime') {
			graph.properties["environment"] = {
                type: value
            };
			return;
		}

		graph.properties[key] = value;
	}
}

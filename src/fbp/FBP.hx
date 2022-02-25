package fbp;

import zenflo.graph.GraphNodeID;
import zenflo.graph.GraphEdge;
import zenflo.graph.GraphNodeMetadata;
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
				case Connection(var _inport, var _outport, edges):
					{
						registerEdges(_inport, _outport);
						
						procesesConnections(edges);
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

	static function registerEdges(left:Nodes, right:Nodes, ?prevNode:Nodes) {
		// trace('left => $left');
		// trace('right => $right');

		final from:{?node:GraphNodeID, ?port:String, ?index:Int} = {};
		final to:{?node:GraphNodeID, ?port:String, ?index:Int} = {};

		final edge:GraphEdge =  {from: from, to: to};

		function makePort(node:Nodes, port:Nodes, isIn = false) {
			var p = port.getParameters();
			var nodeName = "";
			switch node {
				case Node(name, var component):
					{
						nodeName = options.caseSensitive ? name : name.toLowerCase();
						var comp = null, meta:GraphNodeMetadata = null;
						if (component != null) {
							final c = component.getParameters();
							comp = options.caseSensitive ? c[0] : c[0].toLowerCase();
							meta = c[1];
						}
						graph.addNode(nodeName, comp, meta);
					}
				case Outport(var node, var port):{
					var _node = node.getParameters();
					p = !isIn ? port.getParameters() : p;
					nodeName = options.caseSensitive ? _node[0] : _node[0].toLowerCase();
					var comp = null, meta:GraphNodeMetadata = null;
					final component:Nodes = _node[1];
					if (component != null) {
						final c:Array<Dynamic> = component.getParameters();
						comp = options.caseSensitive ? c[0] : c[0].toLowerCase();
						meta = c[1];
					}

					graph.addNode(nodeName, comp, meta);
				}
				case _:
					trace(node);
			}

			if(isIn){
				edge.to = {
					node: nodeName,
					port: p[0],
					index: p[1]
				};
			} else {
				edge.from = {
					node: nodeName,
					port: p[0],
					index: p[1]
				};
			}

			return edge;
		}

		switch left {
			case Outport(var node, var port):
				{
					makePort(node, port);
					
				}
			case _: trace(left);
		}

		switch right {
			case Inport(var port, var node):
				{
					makePort(node, port, true);
					
				}
			case _: trace(left);
		}

		graph.edges.push(edge);
	}

	static function procesesConnections(edges:Null<Array<Nodes>>) {
		if(edges != null){
			for(edge in edges){
				var params = edge.getParameters();
				var _inport = params[0];
				var _outport = params[1];
				var _edges = params[2];
				registerEdges(_inport, _outport);
				procesesConnections(_edges);
			}
		}
	}
}

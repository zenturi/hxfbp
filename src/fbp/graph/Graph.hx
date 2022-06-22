package fbp.graph;

import haxe.DynamicAccess;

class Graph {
    public final name:String;

	public var nodes:Array<GraphNode>;

	public var edges:Array<GraphEdge>;

	public var initializers:Array<GraphIIP>;

	public var groups:Array<GraphGroup>;

	public var inports:DynamicAccess<GraphExportedPort>;
	public var outports:DynamicAccess<GraphExportedPort>;
	public var properties:PropertyMap;

	public var caseSensitive:Bool;


    public function new(name:String = "", ?options:GraphOptions) {
		this.name = name;
		this.properties = {};
		this.nodes = new Array();
		this.edges = new Array();
		this.initializers = new Array();
		this.inports = {};
		this.outports = {};
		this.groups = new Array();

		this.caseSensitive = false;
		if (options != null && options.caseSensitive != null) {
			this.caseSensitive = options.caseSensitive;
		}
	}

    public function toJSON():GraphJson {
		final json:GraphJson = {
			caseSensitive: this.caseSensitive,
			properties: {},
			inports: this.inports.copy(),
			outports: this.outports.copy(),
			groups: [],
			processes: {},
			connections: [],
		};
		json.properties = this.properties.copy();
		json.properties["name"] = this.name;

		json.properties.remove("baseDir");
		json.properties.remove("componentLoader");

        for(group in this.groups){
            final groupData:GraphGroup = {
				name: group.name,
				nodes: group.nodes,
			};
			if (group.metadata != null && group.metadata.keys().length != 0) {
				groupData.metadata = group.metadata.copy();
			}
			json.groups.push(groupData);
        }
	

		Lambda.foreach(this.nodes, (node) -> {
			if (json.processes == null) {
				json.processes = {};
			}
			json.processes.set(node.id, {
				component: node.component,
				metadata: {}
			});
			// json.processes[node.id] = {
			// 	component: node.component
			// };
			if (node.metadata != null) {
				json.processes[node.id].metadata = node.metadata.copy();
			}

			return true;
		});

		Lambda.foreach(this.edges, (edge) -> {
			final connection:GraphJsonEdge = {
				src: {
					process: edge.from.node,
					port: edge.from.port,
				},
				tgt: {
					process: edge.to.node,
					port: edge.to.port,
				}
			};

			if (edge.from != null && edge.from.index != null) {
				connection.src.index = edge.from.index;
			}
			if (edge.to != null && edge.to.index != null) {
				connection.tgt.index = edge.to.index;
			}

			if (edge.metadata != null && edge.metadata.keys().length != 0) {
				connection.metadata = edge.metadata.copy();
			}

			if (json.connections == null) {
				json.connections = [];
			}
			json.connections.push(connection);

			return true;
		});

		Lambda.foreach(this.initializers, (initializer) -> {
			final iip:GraphJsonEdge = {
				data: initializer.from.data,
				tgt: {
					process: initializer.to.node,
					port: initializer.to.port
				},
			};
			if (initializer.to != null && initializer.to.index != null) {
				iip.tgt.index = initializer.to.index;
			}
			if (initializer.metadata != null && initializer.metadata.keys().length != 0) {
				iip.metadata = initializer.metadata.copy();
			}
			if (json.connections == null) {
				json.connections = [];
			}
			json.connections.push(iip);

			return true;
		});

		return json;
	}
}
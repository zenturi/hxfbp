import fbp.FBP;


class Test {
	public static function main() {
		final graphExportedInPort = "# a commment
# @runtime foo
INPORT=Read.IN:FILENAME 
INPORT=Read.OPTIONS:CONFIG 
OUTPORT=Process.OUT:RESULT 
Read(ReadFile) OUT -> IN Process(Output) RESULT -> IN Visualize Display -> IN D1
";

       final graph = FBP.load(graphExportedInPort, {caseSensitive: false});
       
       trace(graph.toJSON());
	}
}

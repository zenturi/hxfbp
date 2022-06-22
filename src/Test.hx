import fbp.FBP;


class Test {
	public static function main() {
		final graphExportedInPort = "# a commment
# @runtime foo
INPORT=Read.IN:FILENAME 
INPORT=Read.OPTIONS:CONFIG 
OUTPORT=Process.OUT:RESULT 
Read(ReadFile) OUT -> IN Process(Output:key=value)

'5s' -> INTERVAL Ticker(core/ticker) OUT -> IN Forward(core/passthru)
Forward OUT -> IN Log(core/console)
";

       final graph = FBP.load(graphExportedInPort, {caseSensitive: false});
       
	//    trace(Json.stringify(graph));
       trace(graph.toJSON());
	}
}

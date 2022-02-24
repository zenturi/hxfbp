import fbp.FBP;


class Test {
	public static function main() {
		final graphExportedInPort = "# a commment
# @runtime foo
INPORT=Read.IN:FILENAME 
INPORT=Read.OPTIONS:CONFIG 

OUTPORT=Process.OUT:RESULT 
Read() ERROR -> IN Display()
Read(ReadFile) OUT -> IN Process(Output)
'pattern1' -> IN[0] Router(router)
Demo OUT -> IN Process RESULT -> INPUT Visualize DISPLAY -> IN Console LOG -> IN D1
";

        
    
       final graph = FBP.load(graphExportedInPort, {caseSensitive: false});
       
       trace(graph.toJSON());
	}
}

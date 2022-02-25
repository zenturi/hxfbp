package fbp.grammar;

import zenflo.graph.GraphNodeMetadata;
import hxparse.Parser.parse as parse;

using StringTools;
enum Token {
    TInport;
    TOutport;
    TLongSpace;
    TShortSpace;
    TIIPChar(data:String);
    TAp;
    TAnyChar(anychar:String);
    TNode(name:String, port:String);
    TAt;
    TAnnotation(key:String);
    TDoc(key:String);
    TIndex(index:Int);
    TBkOpen;
	TBkClose;
    TBrOpen;
	TBrClose;
    TCol;
    TComma;
    TDot;
    THash;
    TEof;
    TNewLine;
    TArrow;
    TCompMeta(val:String);
    TCompName(val:String);
}


typedef TPort = {
    name:String,
    ?index:Int
}

enum Nodes {
    Port(name:String, ?index:Int);
    MiddLet(inport:Nodes, component:Nodes, outport:Nodes);
    Inport(port:Nodes, node:Nodes);
    Outport(node:Nodes, port:Nodes);
    Connection(inport:Nodes, outport:Nodes,  ?edges:Array<Nodes>);
    Component(name:String, meta:GraphNodeMetadata);
    Node(name:String, component:Nodes);
    OUTPORT(node:String, port:TPort, as:String);
    INPORT(node:String, port:TPort, as:String);
    Comment(str:String);
    Annotation(key:String, value:String);
    IIP(data:String);
    Eof;
}

class FBPLexer extends hxparse.Lexer implements hxparse.RuleBuilder {
    public function new(input:byte.ByteData, sourceName:String) {
		super(input, sourceName);
	}
    static var buf:StringBuf;
    public static var tok = @:rule [
        '->' => TArrow,
        "[" => TBkOpen,
		"]" => TBkClose,
        '@' => TAt,
        ":" => TCol,
        ',' => TComma,
        // "'" => TAp,
        '( *)?' => {
            if(lexer.current.length == 0) return TEof;
            return TShortSpace;
        },
        // '[  ]+' => TLongSpace,
        "[\\][']" => {
            buf = new StringBuf();
            lexer.token(iipchar);
            TIIPChar(buf.toString());
        },
        "^'" => {
            buf = new StringBuf();
            lexer.token(iipchar);
            TIIPChar(buf.toString());
        },
        "#" => THash,
        "#[^\n\r]*" => TDoc(lexer.current.trim()),
        "\\(([a-zA-Z/_0-9]+)" =>{
            return TCompName(lexer.current.replace("(", "").replace(")", "").trim());
        },
        ":[a-zA-Z/=_,0-9]+" =>{
            return TCompMeta(lexer.current.replace(":", "").trim());
        },
        "[a-zA-Z_][a-zA-Z.0-9_\\-]*" => {
            if(lexer.current.contains("-") && !lexer.current.contains(".")){
               return TNode(lexer.current, null);
            }
            final s = lexer.current.split(".");
            if(s[1] != null && s[1].contains("-")){
                throw 'invalid port name ${s[1]}';
            }
            TNode(s[0], s[1]);
        },
        // "\\." => TDot,
        // "\\(" => TBrOpen,
		"\\)" => TBrClose,
        "[0-9]+" =>  TIndex(Std.parseInt(lexer.current)),
        'INPORT=' => TInport,
        'OUTPORT=' => TOutport,
        "[\n\r]" => TNewLine,
        "" => TEof,
    ];



    static var iipchar = @:rule [
        "\\'" => {
            lexer.curPos().pmax;
        },
        "[^']" => {
            buf.add(lexer.current);
            lexer.token(iipchar);
        },
        "'" => {
			lexer.curPos().pmax;
		},
    ];
    
}

class FBPGrammar{}
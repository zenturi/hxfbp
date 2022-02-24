package fbp.grammar;

import fbp.grammar.FBPGrammar.TPort;
import fbp.grammar.FBPGrammar.Token;
import fbp.grammar.FBPGrammar.FBPLexer;
import fbp.grammar.FBPGrammar.Nodes;
import hxparse.Parser.parse as parse;

using StringTools;


class FBPParser extends hxparse.Parser<hxparse.LexerTokenSource<Token>, Token> {
	final ast:Array<Nodes> = [];

	public function new(input:byte.ByteData, sourceName:String = "") {
		var lexer = new FBPLexer(input, sourceName);
		var ts = new hxparse.LexerTokenSource(lexer, FBPLexer.tok);
		super(ts);
	}

	public function parseFBP() {
		return lineParse();
	}

	function lineParse() {
		return parse(switch stream {
            case [TNewLine]: lineParse();
            case [TEof]: return Eof;
            case [TDoc(comm), TNewLine]: {
                final content = comm.replace("#", "").trim();
                if(content.startsWith("@")){
                    final re = ~/[ ]+/;
                    if(re.match(content)){
                        return Annotation(re.matchedLeft().replace("@", ""), re.matchedRight());
                    }
                }
                
                return Comment(content);
            };
            case [TOutport, TNode(node, portName), index = parseOptional(getPortIndex)]: {
                final id = index != null ? switch index {
                    case TIndex(id): id;
                    case _: null;
                } : null;
                final port2 = port();
                return OUTPORT(node, {name: portName, index: id}, port2 != null ? port2.name : null);
            }
            case [TInport, TNode(node, portName), index = parseOptional(getPortIndex)]: {
                final id = index != null ? switch index {
                    case TIndex(id): id;
                    case _: null;
                } : null;
                final port2 = port();
                return INPORT(node, {name: portName, index: id}, port2 != null ? port2.name : null);
            }
            case [b1 = bridge()]:{
                switch stream {
                    case [TShortSpace, TArrow, p = port()]:{
                        var comp = bridge();
                        while(true){
                            switch stream {
                                case [TShortSpace,TArrow,  p = port(), TShortSpace]:{
                                    switch stream{
                                        case [comp1 = component()]:{
                                            switch stream {
                                                case [p1 = port()]:{
                                                    comp = Connection(comp, MiddLet(Port(p.name, p.index), comp1, Port(p1.name, p1.index)));
                                                }
                                                case _: comp = Connection(comp, Inport(Port(p.name, p.index), comp1));
                                            }
                                        }
                                        case _: throw 'expected component at ${this.curPos()}';
                                    }
                                    trace(comp);
                                }
                                
                            }
                            switch(this.peek(0)){ 
                                case TNewLine: break;
                                case TEof: break;
                                case _:
                            }
                        }
                        return  Connection(b1, Inport(Port(p.name, p.index), comp));
                    }
                }
                
            }
            case [_ = parseRepeat(space)]: lineParse();
        });
	}

    function space(){
        return parse(switch stream{
            case [TShortSpace]: TShortSpace;
        });
    }



    function bridge(){
        // trace(this.peek(0), this.peek(1), this.peek(2));
        return parse(switch stream{
            case [TIIPChar(iip)]:{
                return IIP(iip);
            }
            // out
            case [comp = component()]:{
                return switch stream {
                    case [TShortSpace, p = port()]:{
                        return Outport(comp, Port(p.name, p.index));
                    }
                    case [TNewLine]: comp;
                }
            }
            // in
            case [TShortSpace, comp = component()]:{
                return switch stream {
                    case [TShortSpace, p = port()]:{
                        return Outport(comp, Port(p.name, p.index));
                    }
                    case [TNewLine]: comp;
                }
            } 
        });
    }


    function component(){
        return parse(switch stream{
            case [TNode(node, _)]:{
                switch stream {
                    case [TBrOpen, compname = parseOptional(()-> parse(switch stream {case [TNode(node, x)]: TNode(node, x);})), meta = parseOptional(compMeta), TBrClose]:{
                        final comp = (compname != null) ? switch compname {
                            case TNode(n, x):{
                                Component(n, [meta]);
                            }
                            case _: null;
                        }: null;
                        return Node(node, comp);
                    }
                    case _: return Node(node, null);
                }
            }
        });
    }

    function compMeta(){
        return parse(switch stream{
            case [TCol, TNode(node, _)]:{
                return node;
            }
        });
    }

	function port():TPort {
		return parse(switch stream {
            case [TShortSpace, TNode(pname, _), index = parseOptional(getPortIndex)]:{
                final id = index != null ? switch index {
                    case TIndex(id): id;
                    case _: null;
                } : null; 
                return {name: pname, index: id};
            }
			case [TCol, TNode(name, _), index = parseOptional(getPortIndex)]: {
                final id = index != null ? switch index {
                    case TIndex(id): id;
                    case _: null;
                } : null; 
				return {name: name, index: id};
			}
            case[TNode(name, _), index = parseOptional(getPortIndex)]:{
                final id = index != null ? switch index {
                    case TIndex(id): id;
                    case _: null;
                } : null; 
                return {name: name, index: id};
            }
            
		});
	}

	function getPortIndex() {
		return parse(switch stream {
			case [TBkOpen, TIndex(id), TBkClose]: {
					return TIndex(id);
				}
		});
	}

	// function linerTerminator(node:Nodes) {
	// 	return parse(switch stream {
	// 		case [TShortSpace, _ = parseOptional(()-> parse(switch stream {case [TComma]: TComma; case [TDoc(comment)]: TDoc(comment);  case [TNewLine]: TNewLine;}))]: {
    //                 node;
	// 			}
    //         // case [TNewLine]: node;
    //         // case [TEof]: node;
	// 	});
	// }
}

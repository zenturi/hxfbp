# FBP flow definition language parser

The fbp library provides a parser for a domain-specific language for flow-based-programming (FBP), used for defining graphs for FBP programming environments like [ZenFlo](https://github.com/zenturi/zenflo), [NoFlo](https://noflojs.org/), [MicroFlo](https://microflo.org/) and MsgFlo.

### Dependencies
 * [ZenFlo](https://github.com/zenturi/zenflo)
 * [Haxe](https://haxe.org/)
 * [Node.js](https://nodejs.org/)

This project uses [lix.pm](https://github.com/lix-pm/lix.client) as Haxe package manager.
Run `npm install` to install the dependencies.

### Compile and run
```
npm run haxe editor.hxml
```


### Usage
You can use the FBP parser in your Haxe code with the following:
```hx
import fbp.FBP;
var fbpData = "'hello, world!' -> IN Display(Output)";
final graph = FBP.load(fbpData, {caseSensitive: false}); // this will produce a Zenflo graph
trace(graph.toJSON()); // convert to json and use in other non-ZenFlo environments
```

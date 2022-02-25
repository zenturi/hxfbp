#!/bin/sh
rm -f fbp.zip
zip -r fbp.zip src *.hxml *.json *.md run.n
haxelib submit fbp.zip $HAXELIB_PWD --always
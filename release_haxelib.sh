#!/bin/sh
rm -f fbp.zip
zip -r fbp.zip src *.hxml *.json *.md haxe_libraries
haxelib submit fbp.zip $HAXELIB_PWD --always
#!/bin/sh

ARGS=$(
    echo "-classpath"
    echo "jagexappletviewer.jar"
    xmllint --xpath "/plist/dict/key[.='JVMOptions']/following-sibling::array[1]/string/text()" Info.plist
    xmllint --xpath "/plist/dict/key[.='JVMMainClassName']/following-sibling::string[1]/text()" Info.plist
    xmllint --xpath "/plist/dict/key[.='JVMArguments']/following-sibling::array[1]/string/text()" Info.plist
)
exec java $ARGS

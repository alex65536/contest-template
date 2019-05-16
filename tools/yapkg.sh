#!/bin/bash

if [[  $# != 1 ]]; then
	echo "Usage yapkg.sh problem"
fi

tools/ya_prepare.sh normal
(
	cd problems/"$1"
	rm ../"$1.zip"
	zip -r ../"$1.zip" *
)
tools/ya_prepare.sh inverse

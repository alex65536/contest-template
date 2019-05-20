#!/bin/bash

if [[ $# != 1 ]]; then
	echo "Usage yapkg.sh problem"
	exit 1
fi

make prepare
(
	cd problems/"$1" || exit
	make
)

tools/ya_prepare.sh normal
(
	cd problems/"$1" || exit
	rm ../"$1.zip"
	zip -r ../"$1.zip" *
)
tools/ya_prepare.sh inverse

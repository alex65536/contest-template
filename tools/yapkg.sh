#!/usr/bin/env bash

if [[ $# != 1 ]]; then
	echo "Usage yapkg.sh PROBLEMS..."
	exit 1
fi

make prepare
(
	cd problems/"$1" || exit
	make
)

tools/ya_prepare.sh normal
while [[ $# != 0 ]]; do
	(
		cd problems/"$1" || exit
		rm ../"$1.zip"
		zip -r ../"$1.zip" *
	)
	shift
done
tools/ya_prepare.sh inverse

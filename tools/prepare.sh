#!/bin/bash

function processDir {
	echo "$1" >> ../problem-list.txt
}

cd problems || exit 1
rm -f ../problem-list.txt

touch ../problem-list.txt

for TASK_NAME in $(ls . | sort); do
	if [[ -d "${TASK_NAME}" ]]; then
		[[ -f "${TASK_NAME}/.prp-ignore" ]] && continue
	else
		continue
	fi
	processDir "${TASK_NAME}"
done

wait

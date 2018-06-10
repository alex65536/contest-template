#!/bin/bash

. color.sh

cd checkerTests || exit 1

TESTID=0
while :; do
	: $((TESTID++))
	[ -f "${TESTID}.in" ] || break
	INPUT="${TESTID}.in"
	OUTPUT="${TESTID}.out"
	ANSWER="${TESTID}.ans"
	echo "${S_BOLD}${S_FG_BLUE}Test ${TESTID}${S_NONE}"
	echo "${S_FG_MAGENTA}Input:${S_NONE}"
	cat "${INPUT}"
	echo "${S_FG_MAGENTA}Output:${S_NONE}"
	cat "${OUTPUT}"
	echo "${S_FG_MAGENTA}Answer:${S_NONE}"
	cat "${ANSWER}"
	echo "${S_FG_MAGENTA}Checker says:${S_NONE}"
	../checker "${INPUT}" "${OUTPUT}" "${ANSWER}"
done

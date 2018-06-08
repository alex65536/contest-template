#!/bin/bash

TESTID=0

jq . problem.json >/dev/null || exit

SOL_INPUT="$(jq .problem.input problem.json -r)"
SOL_OUTPUT="$(jq .problem.output problem.json -r)"

function callSolution {
	# Get input, output files & redirections
	local IN_FILE="$1"
	local OUT_FILE="$2"
	local IN_REDIR="/dev/null"
	local OUT_REDIR="/dev/null"
	[[ -z "${SOL_INPUT}" ]] && IN_REDIR="${IN_FILE}"
	[[ -z "${SOL_OUTPUT}" ]] && OUT_REDIR="${OUT_FILE}"
	# Execute solution
	[[ -z "${SOL_INPUT}" ]] || cp -T "${IN_FILE}" "${SOL_INPUT}"
	../solution <"${IN_REDIR}" >"${OUT_REDIR}"
	[[ -z "${SOL_OUTPUT}" ]] || cp -T "${SOL_OUTPUT}" "${OUT_FILE}"
	# Cleanup temp files
	[[ -z "${SOL_INPUT}" ]] || rm -f "${SOL_INPUT}"
	[[ -z "${SOL_OUTPUT}" ]] || rm -f "${SOL_OUTPUT}"
}

function makeTest {
	: $((TESTID++))
	echo "Generating test ${TESTID}"
	local IN_FILE="${TESTID}.in"
	local OUT_FILE="${TESTID}.out"
	cat >"${IN_FILE}"
	../validator <"${IN_FILE}"
	if [[ "$?" != 0 ]]; then
		echo "Validator error"
		exit 3
	fi
	callSolution "${IN_FILE}" "${OUT_FILE}"
	if [[ -e ../checker ]]; then
		../checker "${IN_FILE}" "${OUT_FILE}" "${OUT_FILE}"
		if [[ "$?" != 0 ]]; then
			echo "Checker error"
			exit 3
		fi
	fi
}

function makeGenTest {
	GEN_APP="$1"
	shift
	"${GEN_APP}" "$@" >tmp.txt
	makeTest <tmp.txt
	rm -f tmp.txt
}

function prepare {
	rm -f ./*.in ./*.out ./checker.* ./checker
	stat --printf='' ../checker* &>/dev/null && cp ../checker* .
	TESTID=0
}

. genTests.sh

# Pretests
echo "Generating pretests..."
[ -d pretests ] || mkdir pretests
(
	cd pretests || exit
	prepare
	runPretestGen
) || exit "$?"

# Tests
echo "Generating tests..."
[ -d tests ] || mkdir tests
(
	cd tests || exit
	prepare
	runTestGen
) || exit "$?"

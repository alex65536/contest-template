#!/bin/bash

TESTID=0

jq . problem.json >/dev/null || exit

SOL_INPUT="$(jq .problem.input problem.json -r)"
SOL_OUTPUT="$(jq .problem.output problem.json -r)"

SUPPLIES_TL=10
SOLUTION_TL=10 # TODO: read solution time limit from JSON

function runLimited {
	# Run program with CPU time limit
	local TIME_LIMIT="$1"; shift
	( ulimit -t "$TIME_LIMIT"; "$@"; )
	local EXITCODE="$?"
	return "$EXITCODE"
}

function callSolution {
	# Get input, output files & redirections
	local ERROR=0
	local IN_FILE="$1"
	local OUT_FILE="$2"
	local IN_REDIR="/dev/null"
	local OUT_REDIR="/dev/null"
	[[ -z "${SOL_INPUT}" ]] && IN_REDIR="${IN_FILE}"
	[[ -z "${SOL_OUTPUT}" ]] && OUT_REDIR="${OUT_FILE}"
	# Execute solution
	[[ -z "${SOL_INPUT}" ]] || cp -T "${IN_FILE}" "${SOL_INPUT}"
	if ! runLimited "$SOLUTION_TL" ../solution <"${IN_REDIR}" >"${OUT_REDIR}"; then
		echo "Solution returned unsuccessfully (maybe killed because of time limit?)"
		ERROR=1
	else
		[[ -z "${SOL_OUTPUT}" ]] || cp -T "${SOL_OUTPUT}" "${OUT_FILE}"
	fi
	# Cleanup temp files
	[[ -z "${SOL_INPUT}" ]] || rm -f "${SOL_INPUT}"
	[[ -z "${SOL_OUTPUT}" ]] || rm -f "${SOL_OUTPUT}"
	[[ "$ERROR" == 1 ]] && exit 3
}

function makeTest {
	: $((TESTID++))
	echo "Generating test ${TESTID}"
	local IN_FILE="${TESTID}.in"
	local OUT_FILE="${TESTID}.out"
	cat >"${IN_FILE}"
	if ! runLimited "$SUPPLIES_TL" ../validator <"${IN_FILE}"; then
		echo "Validator error"
		exit 3
	fi
	callSolution "${IN_FILE}" "${OUT_FILE}"
	if [[ -e ../checker ]]; then
		if ! runLimited "$SUPPLIES_TL" ../checker "${IN_FILE}" "${OUT_FILE}" "${OUT_FILE}"; then
			echo "Checker error"
			exit 3
		fi
	fi
}

function sanitizeParams {
	for PARAM in "$@"; do
		echo -n "'"
		# shellcheck disable=SC1003
		echo -n "$PARAM" | sed -E 's#'\''#'\''\\'\'\''#g' # Magic here: replace ' -> '\'' (quote escaping)
		echo -n "' "
	done
}

function genParamCheck {
	PARAM_STR="$(sanitizeParams "$@")"
	if [[ "${GEN_PARAMS["${PARAM_STR}"]:-0}" == 1 ]]; then
		echo "Warning: the following command line was invoked twice:"
		echo "  ${PARAM_STR}"
		echo "The generated tests will be the same; aborting"
		exit 4
	fi
	GEN_PARAMS["${PARAM_STR}"]=1
}

function makeGenTest {
	genParamCheck "$@"
	GEN_APP="$1"
	shift
	if runLimited "$SUPPLIES_TL" "${GEN_APP}" "$@" >tmp.txt; then
		makeTest <tmp.txt
		rm -f tmp.txt
	else
		rm -f tmp.txt
		echo "Generator error"
		exit 3
	fi
}

function makeTestSeries {
	COUNT="$1"; shift
	for ((I=0; I < COUNT; ++I)); do
		makeGenTest "$@" test$I
	done
}

function prepare {
	rm -f ./*.in ./*.out ./checker.* ./checker ./testlib.h
	stat --printf='' ../checker.* &>/dev/null && (
		cp ../checker.* .
		cp ../checker .
		cp ../testlib.h .
	)
	TESTID=0
	declare -gA GEN_PARAMS
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

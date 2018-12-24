#!/bin/bash

# If zero, input is shown only on fail
# If non-zero, input is shown each time
SHOW_INPUT=1

function runStress {
	local TASK_NAME="$1"; shift
	local NAIVE_NAME="$1"; shift
	local GEN_NAME="$1"; shift
	local GEN_PARM="$1"; shift
	
	local TMPDIR="$(mktemp -d)"
	
	function finish {
		cd / # We move far away from the directory which we want to remove
		rm -rf "${TMPDIR}"
		exit 0
	}
	
	trap 'finish' SIGHUP SIGINT SIGQUIT SIGTERM
	
	g++ --std=c++11 -O2 "../solutions/${TASK_NAME}.cpp" -o "${TMPDIR}/solution" || exit 1
	g++ --std=c++11 -O2 "../solutions/${NAIVE_NAME}.cpp" -o "${TMPDIR}/naive" || exit 1
	g++ --std=c++14 -O2 "../problems/${TASK_NAME}/${GEN_NAME}.cpp" -o "${TMPDIR}/gen" || exit 1
	g++ --std=c++14 -O2 "../problems/${TASK_NAME}/validator.cpp" -o "${TMPDIR}/validator" || exit 1
	if [[ -f "../problems/${TASK_NAME}/checker.cpp" ]]; then
		g++ --std=c++14 -O2 "../problems/${TASK_NAME}/checker.cpp" -o "${TMPDIR}/checker" || exit 1
	fi
	
	function kompare {
		INPUT="$1"
		OUTPUT="$2"
		ANSWER="$3"
		if [[ -f "./checker" ]]; then
			./checker "${INPUT}" "${OUTPUT}" "${ANSWER}"
			return $?
		else
			diff "${OUTPUT}" "${ANSWER}"
			return $?
		fi
	}
	
	function showInput {
		echo -e "\033[34;1mInput:\033[0m"
		cat input.txt
	}
	
	function showGenParams {
		echo -e "\033[34;1mGenerator params:\033[0m"
		echo "${GEN_PARM} ${RAND_SEED}"
	}
	
	cd "${TMPDIR}"
	
	local TESTID=0
	while :; do
		: $((TESTID++))
		echo -e "\033[33;1mTest ${TESTID}\033[0m"
		RAND_SEED=${RANDOM}${RANDOM}${RANDOM}
		./gen ${GEN_PARM} ${RAND_SEED} >input.txt || finish
		[[ "${SHOW_INPUT}" == 0 ]] || showGenParams
		[[ "${SHOW_INPUT}" == 0 ]] || showInput
		if ! ./validator <input.txt; then
			[[ "${SHOW_INPUT}" == 0 ]] && showInput
			finish
		fi
		if ! ./naive; then
			[[ "${SHOW_INPUT}" == 0 ]] && showInput
			echo -e "\033[35;1mRE\033[0m (on naive)"
			finish
		fi
		mv output.txt answer.txt
		if ! ./solution; then
			[[ "${SHOW_INPUT}" == 0 ]] && showInput
			echo -e "\033[35;1mRE\033[0m"
			finish
		fi
		if ! kompare input.txt output.txt answer.txt; then
			[[ "${SHOW_INPUT}" == 0 ]] && showInput
			echo -e "\033[31;1mWA\033[0m"
			finish
		fi
	done
}

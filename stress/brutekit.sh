#!/usr/bin/env bash

# If zero, input is shown only on fail
# If non-zero, input is shown each time
SHOW_INPUT=1

function runStress {
	local TASK_NAME="$1"; shift
	local NAIVE_NAME="$1"; shift
	local GEN_NAME="$1"; shift
	local GEN_PARM="$1"; shift
	local SOURCES=("$@")
	
	[[ "${#SOURCES}" == 0 ]] && SOURCES=("${TASK_NAME}.cpp")
	
	local TMPDIR="$(mktemp -d)"
	
	function finish {
		cd / # We move far away from the directory which we want to remove
		rm -rf "${TMPDIR}"
		exit 0
	}
	
	trap 'finish' SIGHUP SIGINT SIGQUIT SIGTERM
	
	for SOURCE in "${SOURCES[@]}"; do
		echo -e "\033[34;1mCompiling\033[0m ${SOURCE}"
		g++ --std=c++14 -O2 "../solutions/${SOURCE}" -o "${TMPDIR}/${SOURCE}.exe" || exit 1
	done
	
	echo -e "\033[34;1mCompiling\033[0m ${NAIVE_NAME}.cpp"
	g++ --std=c++14 -O2 "../solutions/${NAIVE_NAME}.cpp" -o "${TMPDIR}/naive" || exit 1
	
	echo -e "\033[34;1mCompiling generator\033[0m ${GEN_NAME}.cpp"
	g++ --std=c++14 -O2 "../problems/${TASK_NAME}/${GEN_NAME}.cpp" -o "${TMPDIR}/gen" || exit 1
	
	echo -e "\033[34;1mCompiling validator\033[0m"
	g++ --std=c++14 -O2 "../problems/${TASK_NAME}/validator.cpp" -o "${TMPDIR}/validator" || exit 1
	
	if [[ -f "../problems/${TASK_NAME}/checker.cpp" ]]; then
		echo -e "\033[34;1mCompiling checker\033[0m"
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
		if ! ./naive <input.txt >output.txt; then
			[[ "${SHOW_INPUT}" == 0 ]] && showInput
			echo -e "\033[35;1mRE\033[0m ${NAIVE_NAME}.cpp"
			finish
		fi
		mv output.txt answer.txt
		for SOURCE in "${SOURCES[@]}"; do
			if ! "./${SOURCE}.exe" <input.txt >output.txt; then
				[[ "${SHOW_INPUT}" == 0 ]] && showInput
				echo -e "\033[35;1mRE\033[0m ${SOURCE}"
				finish
			fi
			if ! kompare input.txt output.txt answer.txt; then
				[[ "${SHOW_INPUT}" == 0 ]] && showInput
				echo -e "\033[31;1mWA\033[0m ${SOURCE}"
				finish
			fi
		done
	done
}

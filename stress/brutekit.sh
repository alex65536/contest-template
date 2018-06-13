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
	
	cd "${TMPDIR}"
	
	local TESTID=0
	while :; do
		: $((TESTID++))
		echo -e "\033[33;1mTest ${TESTID}\033[0m"
		./gen $(eval "echo ${GEN_PARM}") seed=${RANDOM}${RANDOM}${RANDOM} >input.txt || finish
		echo -e "\033[34;1mInput:\033[0m"
		cat input.txt
		./validator <input.txt || finish
		if ! ./naive; then
			echo -e "\033[35;1mRE\033[0m (on naive)"
			finish
		fi
		mv output.txt answer.txt
		if ! ./solution; then
			echo -e "\033[35;1mRE\033[0m"
			finish
		fi
		if ! kompare input.txt output.txt answer.txt; then
			echo -e "\033[31;1mWA\033[0m"
			finish
		fi
	done
}

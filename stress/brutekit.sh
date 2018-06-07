function runStress {
	local TASK_NAME="$1"; shift
	local NAIVE_NAME="$1"; shift
	local GEN_NAME="$1"; shift
	local GEN_PARM="$1"; shift
	
	local TMPDIR="$(mktemp -d)"
	
	function finish {
		cd / # We move far away from the directory which we want to remove
		echo "Del ${TMPDIR}"
		rm -rf "${TMPDIR}"
		exit 0
	}
	
	trap 'finish' SIGHUP SIGINT SIGQUIT SIGTERM
	
	g++ --std=c++11 -O2 "../solutions/${TASK_NAME}.cpp" -o "${TMPDIR}/solution"
	g++ --std=c++11 -O2 "../solutions/${NAIVE_NAME}.cpp" -o "${TMPDIR}/naive"
	g++ --std=c++11 -O2 "../problems/${TASK_NAME}/${GEN_NAME}.cpp" -o "${TMPDIR}/gen"
	if [[ -f "../problems/${TASK_NAME}/checker.cpp" ]]; then
		g++ --std=c++11 -O2 "../problems/${TASK_NAME}/checker.cpp" -o "${TMPDIR}/checker"
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
		./gen $(eval "echo ${GEN_PARM}") seed=${RANDOM}${RANDOM}${RANDOM} >input.txt
		echo -e "\033[34;1mInput:\033[0m"
		cat input.txt
		./naive
		mv output.txt answer.txt
		./solution
		if ! kompare input.txt output.txt answer.txt; then
			echo -e "\033[31;1mWA\033[0m"
			finish
		fi
	done
}
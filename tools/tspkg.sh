#!/usr/bin/env bash

TMP_DIR="$(mktemp -d)"

trap 'rm -rf ${TMP_DIR}' EXIT SIGTERM SIGINT SIGQUIT

(while read -u 42 -r "PROBLEM"; do
	echo "Testerizing ${PROBLEM}"
	ln -sT "${PWD}/problems/${PROBLEM}/tests" "${TMP_DIR}/${PROBLEM}"
	./tools/testerize.py "${PWD}/problems/${PROBLEM}"
done) 42<problem-list.txt

ln -sT "${PWD}/statements/contest.pdf" "${TMP_DIR}/contest.pdf"

echo "Creating the archive"

[[ -d "${PWD}/archives" ]] || mkdir "${PWD}/archives"

CUR_DIR="${PWD}"

cd "${TMP_DIR}" && (
	rm -f "${CUR_DIR}/archives/contest.zip"
	zip -9r "${CUR_DIR}/archives/contest.zip" ./*
)

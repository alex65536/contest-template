#!/bin/bash

CONTEST_NAME="$(jq .contest.name ../contest.json -r)"
CONTEST_DATE="$(jq .contest.date ../contest.json -r)"
CONTEST_LOCATION="$(jq .contest.location ../contest.json -r)"

TEMPLATE_FILE="problem.tex.m4"

TMP_FILE="mkpdfbuild${RANDOM}${RANDOM}"

DEST_PDF="$1"
shift

INCLUDES=""

for INFILE in "$@"; do
    INCLUDES+="\\input{${INFILE}.tex} "
done

echo "$INCLUDES"

m4 -D_contestname="${CONTEST_NAME}" -D_contestdate="${CONTEST_DATE}" -D_contestlocation="${CONTEST_LOCATION}" -D_includes="${INCLUDES}" "${TEMPLATE_FILE}" >"${TMP_FILE}.tex"

latexmk -pdf "${TMP_FILE}.tex" && (
    mv -T "${TMP_FILE}.pdf" "${DEST_PDF}.pdf"
    latexmk -c
)

rm -f "${TMP_FILE}.tex"

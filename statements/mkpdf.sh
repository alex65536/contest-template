#!/usr/bin/env bash

jq . ../contest.json >/dev/null || exit

CONTEST_NAME="$(jq .contest.name ../contest.json -r)"
CONTEST_DATE="$(jq .contest.date ../contest.json -r)"
CONTEST_LOCATION="$(jq .contest.location ../contest.json -r)"

TEMPLATE_FILE="problem.tex.m4"

TMP_FILE="mkpdfbuild${RANDOM}${RANDOM}"

DEST_PDF="$1"
shift

INFILES=""

for INFILE in "$@"; do
    INFILES+="$(./mkpdf_helper.py "$INFILE")"$'\n'
done

echo "$INFILES"

m4 -D_contestname="${CONTEST_NAME}" -D_contestdate="${CONTEST_DATE}" -D_contestlocation="${CONTEST_LOCATION}" -D_infiles="${INFILES}" "${TEMPLATE_FILE}" >"${TMP_FILE}.tex"

if latexmk --pdflatex="pdflatex --file-line-error-style %O %S" -pdf "${TMP_FILE}.tex"; then
    mv -T "${TMP_FILE}.pdf" "${DEST_PDF}.pdf"
    ERROR=0
else
    ERROR=$?
fi

latexmk -c
rm -f "${TMP_FILE}.tex"

exit $ERROR

#!/usr/bin/env bash
# Temporary, ugly hack to help uploading to Yandex.Contest
# It switches usual test naming (*.in/*.out) to Ya-Contest acceptable (*/*.a)
# and vise versa. When (and if) (*/*.a) will be accepted as default, this script
# needs to be removed!

fmove() {
	[[ -f "$1" ]] && mv "$1" "$2"
}

remove_leading_zeros() {
	sed -E 's/^0*//' <<<"$1"
}

TYPE="$1"

if [[ "$TYPE" != "normal" && "$TYPE" != "inverse" ]]; then
	echo "Usage: $0 normal|inverse"
	exit 1
fi

(while read -u 42 -r "PROBLEM"; do
	echo "Processing ${PROBLEM}"
	for TESTSET in pretests tests; do (
		cd "${PWD}/problems/${PROBLEM}/${TESTSET}" || exit
		for FNAME in *.out *.a; do
			[[ -f "$FNAME" ]] || continue
			TESTID="$(remove_leading_zeros "${FNAME%%.*}")"
			YA_TID="$(printf "%02d" "$TESTID")"
			case "$TYPE" in
				"normal")
					fmove "$TESTID.in" "$YA_TID"
					fmove "$TESTID.out" "$YA_TID.a"
				;;
				"inverse")
					fmove "$YA_TID" "$TESTID.in"
					fmove "$YA_TID.a" "$TESTID.out"
				;;
			esac
		done
	); done
done) 42<problem-list.txt

.PHONY: all build clean

all: build

PROBLEMS := $(shell ls *.tex | sort)
PROBLEMS_NOEXT := $(PROBLEMS:%.tex=%)
PROBLEMS_PDF := $(PROBLEMS:%.tex=%.pdf)

build: contest.pdf $(PROBLEMS_PDF)

%.pdf: %.tex $(wildcard ../images/%.png) ../contest.json
	./mkpdf.sh $(@:%.pdf=%) $(@:%.pdf=%)

contest.pdf: $(PROBLEMS) $(wildcard ../images/*)
	./mkpdf.sh contest $(PROBLEMS_NOEXT)

clean:
	rm -f *.aux *.log *.pdf

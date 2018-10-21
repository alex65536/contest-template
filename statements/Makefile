.PHONY: all build clean

all: build

PROBLEMS := $(shell ls *.tex | sort)
PROBLEMS_NOEXT := $(PROBLEMS:%.tex=%)
PROBLEMS_PDF := $(PROBLEMS:%.tex=%.pdf)
DEPS := $(wildcard ../images/*.png) problem.tex.m4 ../contest.json

build: contest.pdf $(PROBLEMS_PDF)

%.pdf: %.tex $(DEPS)
	./mkpdf.sh $(@:%.pdf=%) $(@:%.pdf=%)

contest.pdf: $(PROBLEMS) $(DEPS)
	./mkpdf.sh contest $(PROBLEMS_NOEXT)

clean:
	rm -f *.aux *.log *.pdf

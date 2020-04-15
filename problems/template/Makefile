PROBLEM_NAME=$(notdir $(shell pwd))

.PHONY: all build clean test

all: build
build: gen-tests.target

GEN-SRC := $(wildcard gen*.cpp)
GENERATORS := $(GEN-SRC:%.cpp=%)
CHECKER-SRC := $(wildcard checker.cpp)
CHECKER := $(CHECKER-SRC:%.cpp=%)

test: $(CHECKER)
	./testChecker.sh

gen-tests.target: gen.sh genTests.sh solution validator $(CHECKER) $(GENERATORS) problem.json
	./gen.sh

.PRECIOUS: solution.%

solution.%: ../../solutions/$(PROBLEM_NAME).%
	cp -T $^ $@

%: %.pas
	fpc $^ -o$@ -O3 && rm $@.o

%: %.dpr
	fpc $^ -o$@ -O3 -Mdelphi && rm $@.o

%: %.c
	gcc $^ -o $@ -Wall -Wextra -O3

%: %.cpp
	g++ $^ -o $@ -Wall -Wextra -O3 --std=c++14

clean:
	rm -f *.target
	rm -f solution.*
	find . -type f ! -name "*.?*" ! -name "Makefile" -delete
	rm -f tests/checker* tests/tmp.txt tests/testlib.h
	rm -f pretests/checker* pretests/tmp.txt pretests/testlib.h
	find . -type f -regextype egrep -regex '(./tests|./pretests)/[0-9]+(.a)?' -delete
	rm -f *.o

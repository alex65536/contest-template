PROBLEM_NAME=$(notdir $(shell pwd))

.PHONY: all build clean

all: build
build: gen-tests.target

GEN-SRC := $(wildcard gen*.cpp)
GENERATORS := $(GEN-SRC:%.cpp=%)
CHECKER-SRC := $(wildcard checker.cpp)
CHECKER := $(CHECKER-SRC:%.cpp=%)

gen-tests.target: gen.sh genTests.sh solution validator $(CHECKER) $(GENERATORS) problem.json
	./gen.sh
	touch gen-tests.target

.PRECIOUS: solution.%

solution.%: ../../solutions/$(PROBLEM_NAME).%
	cp -T $^ $@

%: %.pas
	fpc $^ -o$@ -O3 && rm $@.o

%: %.dpr
	fpc $^ -o$@ -O3 -Mdelphi && rm $@.o

%: %.c
	gcc $^ -o $@ -Wall -Wextra -pedantic -O3

%: %.cpp
	g++ $^ -o $@ -Wall -Wextra -pedantic -O3 --std=c++14

clean:
	rm -f *.target
	rm -f solution.*
	find . -type f ! -name "*.?*" ! -name "Makefile" -delete
	rm -f tests/*.in tests/*.out tests/checker* tests/tmp.txt
	rm -f pretests/*.in pretests/*.out pretests/checker* pretests/tmp.txt
	rm -f *.o

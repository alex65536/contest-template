.PHONY: all build clean
.NOTPARALLEL: build

SRCS-PAS=$(wildcard *.pas)
SRCS-DPR=$(wildcard *.dpr)
SRCS-C=$(wildcard *.c)
SRCS-CPP=$(wildcard *.cpp)
EXES=$(SRCS-PAS:%.pas=%) $(SRCS-DPR:%.dpr=%) $(SRCS-C:%.c=%) $(SRCS-CPP:%.cpp=%)

all: build

build: $(EXES)

%: %.pas
	fpc $^ -o$@ -O3 && rm $@.o

%: %.dpr
	fpc $^ -o$@ -O3 -Mdelphi && rm $@.o

%: %.c
	gcc $^ -o $@ -Wall -Wextra -pedantic -O3

%: %.cpp
	g++ $^ -o $@ -Wall -Wextra -pedantic -O3 --std=c++11

clean:
	find . -type f ! -name "*.?*" ! -name "Makefile" -delete
	rm -f *.o

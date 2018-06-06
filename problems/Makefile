.PHONY: all build clean

PROBLEM-DIRS := $(shell ls -d */)
PROBLEMS := $(PROBLEM-DIRS:%/=%)
PROBLEMS-BUILD := $(PROBLEMS:%=%-build)
PROBLEMS-CLEAN := $(PROBLEMS:%=%-clean)
.PHONY: $(PROBLEMS-BUILD)

all: build
build: $(PROBLEMS-BUILD)
clean: $(PROBLEMS-CLEAN)

$(PROBLEMS-BUILD):
	+cd $(@:%-build=%) && make build

$(PROBLEMS-CLEAN):
	+cd $(@:%-clean=%) && make clean

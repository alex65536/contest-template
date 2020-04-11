.PHONY: all build clean full-clean prepare tspkg

DIRS := statements problems solutions
DIRS_BUILD := $(DIRS:%=%-build)
DIRS_CLEAN := $(DIRS:%=%-clean)

all: build prepare

prepare:
	./tools/prepare.sh

tspkg: build prepare
	./tools/tspkg.sh

build: $(DIRS_BUILD)

clean: $(DIRS_CLEAN)
	rm -f problem-list.txt
	find . -name "input.txt" -type f -delete
	find . -name "output.txt" -type f -delete

full-clean: clean
	rm -f archives/*.zip
	find . -name "props.json" -type f -delete

.PHONY: $(DIRS_BUILD) $(DIRS_CLEAN)

$(DIRS_BUILD):
	+cd $(@:%-build=%) && make build

$(DIRS_CLEAN):
	+cd $(@:%-clean=%) && make clean

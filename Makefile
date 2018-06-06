.PHONY: all build clean prepare deploy

DIRS := statements problems solutions
DIRS_BUILD := $(DIRS:%=%-build)
DIRS_CLEAN := $(DIRS:%=%-clean)

all: build prepare

prepare:
	./tools/prepare.sh

deploy: build prepare
	./tools/deploy.sh

build: $(DIRS_BUILD)

clean: $(DIRS_CLEAN)
	rm -f problem-list.txt

.PHONY: $(DIRS_BUILD) $(DIRS_CLEAN)

$(DIRS_BUILD):
	+cd $(@:%-build=%) && make build

$(DIRS_CLEAN):
	+cd $(@:%-clean=%) && make clean

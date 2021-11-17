BENCH_SOURCE=benchmarks.json
TARGET=helm

.PHONY: all outclean clone run generate build prepare distclean

all: distclean run

distclean: outclean
		/bin/bash ./script.sh clean $(TARGET)

outclean:
		rm -fr out/$(TARGET)

generate:
		rm -f script.sh
		/bin/env python3 ./generate.py $(BENCH_SOURCE) > script.sh
		chmod +x script.sh

clone: generate
		/bin/bash ./script.sh clone $(TARGET)

build: distclean clone
		/bin/bash ./script.sh build $(TARGET)

prepare: generate
		/bin/bash ./script.sh prepare $(TARGET)

run: generate build prepare
		/bin/bash ./script.sh run $(TARGET)
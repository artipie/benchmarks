BENCH_SOURCE=benchmarks.json
TARGET=
TAG=
NUMBER_CHARTS=5

.PHONY: all outclean clone run generate build prepare distclean write-results draw-charts

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

write-results: run
		python3 ./scripts/writeresults.py $(TAG) $(TARGET)
		cp -av /tmp/artipie-bench/$(TARGET)/benchmarks/results/results.md ../../benchmarks/results/results.md

draw-charts: write-results
		python3 ./scripts/charts.py $(TARGET) $(NUMBER_CHARTS)
		mkdir -p ../../benchmarks/results/$(TAG)
		cp -avr ./out/$(TARGET)/* ../../benchmarks/results/$(TAG)
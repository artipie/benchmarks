
BENCH_SOURCE=benchmarks.json
TARGET=helm

.PHONY: all clean run generate build prepare distclean

all: distclean run

distclean: clean generate
	./script.sh clean
	rm -fr script.sh

clean:
	rm -fr out
	rm -f script.sh

generate:
	rm -f script.sh
	./generate.py $(BENCH_SOURCE) > script.sh
	chmod +x script.sh

clone: generate
	./script.sh clone $(TARGET)

build: clone
	./script.sh build $(TARGET)

prepare: generate
	./script.sh prepare $(TARGET)

run: build prepare
	./script.sh run $(TARGET)

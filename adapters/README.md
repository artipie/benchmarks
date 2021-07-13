# Benchmark toolkit

This is universal adapter benchmrak toolkit for running different SDK benchmarks from
single entry point.

## How to use

Run `make -TARGET=name run` with specified target name (one of `rpm`, `debian`, `helm`)

This command:
 - clone the repository
 - build the project and benchmark project,
 - prepare test data
 - run JMH benchmark and report to `out` dir in `$PWD`

## How to add new benchmark

 1. Prepare test data and archive it with `tar -czf` to `.tar.gz` format, upload this archive to server.
 3. Write a benchmark for adapter
 2. Update `benchmarks.json` file by adding new benchmark definition:
  ```json
        "newBench": {
                "name": "New adapter",
                "repo": "https://github.com/artipie/something-new.git",
                "benchmarks": {
                  "path": "bench-dir"
                }
        }
  ```
    where JSON item is a key-name for new benchmark, `name` is a name to display in console,
    `repo` git URL to clone benchmark, `benchmarks.path` is a location of benchmarks directory in
    repo.
  3. Add cases to `benchmarks`:
  ```json
    "cases": [
      {
        "name": "Batch update",
        "class": "com.artipie.rpm.Rpm.batchUpdateIncrementally",
        "data": "https://artipie.s3.amazonaws.com/rpm-test/bundle100.tar.gz",
        "args": [],
        "output": "rpm-batch-update.txt"
      }
    ]
  ```
  where `name` is a name of case to display in console,
  `class` - benchmark Java class to run,
  `args` - CLI arguments,
  `data` - location of `tar.gz` archive with test data,
  `output` - file to write a report (will be placed in `out/` dir).

## Known issues

In case of problem try to run `make distclean` before other commands.

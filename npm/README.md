# Benchmarks for NPM Artipie repositories.

## Private repository

TBD

## Proxy repository

### Initial setup

Currently central npmjs repository ([https://registry.npmjs.org](https://registry.npmjs.org))
contains more than 1 million packages. It's huge amount of data. But the number of packages
really in use is much lower. To obtain initial setup of the NPM repository 40 open-source
projects were taken from github and then built. As the result, 5.000+ packages with 8.000+
versions were downloaded to repository. The total size is approximately 1.5 GB.

### Test scenarios

#### Download cached packages

Tests downloading packages that already in cache. Every test sample downloads package
metadata and then downloads binary asset. Error threshold is considered as 10%.
Test data sample can be found in the `cached.zip` file - it contains the list of packages 
and assets in CSV format. Test plan is represented by `download-cached.jmx` JMeter file. 
It has several properties thar allows to configure it for particular environment:

* `repository.schema` - defines URL schema of NPM repository, `https` by default; 
* `repository.host` - defines hostname of NPM repository, `registry.npmjs.org` by default; 
* `repository.port` - defines porn of NPM repository, `443` by default;
* `repository.path` - context path of NPM repository, `<empty>` by default. It used for 
repository managers that routes requests to concrete repository based on URL paths;
* `users` - simultaneous users, 10 by default;
* `duration` - duration of test in seconds, 300 by default. Keep in mind that both JMeter
  and server requires time to be adapted to the load. Typically, test is stabilized
  during first minute.
  
To run the test we will use docker container with JMeter inside. Unzip `cached.zip` and run 
the command:
```shell script
$ docker run -it --rm --name junit -v `pwd`:`pwd` -w `pwd` justb4/jmeter:5.1.1 \
    -n -t download-cached.jmx -l results.jtl -e -o report \
    -Jrepository.host=artipie.com -Jrepository.schema=http -Jrepository.port=8080 -Jrepository.path=npm-proxy \
    -Jusers=4 -Jduration=600
```

Also sometimes it's useful to emulate limited network bandwidth. JMeter uses Apache httpclient 
inside. To do this you can use `-Jhttpclient.socket.http.cps` and `-Jhttpclient.socket.https.cps`
properties. It defines the bandwidth in bytes per second (not bits per second). But
httpclient realizes it in simple way - traffic goes on the full speed until limit is
reached and then traffic stops until current second ends. And no any *fairy* policies
applied. So you will have few extremely fast users and few extremely slow ones with 30+
seconds latencies.

You will get 2 kind of results after test run finished. First - `results.jtl` file. You
can use JMeter in GUI mode to get all necessary stats and graphic - simply add
`Listener` you need and specify this file to open. The second result - `report` folder.
It contains HTML report with most used key metrics.

##### Results

TBD retest on cloud environment.

Stress test for standard docker Sonatype Nexus 3.22 container shows the following:
Maximum throughput is ~ 1000 rps (500 tps) and it is obtained with 4 simultaneous users.
JVM heap size is limited with 1200 megabytes, CPU is unlimited but in the highest load
it takes ~ 800% CPU. The 5th user introduces 15-20% error rates and successful
throughput stays on the same level.

It's impossible to run the same functional test with npm-proxy because the current
implementation always try to download newer version of package metadata. After metadata
TTL feature will be implemented, this test can be completed in the right way.
With the current limitations we have the following results: maximum throughput is
~ 300 rps (150 tps). It is obtained with 12 users and not changed with the increasing of
users count until 1500 users. When test emulates more users, get package metadata
response times are increased significantly, and this is expected behavior.
  
#### Initial download packages
  
TBD. The key issue is to get more packages. 5.000 packages from the existing list
should be processed faster than 1 minute.
<a href="http://artipie.com"><img src="https://www.artipie.com/logo.svg" width="64px" height="64px"/></a>

[![Join our Telegramm group](https://img.shields.io/badge/Join%20us-Telegram-blue?&logo=telegram&?link=http://right&link=http://t.me/artipie)](http://t.me/artipie)

[![EO principles respected here](https://www.elegantobjects.org/badge.svg)](https://www.elegantobjects.org)
[![DevOps By Rultor.com](http://www.rultor.com/b/artipie/benchmarks)](http://www.rultor.com/p/artipie/http)
[![We recommend IntelliJ IDEA](https://www.elegantobjects.org/intellij-idea.svg)](https://www.jetbrains.com/idea/)

[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/artipie/benchmarks/blob/master/LICENSE.txt)
[![Hits-of-Code](https://hitsofcode.com/github/artipie/benchmarks)](https://hitsofcode.com/view/github/artipie/benchmarks)
[![PDD status](http://www.0pdd.com/svg?name=artipie/benchmarks)](http://www.0pdd.com/p?name=artipie/benchmarks)

If you have any question or suggestions, do not hesitate to [create an issue](https://github.com/artipie/benchmarks/issues/new) or contact us in
[Telegram](https://t.me/artipie).  
Artipie [roadmap](https://github.com/orgs/artipie/projects/3).

# Benchmarks for Artipie repositories.

## Overview of Artipie repositories benchmarking approach

This project contains examples and code snippets that will be used for performance testing
and results comparison over competitors. Project defines base principles and instruments 
will be used for benchmarking. Included examples are ready-to-run and extendable widely.

### Base principles we want to follow in benchmarking

1. **Open and reproducible**. All results we will publish are obtained fairly and
transparently for everyone who wants to reproduce. We will publish all necessary
information about environment and scenario steps. Scenarios should be designed in the way
to minimize external effects. The preferable way is to use public cloud environments.
2. **Compare the comparable ones**. Different products has different capabilities for
scalability both vertical and horizontal. We will not try to compare the `best-of-product-a`
configuration with a `some-of-product-b` config. We will try to use comparable environments
even if it is not the best setup for some product.
3. **Measure the significant things**. Every performance test depends on a lot of various
aspects. We need to be isolated from many of them, because of it can be irrelevant to our 
base functionality. Network delays, SSL connection establishing, logging load, backup 
and replication processes - all of them should be minimized or turned off during the tests.

### Instruments

Main instrument for benchmarking is Apache JMeter. All test scenarios will be run within it.

## Base scenarios

We need to run several scenarios for every kind of supported artifacts. We need to have
specialized scenarios for every repository type. And we need scenarios that aligned with
real usage scenarios of repository managers.

Let's define some typical scenarios and configurations.

### Repository types

The most of artifact types support 3 types of repositories:
1. **Private repository**. Allows publish artifacts and download them, access should be
authorized.
2. **Proxy repository**. It's a mirror of external repository. It allows only download
and usually not requires authorization.
3. **Group repository**. The aggregation of several repositories of type 1 and 2. It's
read-only but it may require authorization to access artifacts.

### Scenarios
1. **Stress tests**. The goal is to obtain maximum single-operation performance. We should
increase the load until error rate becomes more than the threshold.  
   1. *Private repositories*.
      1. Download artifacts. Key metric is throughput.
      2. Upload artifacts. Key metrics are throughput and upload speed.
   2. *Proxy repositories*.
      1. Download artifacts. Key metric is throughput.
   3. *Group repositories*.
      1. Download artifacts. Key metric is throughput.
2. **Role scenarios**. The goal is to get adequate real-world usage metrics. Usually it
is represented by complex scenario with several simultaneous different actions.
   1. *First-time installer*. This scenario creates a heavy load on the proxy repository
   because it necessary to download all base components that will be locally cached later.
   It does not require any uploads.  
   2. *CI/CD tool*. In typical case CI/CD tool uses actively uses internal cache of
   artifacts. The main purpose of this role - upload. But the internal cache usually 
   has TTL after that artifacts will be refreshed. So the average download/upload rate 
   should be approximately 4:1.
   3. *Developer*. Typically, it performs few downloads and very rare uploads. Good
   download/upload rate 100:1 and higher. This role not heavy depends on latency, but
   repository should support a lot of simultaneous clients in this role.

##  Performance testing

Currently basic performance testing could be done for maven and binary files adapters. Scripts rely on docker and jmeter tools. More details are in [loadtests/README.md](loadtests/README.md)

## Performance Monitoring

Performance monitoring configuration provides Grafana dashboards and based on docker compose, see [loadtests/monitoring/README.md](loadtests/monitoring/README.md)

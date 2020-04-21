#!/bin/bash
docker logs -f --tail 0 nexus | grep -q "Started Sonatype Nexus OSS"
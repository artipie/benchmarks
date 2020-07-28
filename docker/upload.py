#!/usr/bin/python3
import subprocess
import os
import time
import json


# Start artipie with preconfigured docker repo
def start_artipie():
    print("Starting artipie")
    artipie_yml = """
meta:
  storage:
    type: fs
    path: /var/artipie/configs
  layout: flat
"""
    my_docker = """
repo:
  type: docker
  storage:
    type: fs
    path: /var/artipie/data
  permissions:
    "*":
      - "*"
"""
    os.makedirs("./configs", exist_ok=True)
    f = open("./artipie.yaml", "w+")
    f.write(artipie_yml)
    f.close()
    f = open("./configs/my-docker.yaml", "w+")
    f.write(my_docker)
    f.close()
    subprocess.run([
        "bash", "-c",
        "docker run -d --rm --name artipie -it -v $(pwd)/artipie.yaml:/etc/artipie.yml -v $(pwd):/var/artipie -p 8080:80 artipie/artipie:latest"
    ])


# Start docker registry
def start_registry():
    print("Starting docker registry")
    subprocess.run(["docker",
                    "run",
                    "-d",
                    "--rm",
                    "-it",
                    "-p", "5000:5000",
                    "--name", "registry",
                    "registry:2"])


# Measure execution time for passed function
def measure(func):
    tick = time.time()
    func()
    tock = time.time()
    return tock - tick


# Perform benchmark
def perform_benchmarks(images):
    result = \
        {"docker":
            {
                "single-upload": {
                    "artipie": {
                        "images": []
                    },
                    "docker-registry": {
                        "images": []
                    }
                }
            }
        }
    single = result["docker"]["single-upload"]
    for image in images:
        registry_push = ["docker", "push", f"localhost:5000/{image}"]
        registry_time = measure(lambda: subprocess.run(registry_push))
        cmd = " ".join(registry_push)
        print(f"Command: {cmd}\'n Elapsed: {registry_time}")
        artipie_push = ["docker", "push", f"localhost:8080/my-docker/{image}"]
        artipie_time = measure(lambda: subprocess.run(artipie_push))
        cmd = " ".join(artipie_push)
        print(f"Command: {cmd}\'n Elapsed: {artipie_time}")
        single["artipie"]["images"].append({image: artipie_time})
        single["docker-registry"]["images"].append({image: registry_time})
    f = open("docker.json", "w+")
    f.write(json.dumps(result, indent=4, sort_keys=True))
    f.close()


# Pull images form docker hub and tag them for subsequent pushes
def pull_and_tag(images):
    for image in images:
        subprocess.run(["docker", "pull", image])
        subprocess.run(["docker", "tag", image, f"localhost:5000/{image}"])
        subprocess.run(["docker", "tag", image, f"localhost:8080/my-docker/{image}"])


# Entry point
if __name__ == '__main__':
    images = ["ubuntu", "graphiteapp/graphite-statsd", "g4s8/artipie-base"]
    pull_and_tag(images)
    start_registry()
    start_artipie()
    perform_benchmarks(images)
    subprocess.run(["docker", "stop", "registry"])
    subprocess.run(["docker", "stop", "artipie"])

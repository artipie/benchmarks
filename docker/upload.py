#!/usr/bin/python3
import subprocess
import sys
import os
import time
import json

images = ["ubuntu", "graphiteapp/graphite-statsd", "g4s8/artipie-base"]

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
    with open("./artipie.yaml", "w+") as f:
        f.write(artipie_yml)
    with open("./configs/my-docker.yaml", "w+") as f:
        f.write(my_docker)
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
    with open("benchmark-results.json", "w+") as f:
        f.write(json.dumps(result, indent=4, sort_keys=True))

# Pull images form docker hub and tag them for subsequent pushes


def pull_and_tag(images, host="localhost"):
    for image in images:
        subprocess.run(["docker", "pull", image])
        subprocess.run(["docker", "tag", image, f"{host}:5000/{image}"])
        subprocess.run(
            ["docker", "tag", image, f"{host}:8080/my-docker/{image}"])


# Entry point
if __name__ == '__main__':
    arguments = len(sys.argv) - 1
    # Run benchmark locally
    if arguments == 0:
        pull_and_tag(images)
        start_registry()
        start_artipie()
        perform_benchmarks(images)
        subprocess.run(["docker", "stop", "registry"])
        subprocess.run(["docker", "stop", "artipie"])
    # Run only pulling and tagging
    elif sys.argv[1] == "pull":
        pull_and_tag(images, host=os.getenv(
            "PUBLIC_SERVER_IP_ADDR", "localhost"))
    # Start only registry
    elif sys.argv[1] == "start_registry":
        start_registry()
    elif sys.argv[1] == "start_artipie":
        start_artipie()
    elif sys.argv[1] == "stop_registry":
        subprocess.run(["docker", "stop", "registry"])
    elif sys.argv[1] == "stop_artipie":
        subprocess.run(["docker", "stop", "artipie"])

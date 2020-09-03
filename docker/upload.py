#!/usr/bin/python3
import subprocess
import sys
import os
import time
import json

images = ["ubuntu", "graphiteapp/graphite-statsd", "g4s8/artipie-base"]


def run(args):
    """
    Run command with arguments + print command before starting it
    :param args: command arguments
    :return: nothing
    """
    command = " ".join(args)
    print(f"Py3: {command}")
    subprocess.run(args, check=True)


def start_artipie(version=os.getenv("ARTIPIE_VERSION", "latest")):
    """
    Start artipie docker image
    :param version: The artipie version to start
    :return: nothing
    """
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
    run([
        "bash", "-c",
        f"docker run -d --rm --name artipie -it -v $(pwd)/artipie.yaml:/etc/artipie.yml -v $(pwd):/var/artipie -p 8080:80 artipie/artipie:{version}"
    ])


def start_registry():
    """
    Start docker registry
    :return: nothing
    """
    print("Starting docker registry")
    run(["docker",
         "run",
         "-d",
         "--rm",
         "-it",
         "-p", "5000:5000",
         "--name", "registry",
         "registry:2"])


def measure(func):
    """
    Measure execution time for passed function
    :param func: the function
    :return: time elapsed
    """
    tick = time.time()
    func()
    tock = time.time()
    return tock - tick


def pull_and_tag(images, host="localhost"):
    """
    Pull images form docker hub and tag them for subsequent pushes
    :param images: Images to pull
    :param host: The host for tagging
    :return: nothing
    """
    for image in images:
        run(["docker", "pull", image])
        run(["docker", "tag", image, f"{host}:5000/{image}"])
        run(["docker", "tag", image, f"{host}:8080/my-docker/{image}"])


def benchmark_artipie():
    host = os.getenv("PUBLIC_SERVER_IP_ADDR")
    run(["docker", "login", "--username", "alice",
         "--password", "qwerty123", f"{host}:8080"])
    upload_benchmark(images, f"{host}:8080/my-docker", "artipie")


def benchmark_registry():
    host = os.getenv("PUBLIC_SERVER_IP_ADDR")
    upload_benchmark(images, f"{host}:5000", "docker-registry")


def upload_benchmark(images, address, registry):
    result = \
        {"docker":
            {
                "single-upload": {
                    registry: {
                        "images": []
                    }
                }
            }
        }
    for image in images:
        full_image = f"{address}/{image}"
        push = ["docker", "push", full_image]
        time = measure(lambda: run(push))
        print(f"Pushing {full_image}; Elapsed: {time}")
        result["docker"]["single-upload"][registry]["images"].append({image: time})
    with open(f"{registry}-benchmark-results.json", "w+") as f:
        f.write(json.dumps(result, indent=4, sort_keys=True))


# Entry point
if __name__ == '__main__':
    arguments = len(sys.argv) - 1
    # Run benchmark locally
    if arguments == 0:
        pull_and_tag(images)
        start_registry()
        start_artipie()
        upload_benchmark(images, f"localhost:8080/my-docker", "artipie")
        upload_benchmark(images, f"localhost:5000/", "docker-registry")
        run(["docker", "stop", "registry"])
        run(["docker", "stop", "artipie"])
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
        run(["docker", "stop", "registry"])
    elif sys.argv[1] == "stop_artipie":
        run(["docker", "stop", "artipie"])
    elif sys.argv[1] == "benchmark_artipie":
        benchmark_artipie()
    elif sys.argv[1] == "benchmark_registry":
        benchmark_registry()

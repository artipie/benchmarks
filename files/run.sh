#!/bin/sh
# Run performance tests.
#
# Usage: ./run.sh <jmeter-scenario.jmx> artipie|sonatype [<version>]
# --------------------------------------------------

function check_prerequisites {
  type ssh-keygen >/dev/null 2>&1 || { echo >&2 "ssh-keygen is required but is not found"; exit 1; }
  type terraform >/dev/null 2>&1 || { echo >&2 "terraform is required but is not found"; exit 1; }
  type ssh >/dev/null 2>&1 || { echo >&2 "ssh is required but is not found"; exit 1; }
  type scp >/dev/null 2>&1 || { echo >&2 "scp is required but is not found"; exit 1; }
}

function generate_keys {
  if [ ! -f "id_rsa_perf" ]
  then
    ssh-keygen -t rsa -b 4096 -f id_rsa_perf -N ""
  fi
}

if [ $# -lt 2 ]
then
  echo >&2 "Usage: ./run.sh <jmeter-scenario.jmx> artipie|sonatype [<version>]"
  exit 1
fi

cd "$(dirname "$0")"
if [ ! -f "$1" ]
then
  echo >&2 "Could not find file $1"
  exit 1
fi
scenario=$1

if [ "$2" != 'artipie' ] && [ "$2" != 'sonatype' ]
then
  echo >&2 "Unknown repository '$2': only 'artipie' and 'sonatype' are supported"
  exit 1
fi
repository=$2

if [ $# -gt 2 ]
then
  version=$3
else
  version='latest'
fi

check_prerequisites
generate_keys
terraform init -input=false tf
terraform apply -input=false -auto-approve \
  -var "repository={type=\"${repository}\", version=\"${version}\"}" \
  -var "scenario_file=${scenario}" \
  tf

jmeter_ip_addr=$(terraform output jmeter_ip_addr)
server_ip_addr=$(terraform output server_ip_addr)

if [ "${repository}" == "artipie" ]
then
  remote_cmd="./apache-jmeter-5.2.1/bin/jmeter -n -t upload-files.jmx -l results.jtl -e -o report -Jrepository.host=${server_ip_addr} -Jrepository.path=files -Jlogin=user -Jpassword=password"
elif [ "${repository}" == "sonatype" ]
then
  remote_cmd="./apache-jmeter-5.2.1/bin/jmeter -n -t upload-files.jmx -l results.jtl -e -o report -Jrepository.host=${server_ip_addr} -Jrepository.path='repository/files' -Jlogin=user -Jpassword=password"
fi

ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=60 -i id_rsa_perf ubuntu@${jmeter_ip_addr} "${remote_cmd}"
scp -o StrictHostKeyChecking=no -o ServerAliveInterval=60 -i id_rsa_perf -r ubuntu@${jmeter_ip_addr}:report .

terraform destroy -input=false -auto-approve \
  -var "repository={type=\"${repository}\", version=\"${version}\"}" \
  -var "scenario_file=${scenario}" \
  tf

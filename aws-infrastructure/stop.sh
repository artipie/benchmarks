#!/bin/bash
set -x

# Enter aws-infrastructure dir, whaterver the script is called from
cd "$( dirname "${BASH_SOURCE[0]}" )"

# Auto approve terrafrom commands
export TF_CLI_ARGS="-input=false -auto-approve"

terraform destroy
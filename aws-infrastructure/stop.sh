#!/bin/bash
set -x

# Auto approve terrafrom commands
export TF_CLI_ARGS="-input=false -auto-approve"

terraform destroy
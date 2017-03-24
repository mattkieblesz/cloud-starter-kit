#!/bin/bash

readonly SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )
readonly BASE_DIR=$( cd $SCRIPT_DIR/.. && pwd )

source "$SCRIPT_DIR/utils.sh"

main() {
    # Be unforgiving about errors
    set -euo pipefail

    inf "--> Compose local environment"
    ANSIBLE_CONFIG=$BASE_DIR/conf/ansible.cfg ansible-playbook $BASE_DIR/plays/local_setup.yml
}

[[ "$0" == "$BASH_SOURCE" ]] && main

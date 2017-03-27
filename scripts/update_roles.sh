#!/bin/bash

readonly SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
readonly BASE_DIR=$( cd $SCRIPT_DIR/.. && pwd )

readonly VENDOR_ROLES_DIR="$BASE_DIR/roles/vendor"
readonly VENDOR_ROLES_REQUIREMNTS="$SCRIPT_DIR/local/role_requirements.yml"

source "$SCRIPT_DIR/utils.sh"

prerequisites() {
    local ansible_galaxy_cmd=`which ansible-galaxy`

    if [ -z "$ansible_galaxy_cmd" ]; then
        error "ansible-galaxy does not appear to be installed. Please install and re-run this script."
        exit 1
    fi
}

main() {
    # Be unforgiving about errors
    set -euo pipefail

    prerequisites

    if [ -d "$VENDOR_ROLES_DIR" ]; then
        cd "$VENDOR_ROLES_DIR"
        if [ "$(pwd)" == "$VENDOR_ROLES_DIR" ];then
            warn "Removing current roles in '$VENDOR_ROLES_DIR/*'"
            rm -rf *
        else
            error "Path error could not change dir to $VENDOR_ROLES_DIR"
        fi
    else
        mkdir -p $VENDOR_ROLES_DIR
    fi

    inf "--> Installing Ansible Galaxy roles"
    ansible-galaxy install -r "$VENDOR_ROLES_REQUIREMNTS" --force --no-deps -p "$VENDOR_ROLES_DIR"
}

[[ "$0" == "$BASH_SOURCE" ]] && main

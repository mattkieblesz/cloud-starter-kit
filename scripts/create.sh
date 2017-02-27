#!/bin/bash

# Discover if we are using terraform aws/terraform scaleway/local docker/local vagrant/local hybrid
# Discover if we are using images

# if terraform (aws/scaleway)
#   run terraform plan & apply if yes

# if local docker
#   run docker run

# if local vagrant
#   run vagrant up

readonly SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

source "$SCRIPT_DIR/utils.sh"

OPTIONS="$@"

DEFAULT_STORE="local"  # local/s3
DEFAULT_TYPE="vagrant"  # docker/vagrant/aws/scaleway
DEFAULT_VERSION="$( git rev-parse HEAD )"  # <tag-name>/<commit-hash>

parse_options() {
    # getopt doesn't know what empty string means! use substring matching instead
    for option in $OPTIONS
    do
        case $option in
            -p=*|--play=*) PLAY="${option#*=}";;  # playbook in <playbook-name> format
            -s=*|--store=*) STORE="${option#*=}" && [ -z "$STORE" ] && STORE=$DEFAULT_STORE;;
            -t=*|--type=*) TYPE="${option#*=}" && [ -z "$TYPE" ] && TYPE=$DEFAULT_TYPE;;
            -v=*|--version=*) VERSION="${option#*=}" && [ -z "$VERSION" ] && VERSION=$DEFAULT_VERSION;;
            (*) break;;
        esac
    done

    if [ -z $PLAY ]; then
        error "You need to specify play"
        exit 1
    fi
}

main() {
    # Be unforgiving about errors
    set -euo pipefail

    parse_options

    inf "--> Creating resource:"
    inf "-->    store: $STORE"
    inf "-->    play: $PLAY"
    inf "-->    version: $VERSION"
    inf "-->    type: $TYPE"

    if [ $TYPE = "vagrant" ]; then
        inf "--> Copy template files"
    fi
}

[[ "$0" == "$BASH_SOURCE" ]] && main

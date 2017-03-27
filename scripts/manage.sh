#!/bin/bash

readonly SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

source "$SCRIPT_DIR/utils.sh"

COMMAND=$1

OPTIONS="${@:2}"

DEFAULT_PLAY="all"
DEFAULT_ENV="local"
DEFAULT_STORE="local"  # local/s3
DEFAULT_IMAGE_TYPE="docker"  # docker/vagrant/aws/scaleway
DEFAULT_VERSION="$( git rev-parse HEAD )"  # <tag-name> or <commit-hash>

parse_options() {
    # getopt doesn't know what empty string means! use substring matching instead
    for option in $OPTIONS
    do
        case $option in
            -p=*|--play=*) PLAY="${option#*=}" && [ -z "$PLAY" ] && PLAY=$DEFAULT_PLAY;;  # playbook in <playbook-name> format
            -e=*|--env=*) ENV="${option#*=}" && [ -z "$ENV" ] && ENV=$DEFAULT_ENV;;
            -s=*|--store=*) STORE="${option#*=}" && [ -z "$STORE" ] && STORE=$DEFAULT_STORE;;
            -t=*|--image-type=*) IMAGE_TYPE="${option#*=}" && [ -z "$IMAGE_TYPE" ] && IMAGE_TYPE=$DEFAULT_IMAGE_TYPE;;
            -v=*|--version=*) VERSION="${option#*=}" && [ -z "$VERSION" ] && VERSION=$DEFAULT_VERSION;;
            (*) break;;
        esac
    done
}

main() {
    # Be unforgiving about errors
    set -euo pipefail

    parse_options

    if [ $COMMAND == "create" ]; then
        inf "Create infrastructure for $ENV environment"
        # Discover if we are using terraform aws/terraform scaleway/local docker/local vagrant/local hybrid
        # Discover if we are using images

        # if terraform (aws/scaleway)
        #   run terraform plan & apply if yes

        # if local docker
        #   run docker run

        # if local vagrant
        #   run vagrant up
    elif  [ $COMMAND == "run" ]; then
        inf "Run infrastructure for $ENV environment"
    elif  [ $COMMAND == "halt" ]; then
        inf "Halt infrastructure for $ENV environment"
    elif  [ $COMMAND == "destroy" ]; then
        inf "Destroy infrastructure for $ENV environment"
        # Discover if we are using terraform aws/terraform scaleway/local docker/local vagrant
        # Discover if we are using images

        # if terraform (aws/scaleway)
        #   run terraform destroy & apply if yes

        # if local docker
        #   run docker rm

        # if local vagrant
        #   run vagrant destroy

    elif  [ $COMMAND == "provision" ]; then
        inf "Provision to $ENV environment"
    elif  [ $COMMAND == "deploy" ]; then
        inf "Deploy to $ENV environment"
        # Discover if we are using builds or just reprovisioning

        # if builds
        #   spin up resource with new build (create), divert traffic to it, teardown old instance (destroy)

        # if reporivsioning
        #   run playbook against resource
    elif  [ $COMMAND == "build" ]; then
        inf "Build image for $ENV environment"
    elif  [ $COMMAND == "test" ]; then
        inf "Run test suite"
    elif  [ $COMMAND == "backup" ]; then
        inf "Backup datastore for $ENV environment"
        # Run only against datastore resources
        # Get playbooks tasks by using tags which will do backing up
    fi

}

[[ "$0" == "$BASH_SOURCE" ]] && main

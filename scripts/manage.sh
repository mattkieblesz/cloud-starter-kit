#!/bin/bash

readonly SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
readonly BASE_DIR=$( cd $SCRIPT_DIR/.. && pwd )
readonly WORKSPACE_DIR=$BASE_DIR/workspace

source "$SCRIPT_DIR/utils.sh"

COMMAND=$1
OPTIONS="${@:2}"
DEFAULT_SERVICE="all"
DEFAULT_ENV="local"
DEFAULT_STORE="local"  # local/s3
DEFAULT_VERSION="$( git rev-parse HEAD )"  # <tag-name> or <commit-hash>
DEFAULT_TAGS="all"

parse_options() {
    # getopt doesn't know what empty string means! use substring matching instead
    for option in $OPTIONS
    do
        case $option in
            --env=*) ENV="${option#*=}" && [ -z "$ENV" ] && ENV=$DEFAULT_ENV;;
            --store=*) STORE="${option#*=}" && [ -z "$STORE" ] && STORE=$DEFAULT_STORE;;
            --version=*) VERSION="${option#*=}" && [ -z "$VERSION" ] && VERSION=$DEFAULT_VERSION;;
            --service=*) SERVICE="${option#*=}" && [ -z "$SERVICE" ] && SERVICE=$DEFAULT_SERVICE;;
            --tags=*) TAGS="${option#*=}" && [ -z "$TAGS" ] && TAGS=$DEFAULT_TAGS;;
            (*) break;;
        esac
    done

    if [ $SERVICE == "all" ]; then
        SERVICES=$(dir workspace/)
    else
        SERVICES=($SERVICE)
    fi
}

main() {
    # Be unforgiving about errors
    set -euo pipefail

    parse_options

    if [ $COMMAND == "build" ]; then
        inf "Building image"

    elif [ $COMMAND == "test" ]; then
        inf "Run test suite"

    elif [ $COMMAND == "backup" ]; then
        inf "Backup datastore for $ENV environment"
        # Run only against datastore resources
        # Get playbooks tasks by using tags which will do backing up

    elif [ $ENV == "local" ]; then
        for service_name in $SERVICES;
        do
            service_dir="$WORKSPACE_DIR/$service_name"
            if [ -f $service_dir/Vagrantfile ]; then
                type='vagrant'
            elif [ -f $service_dir/Dockerfile ]; then
                type='docker'
            fi

            if [ $COMMAND == "create" ]; then
                if [ $type == "vagrant" ]; then
                    (cd $service_dir && vagrant up)
                fi
            elif [ $COMMAND == "run" ]; then
                if [ $type == "vagrant" ]; then
                    (cd $service_dir && vagrant up)
                fi
            elif [ $COMMAND == "halt" ]; then
                if [ $type == "vagrant" ]; then
                    (cd $service_dir && vagrant halt)
                fi
            elif [ $COMMAND == "destroy" ]; then
                if [ $type == "vagrant" ]; then
                    (cd $service_dir && vagrant destroy)
                fi
            elif [ $COMMAND == "provision" ]; then
                if [ $type == "vagrant" ]; then
                    (cd $service_dir && ansible-playbook -i inventory —private-key=~/.vagrant.d/insecure_private_key -u vagrant ../../plays/$service_name.yml —tags="$TAGS")
                fi
            elif [ $COMMAND == "deploy" ]; then
                if [ $type == "vagrant" ]; then
                    (cd $service_dir && ansible-playbook -i inventory —private-key=~/.vagrant.d/insecure_private_key -u vagrant ../../plays/$service_name.yml —tags="$TAGS")
                fi
            elif [ $COMMAND == "deploy" ]; then
                if [ $type == "vagrant" ]; then
                    (cd $service_dir && ansible-playbook -i inventory —private-key=~/.vagrant.d/insecure_private_key -u vagrant ../../plays/$service_name.yml —tags="$TAGS")
                fi
            fi
        done
    else
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
        elif [ $COMMAND == "run" ]; then
            inf "Run infrastructure for $ENV environment"

        elif [ $COMMAND == "halt" ]; then
            inf "Halt infrastructure for $ENV environment"

        elif [ $COMMAND == "destroy" ]; then
            inf "Destroy infrastructure for $ENV environment"

            # Discover if we are using terraform aws/terraform scaleway/local docker/local vagrant
            # Discover if we are using images

            # if terraform (aws/scaleway)
            #   run terraform destroy & apply if yes

            # if local docker
            #   run docker rm

            # if local vagrant
            #   run vagrant destroy

        elif [ $COMMAND == "provision" ]; then
            inf "Provision to $ENV environment"

        elif [ $COMMAND == "deploy" ]; then
            inf "Deploy to $ENV environment"

            # Discover if we are using builds or just reprovisioning

            # if builds
            #   spin up resource with new build (create), divert traffic to it, teardown old instance (destroy)

            # if reporivsioning
            #   run playbook against resource
        fi
    fi

}

[[ "$0" == "$BASH_SOURCE" ]] && main

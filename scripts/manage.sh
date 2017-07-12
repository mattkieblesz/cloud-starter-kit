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

ansible_provision() {
    env=$1
    service_name=$2
    config_file=$BASE_DIR/workspace/$service_name/ansible.cfg
    inventory_file=$BASE_DIR/envs/$env/inventory
    playbook_file=$BASE_DIR/plays/$service_name.yml

    ANSIBLE_CONFIG=$config_file ansible-playbook -i $inventory_file $playbook_file --limit $service_name
}

main() {
    # Be unforgiving about errors
    set -euo pipefail

    parse_options

    if [ $COMMAND == "build" ]; then
        inf "Building image with packer"

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
            image_name="$type-$service_name"
            image_tag=$DEFAULT_VERSION

            if [ $COMMAND == "create" ]; then
                if [ $type == "vagrant" ]; then
                    (cd $service_dir && vagrant up)
                elif [ $type == "docker" ]; then
                    (cd $service_dir && docker build -t $image_name:$image_tag .)
                fi
            elif [ $COMMAND == "run" ]; then
                if [ $type == "vagrant" ]; then
                    (cd $service_dir && vagrant up)
                elif [ $type == "docker" ]; then
                    if [[ "$(docker build -q $image_name:$image_tag 2> /dev/null)" == "" ]]; then
                        (cd $service_dir && docker build -t $image_name:$image_tag .)
                    fi
                    (cd $service_dir && docker run -p 22 --net cloud-starter-kit --ip 192.168.20.10 -d -i -t $image_name:$image_tag)
                fi
            elif [ $COMMAND == "halt" ]; then
                if [ $type == "vagrant" ]; then
                    (cd $service_dir && vagrant halt)
                elif [ $type == "docker" ]; then
                    (cd $service_dir && docker stop $(docker ps -q --filter ancestor=$image_name:$image_tag ))
                fi
            elif [ $COMMAND == "destroy" ]; then
                if [ $type == "vagrant" ]; then
                    (cd $service_dir && vagrant destroy)
                elif [ $type == "docker" ]; then
                    (cd $service_dir && docker stop $(docker ps -q --filter ancestor=$image_name:$image_tag ))
                    (cd $service_dir && docker rmi $image_name:$image_tag)
                fi
            elif [ $COMMAND == "provision" ]; then
                if [ $type == "vagrant" ]; then
                    (cd $service_dir && vagrant provision)
                elif [ $type == "docker" ]; then
                    inf "Pass"
                fi
            elif [ $COMMAND == "deploy" ]; then
                if [ $type == "vagrant" ]; then
                    (cd $service_dir && vagrant provision)
                elif [ $type == "docker" ]; then
                    inf "Pass"
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

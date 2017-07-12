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

parse_options() {
    # getopt doesn't know what empty string means! use substring matching instead
    for option in $OPTIONS
    do
        case $option in
            --env=*) ENV="${option#*=}" && [ -z "$ENV" ] && ENV=$DEFAULT_ENV;;
            --store=*) STORE="${option#*=}" && [ -z "$STORE" ] && STORE=$DEFAULT_STORE;;
            --version=*) VERSION="${option#*=}" && [ -z "$VERSION" ] && VERSION=$DEFAULT_VERSION;;
            --service=*) SERVICE="${option#*=}" && [ -z "$SERVICE" ] && SERVICE=$DEFAULT_SERVICE;;
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
    tag=$3
    config_file=$BASE_DIR/envs/$env/ansible.cfg
    inventory_file=$BASE_DIR/envs/$env/inventory
    playbook_file=$BASE_DIR/plays/$service_name.yml

    ANSIBLE_CONFIG=$config_file ansible-playbook -i $inventory_file $playbook_file --limit $service_name --tags $tag
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

        if [ $ENV == 'local' ]; then
            for service_name in $SERVICES;
            do
                service_dir="$WORKSPACE_DIR/$service_name"

                if [ -f $service_dir/Vagrantfile ]; then
                    (cd $service_dir && vagrant up)

                elif [ -f $service_dir/Dockerfile ]; then
                    image_name="docker-$service_name"
                    image_tag=$DEFAULT_VERSION

                    (cd $service_dir && docker build -t $image_name:$image_tag .)
                fi

                make run SERVICE=$service_name ENV=local
            done
        else
            env_dir="$BASE_DIR/envs/$ENV"
            if [ -f $env_dir/terraform.tf ]; then
                inf "Terraform cmd"
            fi
        fi

    elif [ $COMMAND == "destroy" ]; then
        # Discover if we are using terraform aws/terraform scaleway/local docker/local vagrant
        # Discover if we are using images

        # if terraform (aws/scaleway)
        #   run terraform destroy & apply if yes

        if [ $ENV == 'local' ]; then
            for service_name in $SERVICES;
            do
                service_dir="$WORKSPACE_DIR/$service_name"

                if [ -f $service_dir/Vagrantfile ]; then
                    (cd $service_dir && vagrant destroy)

                elif [ -f $service_dir/Dockerfile ]; then
                    image_name="docker-$service_name"
                    image_tag=$DEFAULT_VERSION

                    (cd $service_dir && docker stop $(docker ps -q --filter ancestor=$image_name:$image_tag ))
                    (cd $service_dir && docker rmi $image_name:$image_tag)
                fi
            done
        else
            env_dir="$BASE_DIR/envs/$ENV"
            if [ -f $env_dir/terraform.tf ]; then
                inf "Destroy infrastructure with terraform"
            fi
        fi

    elif [ $COMMAND == "run" ]; then
        env_dir="$BASE_DIR/envs/$ENV"

        if [ $ENV == 'local' ]; then
            for service_name in $SERVICES;
            do
                service_dir="$WORKSPACE_DIR/$service_name"

                if [ -f $service_dir/Vagrantfile ]; then
                    (cd $service_dir && vagrant up)

                elif [ -f $service_dir/Dockerfile ]; then
                    # since we are not using compose we need to get ips from config here
                    image_name="docker-$service_name"
                    image_tag=$DEFAULT_VERSION

                    if [[ "$(docker build -q $image_name:$image_tag 2> /dev/null)" == "" ]]; then
                        (cd $service_dir && docker build -t $image_name:$image_tag .)
                    fi
                    (cd $service_dir && ./docker_run.sh $image_name:$image_tag)
                fi
            done
        else
            if [ -f $env_dir/terraform.tf ]; then
                inf "Destroy infrastructure with terraform"
            fi
        fi

    elif [ $COMMAND == "halt" ]; then
        if [ $ENV == 'local' ]; then
            for service_name in $SERVICES;
            do
                service_dir="$WORKSPACE_DIR/$service_name"

                if [ -f $service_dir/Vagrantfile ]; then
                    (cd $service_dir && vagrant halt)

                elif [ -f $service_dir/Dockerfile ]; then
                    image_name="docker-$service_name"
                    image_tag=$DEFAULT_VERSION

                    (cd $service_dir && docker stop $(docker ps -q --filter ancestor=$image_name:$image_tag ))
                fi
            done
        else
            env_dir="$BASE_DIR/envs/$ENV"
            if [ -f $env_dir/terraform.tf ]; then
                inf "Destroy infrastructure with terraform"
            fi
        fi

    elif [ $COMMAND == "provision" ]; then
        for service_name in $SERVICES;
        do
            inf "Provision $service_name for $ENV environment"
            ansible_provision $ENV $service_name 'all'
        done

    elif [ $COMMAND == "deploy" ]; then
        # Discover if we are using builds or just reprovisioning

        # if builds
        #   spin up resource with new build (create), divert traffic to it, teardown old instance (destroy)

        # if reporivsioning
        #   run playbook against resource
        for service_name in $SERVICES;
        do
            inf "Deploy $service_name for $ENV environment"
            ansible_provision $ENV $service_name 'deploy'
        done

    elif [ $COMMAND == "build" ]; then
        inf "Building image with packer"

    # Run only against datastore resources
    # Get playbooks tasks by using tags which will do backing up
    elif [ $COMMAND == "backup" ]; then
        inf "Backup datastore for $ENV environment"

    elif [ $COMMAND == "test" ]; then
        inf "Run test suite"
    fi

}

[[ "$0" == "$BASH_SOURCE" ]] && main

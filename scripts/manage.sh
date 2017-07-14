#!/bin/bash

readonly SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
readonly BASE_DIR=$( cd $SCRIPT_DIR/.. && pwd )

readonly SECRETS_DIR="$BASE_DIR/conf/secrets"
readonly WORKSPACE_DIR=$BASE_DIR/workspace

readonly STORE_BUCKET_NAME=$( cd $BASE_DIR && basename $(pwd) )

source "$SCRIPT_DIR/utils.sh"

COMMAND=$1
OPTIONS="${@:2}"
DEFAULT_SERVICE="all"
DEFAULT_ENV="local"
DEFAULT_STORE="local"  # local/s3
DEFAULT_BUILD_TYPE="amazon-instance"

get_service_version() {
    service_dir="$WORKSPACE_DIR/$1"
    if [ -d "$service_dir/.git" ]; then
        git_dir="$service_dir"
    else
        git_dir="."
    fi

    # current latest tag for the service with stripped v prefix
    # TODO: add checking release branch and get only from that major version
    version=$(cd $git_dir && git tag -l --sort=v:refname "v*" | tail -1  | cut -c 2-)
    echo $version
}

parse_options() {
    # getopt doesn't know what empty string means! use substring matching instead
    for option in $OPTIONS
    do
        case $option in
            --env=*) ENV="${option#*=}" && [ -z "$ENV" ] && ENV=$DEFAULT_ENV;;
            --store=*) STORE="${option#*=}" && [ -z "$STORE" ] && STORE=$DEFAULT_STORE;;
            --service=*) SERVICE="${option#*=}" && [ -z "$SERVICE" ] && SERVICE=$DEFAULT_SERVICE;;
            --build-type=*) BUILD_TYPE="${option#*=}" && [ -z "$BUILD_TYPE" ] && BUILD_TYPE=$DEFAULT_BUILD_TYPE;;
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
    config_file=$SECRETS_DIR/ansible.cfg
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
                    image_tag=$(get_service_version $service_name)

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
                    image_tag=$(get_service_version $service_name)

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
                    image_tag=$(get_service_version $service_name)

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
                    image_tag=$(get_service_version $service_name)

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
        for service_name in $SERVICES;
        do
            inf "Build $service_name image"
            # get latest <git tag> from workspace repo or git tag from this cloud repo
            # increment build using script and save output in service_version variable
            #
            version=$(get_service_version $service_name)
            if [ -z "$version" ]; then
                version="0.0.0.0"
            else
                version=$(./scripts/increment_version.sh $version)
            fi

            service_version="v$version"

            if [[ $BUILD_TYPE == "amazon-instance" || $BUILD_TYPE == "amazon-ebs" ]]; then
                # FIXME: for eu-west-2 (london) amazon-instance builder fails since upload to s3 to this
                # region is not supported (consider using awscli instead of aws-ami-tools)

                # region=$(grep "^region=" $SECRETS_DIR/aws-config | cut -d= -f2)
                region=$(aws s3api get-bucket-location --output text --bucket $STORE_BUCKET_NAME)

                region_var="region=$region"
                service_name_var="service_name=$service_name"
                service_version_var="service_version=$service_version"
                bucket_name_var="bucket_name=$STORE_BUCKET_NAME"
                base_dir_var="base_dir=$BASE_DIR"
                account_id_var="account_id=$(aws sts get-caller-identity --output text --query 'Account')"

                packer build -var-file=$SECRETS_DIR/credentials.json \
                            -var $region_var \
                            -var $service_name_var \
                            -var $service_version_var \
                            -var $bucket_name_var \
                            -var $base_dir_var \
                            -var $account_id_var \
                            -only $BUILD_TYPE \
                            $SCRIPT_DIR/templates/packer-amazon.json
            else
                warn "Build type $BUILD_TYPE is not supported"
            fi
        done

    elif [ $COMMAND == "backup" ]; then
        # Run only against datastore resources
        # Get playbooks tasks by using tags which will do backing up
        inf "Run  backup"
    elif [ $COMMAND == "test" ]; then
        inf "Run test suite"
    fi

}

[[ "$0" == "$BASH_SOURCE" ]] && main

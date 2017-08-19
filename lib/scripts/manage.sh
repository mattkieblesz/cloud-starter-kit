#!/bin/bash

readonly SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
readonly BASE_DIR=$( cd $SCRIPT_DIR/../.. && pwd )

readonly SECRETS_DIR="$BASE_DIR/conf/secrets"
readonly WORKSPACE_DIR=$BASE_DIR/workspace

readonly STORE_BUCKET_NAME=$( cd $BASE_DIR && basename $(pwd) )
readonly LOCAL_STORE_DIR="$BASE_DIR/envs/local/store"

source "$SCRIPT_DIR/utils.sh"

COMMAND=$1
OPTIONS="${@:2}"
DEFAULT_SERVICE="all"
DEFAULT_ENV="local"
DEFAULT_STORE="local"
BUILD_TAG=false
DEFAULT_BUILD_TYPE="amazon-ebs"
DEFAULT_TEST_TYPE="vagrant"
DEFAULT_CONCURENCY="1"
BASE_VAGRANT_BOX_URL="https://app.vagrantup.com/ubuntu/boxes/trusty64/versions/20170619.0.0/providers/virtualbox.box"
DEFAULT_PROVISION_TAG="all"

get_service_version() {
    # All services which have it's own repo are being tagged
    # Other services versions are kept within this repo

    # current latest tag for the service with stripped v prefix
    # TODO: add checking release branch and get only from that major version
    version=$(cd $WORKSPACE_DIR/$service_name && git tag -l --sort=v:refname "v*" | tail -1  | cut -c 2-)

    if [ -z "$version" ]; then
        version="0.0.0.0"
    fi
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
            --test-type=*) TEST_TYPE="${option#*=}" && [ -z "$TEST_TYPE" ] && TEST_TYPE=$DEFAULT_TEST_TYPE;;
            --concurency=*) CONCURENCY="${option#*=}" && [ -z "$CONCURENCY" ] && CONCURENCY=$DEFAULT_CONCURENCY;;
            --provision-tag=*) PROVISION_TAG="${option#*=}" && [ -z "$PROVISION_TAG" ] && PROVISION_TAG=$DEFAULT_PROVISION_TAG;;
            --build-tag) BUILD_TAG=true;;
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
    config_file=$BASE_DIR/conf/ansible.cfg
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

        if [ $ENV == 'local' ]; then
            for service_name in $SERVICES;
            do
                service_dir="$WORKSPACE_DIR/$service_name"
                service_version=$(get_service_version $service_name)

                if [ -f $service_dir/Vagrantfile ]; then
                    vagrant_box="${service_name}_${service_version}.box"
                    vagrant_box_path="images/vagrant/$vagrant_box"
                    current_vagrant_box_link="images/vagrant/latest.box"

                    if [ ! -f $LOCAL_STORE_DIR/$vagrant_box_path ]; then
                        if [ $(aws s3 ls s3://$STORE_BUCKET_NAME/$vagrant_box_path | wc -l) == 0 ]; then
                            inf "$vagrant_box box doesn't exist in remote store. Use base box instead."

                            vagrant_box_path="images/vagrant/base.box"

                            if [ $(aws s3 ls s3://$STORE_BUCKET_NAME/$vagrant_box_path | wc -l) == 0 ]; then
                                inf "Base box doesn't exit in remote store... download it from $BASE_VAGRANT_BOX_URL"

                                wget $BASE_VAGRANT_BOX_URL -O $LOCAL_STORE_DIR/$vagrant_box_path

                                inf "Upload base box to remote store"
                                aws s3 cp $LOCAL_STORE_DIR/$vagrant_box_path s3://$STORE_BUCKET_NAME/$vagrant_box_path
                            fi
                        else
                            inf "Download box from remote store"
                            aws s3 cp s3://$STORE_BUCKET_NAME/$vagrant_box_path $LOCAL_STORE_DIR/$vagrant_box_path
                        fi
                    fi

                    # remove latest link
                    rm -f $LOCAL_STORE_DIR/$current_vagrant_box_link
                    # link currently used box
                    ln -s $LOCAL_STORE_DIR/$vagrant_box_path $LOCAL_STORE_DIR/$current_vagrant_box_link

                elif [ -f $service_dir/Dockerfile ]; then
                    image_tag=$service_version
                    docker_image="${service_name}_${image_tag}.tar"
                    docker_image_path="images/docker/$docker_image"

                    # if image doesn't exist in local docker registry
                    if [[ "$(docker images -q $service_name:$image_tag 2> /dev/null)" == "" ]]; then
                        if [ ! -f $LOCAL_STORE_DIR/$docker_image_path ]; then
                            if [ $(aws s3 ls s3://$STORE_BUCKET_NAME/$docker_image_path | wc -l) == 0 ]; then
                                inf "$docker_image image doesn't exist in remote store. Build base box from Docker file"
                                image_tag="base"
                                (cd $service_dir && docker build -t $service_name:$image_tag .)
                            else
                                inf "Download box from remote store"
                                aws s3 cp s3://$STORE_BUCKET_NAME/$docker_image_path $LOCAL_STORE_DIR/$docker_image_path

                                inf "Load image into docker"
                                docker load -i $LOCAL_STORE_DIR/$docker_image_path
                            fi
                        else
                            docker load -i $LOCAL_STORE_DIR/$docker_image_path
                        fi
                    fi

                    # untag latest docker version of this service
                    if [[ "$(docker images -q $service_name:latest 2> /dev/null)" != "" ]]; then
                        docker rmi $service_name:latest
                    fi
                    docker tag $service_name:$image_tag $service_name:latest
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
                    image_name="$service_name"
                    image_tag=$(get_service_version $service_name)

                    docker stop $(docker ps -q --filter ancestor=$image_name:$image_tag )
                    docker rmi -f $image_name:$image_tag
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
                    (cd $service_dir && ./docker_run.sh $service_name:latest)
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
                    image_name="$service_name"
                    image_tag=$(get_service_version $service_name)

                    docker stop $(docker ps -q --filter ancestor=$image_name:$image_tag )
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
            ansible_provision $ENV $service_name $PROVISION_TAG
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
        if [[ ${#SERVICES[@]} == 0 ]]; then
            error "You must specify only one service instead of: $SERVICES\n"
            exit 0
        fi
        service_name=${SERVICES[0]}

        inf "Build $service_name image"

        # get latest <git tag> from workspace repo or git tag from this cloud repo
        # increment build using script and save output in service_version variable
        version=$(get_service_version $service_name)
        if [ $version != "0.0.0.0" ]; then
            version=$(./scripts/increment_version.sh -b $version)
        fi
        full_version="v$version"

        if [[ $BUILD_TYPE == "amazon-instance" || $BUILD_TYPE == "amazon-ebs" ]]; then
            # FIXME: for eu-west-2 (london) amazon-instance builder fails since upload to s3 to this
            # region is not supported (consider using awscli instead of aws-ami-tools)
            # TODO: local vagrant/docker with packer

            # region=$(grep "^region=" $SECRETS_DIR/aws-config | cut -d= -f2)
            region=$(aws s3api get-bucket-location --output text --bucket $STORE_BUCKET_NAME)

            region_var="region=$region"
            service_name_var="service_name=$service_name"
            service_version_var="service_version=$version"
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
            error "Build type $BUILD_TYPE is not supported\n"
            exit 0
        fi

        # tag service if it has repo
        if [[ $BUILD_TAG == true ]]; then
            echo 'build'
            (cd $WORKSPACE_DIR/$service_name && git tag $full_version && git push origin $full_version)
        fi

    elif [ $COMMAND == "push" ]; then
        if [[ ${#SERVICES[@]} == 0 ]]; then
            error "You must specify only one service instead of: $SERVICES\n"
            exit 0
        fi
        service_name=${SERVICES[0]}

        inf "Push $service_name current version image"

        service_dir="$WORKSPACE_DIR/$service_name"
        service_version=$(get_service_version $service_name)

        if [ -f $service_dir/Vagrantfile ]; then
            vagrant_box="${service_name}_${service_version}.box"
            vagrant_box_path="images/vagrant/$vagrant_box"

            if [ ! -f $LOCAL_STORE_DIR/$vagrant_box_path ]; then
                inf "Packaging the box to local store"
                (cd $service_dir && vagrant package --output $LOCAL_STORE_DIR/$vagrant_box_path)
            fi

            if [ $(aws s3 ls s3://$STORE_BUCKET_NAME/$vagrant_box_path | wc -l) == 1 ]; then
                inf "$vagrant_box box already exists."
                while true; do
                    read -p "Do you want to override it? (y/n)" yn
                    case $yn in
                        [Yy]* ) break;;
                        [Nn]* ) exit 0;;
                        * ) echo "Please answer yes or no.";;
                    esac
                done
            fi

            inf "Copy $vagrant_box to remote store"
            aws s3 cp $LOCAL_STORE_DIR/$vagrant_box_path s3://$STORE_BUCKET_NAME/$vagrant_box_path

        elif [ -f $service_dir/Dockerfile ]; then
            image_tag=$service_version
            docker_image="${service_name}_${image_tag}.tar"
            docker_image_path="images/docker/$docker_image"

            if [ ! -f $LOCAL_STORE_DIR/$docker_image_path ]; then
                inf "Commit container changes"
                docker commit $(docker ps -q --filter ancestor=$service_name:latest) $service_name:$service_version
                docker rmi $service_name:latest
                docker tag $service_name:$service_version $service_name:latest

                inf "Packaging the box to local store"
                docker save -o $LOCAL_STORE_DIR/$docker_image_path $service_name:$service_version
            fi

            if [ $(aws s3 ls s3://$STORE_BUCKET_NAME/$docker_image_path | wc -l) == 1 ]; then
                inf "$docker_image image already exists."
                while true; do
                    read -p "Do you want to override it? (y/n)" yn
                    case $yn in
                        [Yy]* ) break;;
                        [Nn]* ) exit 0;;
                        * ) echo "Please answer yes or no.";;
                    esac
                done
            fi

            inf "Copy $docker_image to remote store"
            aws s3 cp $LOCAL_STORE_DIR/$docker_image_path s3://$STORE_BUCKET_NAME/$docker_image_path
        fi

    elif [ $COMMAND == "test" ]; then
        if [[ ${#SERVICES[@]} == 0 ]]; then
            suits="all"
        else
            suits=${SERVICES[0]}
        fi

        if [ $TEST_TYPE == 'vagrant' ]; then
            inf "Run test suite using Vagrant"

	        kitchen_file="$BASE_DIR/.kitchen.yml"
	        local_kitchen_file="$BASE_DIR/.kitchen.vagrant.yml"

		    KITCHEN_YAML=$kitchen_file KITCHEN_LOCAL_YAML=$local_kitchen_file kitchen test $suits -c $CONCURENCY
		    KITCHEN_YAML=$kitchen_file KITCHEN_LOCAL_YAML=$local_kitchen_file kitchen destroy $suits


        elif [ $TEST_TYPE == 'aws' ]; then
            warn "Not available"
        fi

    elif [ $COMMAND == "backup" ]; then
        # Run only against datastore resources
        # Get playbooks tasks by using tags which will do backing up
        inf "Run  backup"
    fi
}

[[ "$0" == "$BASH_SOURCE" ]] && main

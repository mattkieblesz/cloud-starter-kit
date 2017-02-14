#!/bin/bash

readonly SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
readonly BASE_DIR=$( cd $SCRIPT_DIR/.. && pwd )

readonly AWS_CONFIG_DIR="$HOME/.aws"
readonly AWS_CONFIG_FILE="$AWS_CONFIG_DIR/config"

readonly STORE_BUCKET_NAME=$( cd $BASE_DIR && basename $(pwd) )

source "$SCRIPT_DIR/utils.sh"

main() {
    # Be unforgiving about errors
    set -euo pipefail

    inf "--> Touch Ansible-Vault pass"
    touch conf/vpass

    inf "--> Setup AWS credentials"
    mkdir -p $AWS_CONFIG_DIR
    if [ ! -f $AWS_CONFIG_FILE ]; then
        ln -s $BASE_DIR/conf/aws-config $AWS_CONFIG_FILE
    fi

    inf "--> Creating local store dirs"
    for dir in envs/*/;  # list all dirs in envs directory
    do
        dir=${dir%/}  # strip trailing slash
        env_name="${dir#envs/}" # strip leading prefix

        mkdir -p store/$env_name/images store/$env_name/backups  # create local store dirs
    done

    inf "--> Creating remote store s3 bucket"
    /usr/local/bin/aws s3 mb s3://$STORE_BUCKET_NAME
    inf "--> Sync everything which is in the local store with remote"
    /usr/local/bin/aws s3 cp $BASE_DIR/store/ s3://$STORE_BUCKET_NAME/ --recursive --exclude "README.md"
}

[[ "$0" == "$BASH_SOURCE" ]] && main

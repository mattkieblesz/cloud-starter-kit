#!/bin/bash

readonly SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )
readonly BASE_DIR=$( cd $SCRIPT_DIR/.. && pwd )

readonly WORKSPACE_DIR="$HOME/Projects"
readonly AWS_CONFIG_DIR="$HOME/.aws"
readonly AWS_CONFIG_FILE_LINK="$AWS_CONFIG_DIR/config"
readonly ANSIBLE_CONFIG_FILE_LINK="$HOME/.ansible.cfg"
readonly ANSIBLE_VAULT_PASS_FILE_LINK="$HOME/vpass"

readonly STORE_BUCKET_NAME=$( cd $BASE_DIR && basename $(pwd) )

source "$SCRIPT_DIR/utils.sh"

main() {
    # Be unforgiving about errors
    set -euo pipefail

    inf "--> Touch Ansible-Vault pass"
    touch conf/vpass

    inf "--> Setup workspace dit"
    mkdir -p $WORKSPACE_DIR

    inf "--> Setup AWS credentials"
    mkdir -p $AWS_CONFIG_DIR
    if [ ! -f $AWS_CONFIG_FILE_LINK ]; then
        ln -s $BASE_DIR/conf/aws-config $AWS_CONFIG_FILE_LINK
    fi

    inf "--> Setup Ansible config"
    # if [ ! -f $ANSIBLE_CONFIG_FILE_LINK ]; then
    #     ln -s $BASE_DIR/conf/ansible.cfg $ANSIBLE_CONFIG_FILE_LINK
    # fi
    if [ ! -f $ANSIBLE_VAULT_PASS_FILE_LINK ]; then
        ln -s $BASE_DIR/conf/vpass $ANSIBLE_VAULT_PASS_FILE_LINK
    fi

    inf "--> Creating remote store s3 bucket"
    # /usr/local/bin/aws s3 mb s3://$STORE_BUCKET_NAME

    for dir in envs/*/;  # list all dirs in envs directory
    do
        dir=${dir%/}  # strip trailing slash
        env_name="${dir#envs/}" # strip leading prefix
        env_dir="$BASE_DIR/envs/$env_name"
        store_dir="$env_dir/store"
        configure_playbook="$env_dir/configure.yml"

        inf "--> Configure $env_name store"

        # create local store dirs
        mkdir -p $store_dir/images $store_dir/backups $store_dir/services

        # run configuration playbook if present
        if [ -f $configure_playbook ]; then
            ANSIBLE_CONFIG=$BASE_DIR/conf/ansible.cfg ansible-playbook $configure_playbook --extra-vars="env_name=$env_name"
        fi

        # sync store to remote
        /usr/local/bin/aws s3 cp $store_dir s3://$STORE_BUCKET_NAME/$env_name --recursive --exclude '*/.vagrant/*'
    done

}

[[ "$0" == "$BASH_SOURCE" ]] && main

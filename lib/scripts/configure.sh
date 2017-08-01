#!/bin/bash

readonly SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
readonly BASE_DIR=$( cd $SCRIPT_DIR/.. && pwd )

readonly WORKSPACE_DIR="$BASE_DIR/workspace"
readonly SECRETS_DIR="$BASE_DIR/conf/secrets"

readonly AWS_GLOBAL_CONFIG_DIR="$HOME/.aws"
readonly AWS_GLOBAL_CONFIG_FILE_LINK="$AWS_GLOBAL_CONFIG_DIR/config"
readonly AWS_PUBKEY_FILE="$SECRETS_DIR/aws_pubkey.pem"
readonly AWS_PRIVKEY_FILE="$SECRETS_DIR/aws_privkey.pem"
readonly AWS_PACKER_CREDENTIALS_FILE="$SECRETS_DIR/credentials.json"
readonly ANSIBLE_VAULT_PASS_FILE="$SECRETS_DIR/vpass"

readonly PROJECT_NAME=$( cd $BASE_DIR && basename $(pwd) )
readonly STORE_BUCKET_NAME=$PROJECT_NAME
readonly LOCAL_ENV="local"

source "$SCRIPT_DIR/utils.sh"

main() {
    # Be unforgiving about errors
    set -euo pipefail

    inf "--> Setup workspace and secrets dirs"
    mkdir -p $WORKSPACE_DIR $SECRETS_DIR

    inf "--> Setup AWS access keys"
    mkdir -p $AWS_GLOBAL_CONFIG_DIR
    if [ ! -f $AWS_GLOBAL_CONFIG_FILE_LINK ]; then
        ln -s $SECRETS_DIR/aws-config $AWS_GLOBAL_CONFIG_FILE_LINK
    fi

    inf "--> Setup packer credentials for aws"
    if [ ! -f $AWS_PACKER_CREDENTIALS_FILE ]; then
        aws_access_key_id=$(grep "^aws_access_key_id=" $SECRETS_DIR/aws-config | cut -d= -f2)
        aws_secret_access_key=$(grep "^aws_secret_access_key=" $SECRETS_DIR/aws-config | cut -d= -f2)
        cat > $AWS_PACKER_CREDENTIALS_FILE <<EOL
{
    "aws_access_key_id": "$aws_access_key_id",
    "aws_secret_access_key": "$aws_secret_access_key"
}
EOL
    fi

    inf "--> Info about AWS credentials if not present"
    if [[ ! -f $AWS_PUBKEY_FILE || ! -f $AWS_PRIVKEY_FILE ]]; then
        warn "--> You must create and download x.509 cert from AWS into secrets directory"
    fi

    inf "--> Touch Ansible-Vault pass"
    echo 'thisisvpass' > $ANSIBLE_VAULT_PASS_FILE

    inf "--> Creating remote store s3 bucket if doesn't exist already"
    if [ $( aws s3 ls | grep $STORE_BUCKET_NAME | wc -l ) == 0 ]; then
        aws s3 mb s3://$STORE_BUCKET_NAME
    fi

    for dir in envs/*/;  # list all dirs in envs directory
    do
        dir=${dir%/}  # strip trailing slash
        env_name="${dir#envs/}" # strip leading prefix
        env_dir="$BASE_DIR/envs/$env_name"
        store_dir="$env_dir/store"

        inf "--> Configure $env_name store"

        # create local store dirs
        mkdir -p $store_dir/backups
    done

    inf "--> Create local environments store dirs"
    mkdir -p $BASE_DIR/envs/local/store/images/vagrant \
             $BASE_DIR/envs/local/store/images/docker \
             $BASE_DIR/envs/local/store/images/amazon
}

[[ "$0" == "$BASH_SOURCE" ]] && main

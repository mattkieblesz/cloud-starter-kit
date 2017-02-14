#!/bin/bash

readonly SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
readonly INSTALL_DIR="/usr/local/bin"
readonly DOWNLOAD_DIR="/tmp"

readonly TERRAFORM_VERSION="0.8.6"
readonly TERRAFORM_DOWNLOAD_URL="https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
readonly PACKER_VERSION="0.12.2"
readonly PACKER_DOWNLOAD_URL="https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip"

source "$SCRIPT_DIR/utils.sh"

prerequisites() {
    local curl_cmd=`which curl`
    local unzip_cmd=`which unzip`
    local python_cmd=`which python`
    local pip_cmd=`which pip`
    local system=$(uname)

    if [ -z "$curl_cmd" ]; then
        error "curl does not appear to be installed. Please install and re-run this script."
        exit 1
    fi

    if [ -z "$unzip_cmd" ]; then
        error "unzip does not appear to be installed. Please install and re-run this script."
        exit 1
    fi

    if [ -z "$python_cmd" ]; then
        error "python does not appear to be installed. Please install and re-run this script."
        exit 1
    fi

    if [ -z "$pip_cmd" ]; then
        error "pip does not appear to be installed. Please install and re-run this script."
        exit 1
    fi

    distro_warn_message="Tested only on Ubuntu 14.04"
    if [ "$system" == "Linux" ]; then
        distro=$(lsb_release -i)
        if ! ([[ $distro == *"Ubuntu"* ]] || [[ $distro == *"Debian"* ]]) ;then
            warn "$distro_warn_message"
        fi
    else
        warn "$distro_warn_message"
    fi

    if [ "$EUID" -ne 0 ]; then
        error "Please run as root"
        exit 1
    fi
}

install_binary() {
    inf "--> Downloading $1 binary"
    curl -o "$1" "$2"

    inf "--> Extracting executable"
    unzip "$1" -d "$INSTALL_DIR"

    rm "$1"
}

main() {
    # Be unforgiving about errors
    set -euo pipefail

    prerequisites

    inf "--> Installing core requirements"
    apt-get install build-essential python-dev python-pip python3-pip

    inf "--> Installing Terraform"
    install_binary "$DOWNLOAD_DIR/terraform.zip" $TERRAFORM_DOWNLOAD_URL

    inf "--> Installing Packer"
    install_binary "$DOWNLOAD_DIR/packer.zip" $PACKER_DOWNLOAD_URL

    inf "--> Installing Ansible"
    pip install ansible==2.2.1  # use python2.7 since ansible doesn't support 3 yet

    inf "--> Installing awscli"
    # ignore six if installed https://github.com/aws/aws-cli/issues/1522#issuecomment-159007931
    sudo -H pip install awscli==1.11.47 --upgrade --ignore-installed six
}

[[ "$0" == "$BASH_SOURCE" ]] && main

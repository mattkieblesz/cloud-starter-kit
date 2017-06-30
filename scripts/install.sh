#!/bin/bash

readonly SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
readonly INSTALL_DIR="/usr/local/bin"
readonly DOWNLOAD_DIR="/tmp"

readonly TERRAFORM_VERSION="0.9.10"
readonly TERRAFORM_DOWNLOAD_URL="https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
readonly PACKER_VERSION="1.0.2"
readonly PACKER_DOWNLOAD_URL="https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip"
readonly VAGRANT_VERSION="1.9.6"
readonly VAGRANT_DOWNLOAD_URL="https://releases.hashicorp.com/vagrant/${VAGRANT_VERSION}/vagrant_${VAGRANT_VERSION}_x86_64.deb"
readonly DOCKER_DOWLOAD_URL="https://apt.dockerproject.org/repo/pool/main/d/docker-engine/docker-engine_17.05.0~ce-0~ubuntu-xenial_amd64.deb"

source "$SCRIPT_DIR/utils.sh"

prerequisites() {
    local curl_cmd=`which curl`
    local unzip_cmd=`which unzip`
    local python_cmd=`which python`
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

install_deb() {
    inf "--> Downloading $1 deb package"
    curl -o "$1" "$2"

    inf "--> Installing deb package"
    dpkg -i "$1"

    rm "$1"
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
    apt-get update
    apt-get install build-essential python-dev python-pip python3-pip libssl-dev

    inf "--> Installing Terraform"
    install_binary "$DOWNLOAD_DIR/terraform.zip" $TERRAFORM_DOWNLOAD_URL

    inf "--> Installing Packer"
    install_binary "$DOWNLOAD_DIR/packer.zip" $PACKER_DOWNLOAD_URL

    inf "--> Installing Ansible"
    pip install ansible==2.3.1  # use python2.7 since ansible doesn't support 3 yet

    inf "--> Installing awscli"
    # ignore six if installed https://github.com/aws/aws-cli/issues/1522#issuecomment-159007931
    pip install awscli==1.11.114 --upgrade --ignore-installed six

    inf "--> Installing Docker"
    # https://docs.docker.com/engine/installation/linux/ubuntu/#install-from-a-package
    apt-get install --no-install-recommends linux-image-extra-$(uname -r) linux-image-extra-virtual
    install_deb "$DOWNLOAD_DIR/docker.deb" $DOCKER_DOWLOAD_URL

    inf "--> Enable Docker to be run by current user"
    # # https://docs.docker.com/engine/installation/linux/linux-postinstall/
    getent group docker || groupadd docker
    usermod -aG docker $USER

    inf "--> Installing Vagrant"
    install_deb "$DOWNLOAD_DIR/vagrant.deb" $VAGRANT_DOWNLOAD_URL
}

[[ "$0" == "$BASH_SOURCE" ]] && main

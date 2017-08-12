import click
import os

from lib import settings as s
from lib.utils import log, bash

GLOBAL_INSTALL_DIR = os.path.join('/', 'usr', 'local', 'bin')


def install_binary(name, download_url):
    binary_file_path = os.path.join(s.TMP_DIR, name)

    log.info('Downloading %s binary' % name)
    bash('curl -o %s %s' % (binary_file_path, download_url))

    log.info('Extracting executable')
    bash('unzip -o %s -d %s' % (binary_file_path, GLOBAL_INSTALL_DIR), sudo=True)

    os.remove(binary_file_path)


def install_deb(name, download_url):
    deb_file_path = os.path.join(s.TMP_DIR, name)

    log.info('Downloading %s deb package' % name)
    bash('curl -o %s %s' % (deb_file_path, download_url))

    log.info('Installing deb package')
    bash('dpkg -i %s' % deb_file_path, sudo=True)

    os.remove(deb_file_path)


@click.group()
def setup():
    '''Repo installation commands.'''
    pass


@setup.command()
def install():
    log.info('Installing core requirements')
    bash('apt-get update && apt-get install build-essential python-dev python-pip python3-pip libssl-dev sshpass', sudo=True)

    log.info('Installing Terraform')
    install_binary('terraform.zip', s.TERRAFORM_DOWNLOAD_URL)

    log.info('Installing Packer')
    install_binary('packer.zip', s.PACKER_DOWNLOAD_URL)

    log.info('Installing Ansible')
    bash('pip install ansible==%s' % s.ANSIBLE_VERSION)  # use python2.7 since ansible doesn't support 3 yet

    log.info('Installing awscli')
    # ignore six if installed https://github.com/aws/aws-cli/issues/1522#issuecomment-159007931
    bash('pip install awscli==%s --upgrade --ignore-installed six' % s.AWSCLI_VERSION, sudo=True)

    log.info('Installing Docker')
    # https://docs.docker.com/engine/installation/linux/ubuntu/#install-from-a-package
    kernel_release = bash('uname -r')
    bash('apt-get install --no-install-recommends linux-image-extra-%s linux-image-extra-virtual' % kernel_release, sudo=True)
    install_deb('docker.deb', s.DOCKER_DOWLOAD_URL)

    log.info('Enable Docker to be run by current user')
    # https://docs.docker.com/engine/installation/linux/linux-postinstall/
    bash('getent group docker || groupadd docker', sudo=True)
    bash('usermod -aG docker $USER', sudo=True)

    log.info('Installing Chef DK')
    install_deb('chefdk.deb', s.CHEFDK_DOWNLOAD_URL)
    bash('gem install kitchen-ansible')
    bash('gem install kitchen-vagrant')

    log.info('Installing Vagrant')
    install_deb('vagrant.deb', s.VAGRANT_DOWNLOAD_URL)

    log.info('Installing Vagrant plugins')
    bash('vagrant plugin install vagrant-hostsupdater')

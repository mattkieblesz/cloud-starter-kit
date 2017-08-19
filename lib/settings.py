import os

# all provider secrets
from .local_settings import *  # NOQA


PROJECT_NAME = 'mkitdevelopment-cloud'
PROJECT_ROOT = os.path.normpath(os.path.join(os.path.dirname(__file__), os.pardir))  # NOQA

#################
# General setup #
#################
SCRIPTS_DIR = os.path.join(PROJECT_ROOT, 'lib', 'scripts')
SECRETS_DIR = os.path.join(PROJECT_ROOT, 'secrets')

MANAGED_MESSAGE = 'Manged by %s setup scripts' % PROJECT_NAME
REMOTE_STORE_BUCKET = 'something-unique-xales'

SERVICES = [
    'webapp',
    'database'
]

###################
# Providers setup #
###################
PROVIDERS_DIR = os.path.join(PROJECT_ROOT, 'cloud', 'providers')
# cloud/providers/<provider>/envs/<region>/<env>/<vars.yml|secrets.yml>
PROVIDERS = {
    'aws': {
        'provisioner': 'ansible',
        'regions': {
            'eu-west-2': {
                'profile': 'default',
                'envs': {
                    'dev': {
                        'provisioner': 'ansible',
                        'services': ['webapp', 'database']
                    },
                    'stg': {
                        'provisioner': 'ansible',
                        'services': ['webapp', 'database']
                    },
                    'prd': {
                        'provisioner': 'ansible',
                        'services': ['webapp', 'database']
                    },
                    'mgt': {
                        'provisioner': 'ansible',
                        'services': ['gocdserver', 'jenkins', 'gitlab']
                    }
                }
            }
        }
    }
}


################################
# Infrastructure as code setup #
################################


######################
# Provisioners setup #
######################
PROVISIONERS_DIR = os.path.join(PROJECT_ROOT, 'cloud', 'provisioners')

# Ansible
ANSIBLE_DIR = os.path.join(PROVISIONERS_DIR, 'ansible')
ANSIBLE_VENDOR_ROLES = [
    # (src, version, name)
    ('git+https://github.com/mkitdevelopment/ansible-users.git', 'v0.0.3', 'ansible-users'),
    ('git+https://github.com/mkitdevelopment/ansible-python.git', 'v0.0.1', 'ansible-python'),
    ('git+https://github.com/mkitdevelopment/ansible-nginx.git', 'v0.0.2', 'ansible-nginx'),
    ('git+https://github.com/ANXS/postgresql.git', 'v1.9.0', 'ansible-postgresql'),
    ('git+https://github.com/mkitdevelopment/sphinx.git', 'v0.0.1', 'ansible-sphinx'),
    ('git+https://github.com/geerlingguy/ansible-role-mysql.git', '2.8.0', 'ansible-mysql'),
    ('git+https://github.com/Oefenweb/ansible-haproxy', 'v4.5.1', 'ansible-haproxy')
]

# Puppet
# ...

# Chef
# ...


###################
# Workspace setup #
###################
WORKSPACE_DIR = os.path.join(PROJECT_ROOT, 'workspace')
MACHINES_DIR = os.path.join(WORKSPACE_DIR, 'machines')
REPOS_DIR = os.path.join(WORKSPACE_DIR, 'repos')
LOCAL_STORE_DIR = os.path.join(WORKSPACE_DIR, 'store')
TMP_DIR = os.path.join(WORKSPACE_DIR, 'tmp')

WORKSPACE_REPOS = {
    'webapp': 'git@gitlab.com:mattkieblesz/mkitdevelopment.git'
}

# Local docker setup
DOCKER_LOCAL_NETWORK_SUBNET = '192.168.20.0/24'
DOCKER_NETWORK_NAME = PROJECT_NAME

WORKSPACE_MACHINES = [
    {
        'name': 'database',
        'services': ['database'],
        'url': 'database.app.internal',
        'ip': '192.168.20.10',
        'image': 'rastasheep/ubuntu-sshd:14.04',
        'network': DOCKER_NETWORK_NAME,
        'ports': [
            {'guest': 5432},
            {'guest': 22},
        ],
        'type': 'docker'
    },
    {
        'name': 'search',
        'services': ['search'],
        'url': 'search.app.internal',
        'ip': '192.168.20.20',
        'image': 'rastasheep/ubuntu-sshd:14.04',
        'network': DOCKER_NETWORK_NAME,
        'ports': [
            {'guest': 9312},
            {'guest': 9306},
            {'guest': 3306},
            {'guest': 22}
        ],
        'type': 'docker'
    },
    {
        'name': 'webapp',
        'services': ['webapp'],
        'url': 'webapp.app.internal',
        'ip': '192.168.10.10',
        'image': 'ubuntu/trusty64',
        'ports': [
            {'guest': 80},
        ],
        'type': 'vagrant'
    }
]


#########
# Tools #
#########
TERRAFORM_VERSION = '0.10.0'
TERRAFORM_DOWNLOAD_URL = 'https://releases.hashicorp.com/terraform/%(version)s/terraform_%(version)s_linux_amd64.zip' % {'version': TERRAFORM_VERSION}
ANSIBLE_VERSION = '2.3.2'
VAGRANT_VERSION = '1.9.7'
VAGRANT_DOWNLOAD_URL = 'https://releases.hashicorp.com/vagrant/%(version)s/vagrant_%(version)s_x86_64.deb' % {'version': VAGRANT_VERSION}
DOCKER_ENGINE_VERSION = '17.05.0'
DOCKER_DOWLOAD_URL = 'https://apt.dockerproject.org/repo/pool/main/d/docker-engine/docker-engine_%(version)s~ce-0~ubuntu-xenial_amd64.deb' % {'version': DOCKER_ENGINE_VERSION}
PACKER_VERSION = '1.0.4'
PACKER_DOWNLOAD_URL = 'https://releases.hashicorp.com/packer/%(version)s/packer_%(version)s_linux_amd64.zip' % {'version': PACKER_VERSION}
CHEFDK_VERSION = '2.1.11'
CHEFDK_DOWNLOAD_URL = 'https://packages.chef.io/files/stable/chefdk/%(version)s/ubuntu/16.04/chefdk_%(version)s-1_amd64.deb' % {'version': CHEFDK_VERSION}
AWSCLI_VERSION = '1.11.133'

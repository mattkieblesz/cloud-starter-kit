import os

# all provider secrets
from .local_settings import *  # NOQA


PROJECT_NAME = 'mkitdevelopment-cloud'
PROJECT_ROOT = os.path.normpath(os.path.join(os.path.dirname(__file__), os.pardir))  # NOQA

# Components paths
ENVS_DIR = os.path.join(PROJECT_ROOT, 'cloud', 'envs')
ANSIBLE_DIR = os.path.join(PROJECT_ROOT, 'cloud', 'ansible')
SECRETS_DIR = os.path.join(PROJECT_ROOT, 'cloud', 'files', 'secrets')
SCRIPTS_DIR = os.path.join(PROJECT_ROOT, 'lib', 'scripts')

WORKSPACE_DIR = os.path.join(PROJECT_ROOT, 'workspace')
MACHINES_DIR = os.path.join(WORKSPACE_DIR, 'machines')
REPOS_DIR = os.path.join(WORKSPACE_DIR, 'repos')
LOCAL_STORE_DIR = os.path.join(WORKSPACE_DIR, 'store')
TMP_DIR = os.path.join(WORKSPACE_DIR, 'tmp')

# Envs setup
ENVS = {
    'dev': {
        'provider': 'ovh',
        'provisioner': 'ansible',
        'services': ['webapp', 'database']
    },
    'stg': {
        'provider': 'aws',
        'profile': 'default',
        'provisioner': 'ansible',
        'services': ['webapp', 'database']
    },
    'prd': {
        'provider': 'aws',
        'profile': 'default',
        'provisioner': 'ansible',
        'services': ['webapp', 'database']
    },
    'mgt': {
        'provider': 'aws',
        'profile': 'default',
        'provisioner': 'ansible',
        'services': ['gocdserver', 'jenkins', 'gitlab']
    }
}

# All machines
MACHINES = [
    'webapp',
    'database'
]

# LOCAL SETUP
WORKSPACE_REPOS = {
    'webapp': 'git@gitlab.com:mattkieblesz/mkitdevelopment.git'
}
# machine can have a repo but it might not be relevant for local development
# seperate setting
WORKSPACE_MACHINES = [
    {
        'name': 'database',
        'url': 'database.app.internal',
        'ip': '192.168.20.10',
        'image': 'rastasheep/ubuntu-sshd:14.04',
        'network': 'cloud-starter-kit',
        'ports': [
            {'guest': 5432},
            {'guest': 22},
        ],
        'type': 'docker'
    },
    {
        'name': 'webapp',
        'url': 'webapp.app.internal',
        'ip': '192.168.10.10',
        'image': 'ubuntu/trusty64',
        'ports': [
            {'guest': 80},
        ],
        'type': 'vagrant'
    }
]
MANAGED_MESSAGE = 'Manged by %s setup scripts' % PROJECT_NAME

# Local docker setup
DOCKER_LOCAL_NETWORK_SUBNET = '192.168.20.0/24'

# Remote store setup
REMOTE_STORE_BUCKET_NAME = 'something-unique-xales'

# Ansible setup
ANSIBLE_VENDOR_ROLES = [
    # (src, version, name)
    ('git+https://github.com/mkitdevelopment/ansible-users.git', 'v0.0.3', 'ansible-users'),
    ('git+https://github.com/mkitdevelopment/ansible-python.git', 'v0.0.1', 'ansible-python'),
    ('git+https://github.com/mkitdevelopment/ansible-nginx.git', 'v0.0.2', 'ansible-nginx'),
    ('git+https://github.com/ANXS/postgresql.git', 'v1.9.0', 'ansible-postgresql'),
    ('git+https://github.com/Oefenweb/ansible-haproxy', 'v4.5.1', 'ansible-haproxy')
]

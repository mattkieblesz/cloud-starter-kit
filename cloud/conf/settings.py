import os

# all provider secrets
from .providers import *  # NOQA


PROJECT_NAME = 'mkitdevelopment-cloud'
PROJECT_ROOT = os.path.normpath(os.path.join(os.path.dirname(__file__), os.pardir))  # NOQA

# Conf setup
SECRETS_DIR = os.path.join(PROJECT_ROOT, 'conf', 'secrets')

# Components paths
ENVS_DIR = os.path.join(PROJECT_ROOT, 'cloud', 'envs')
ANSIBLE_DIR = os.path.join(PROJECT_ROOT, 'cloud', 'ansible')
MACHINES_DIR = os.path.join(PROJECT_ROOT, 'workspace', 'machines')
WORKSPACE_DIR = os.path.join(PROJECT_ROOT, 'workspace', 'repos')
LOCAL_STORE_DIR = os.path.join(PROJECT_ROOT, 'workspace', 'store')
TMP_DIR = os.path.join(PROJECT_ROOT, 'workspace', 'tmp')

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

# Local setup
REPOS = [
    'git@gitlab.com:mattkieblesz/mkitdevelopment.git'
    # 'git@gitlab.com:mattkieblesz/django-starter-kit.git'
]

# Remote store setup
REMOTE_STORE_BUCKET_NAME = 'something-unique-xales'

# Ansible setup
ANSIBLE_VENDOR_ROLES = [
    # (src, version, name)
    ('git+https://github.com/mkitdevelopment/ansible-users.git', 'v0.0.3', 'ansible-users'),
    ('git+https://github.com/mkitdevelopment/ansible-python.git', 'v0.0.1', 'ansible-python'),
    ('git+https://github.com/mkitdevelopment/ansible-nginx.git', 'v0.0.2', 'ansible-nginx'),
    ('git+https://github.com/ANXS/postgresql.git', 'v1.7.1', 'ansible-postgresql'),
    ('git+https://github.com/Oefenweb/ansible-haproxy', 'v4.5.1', 'ansible-haproxy')
]

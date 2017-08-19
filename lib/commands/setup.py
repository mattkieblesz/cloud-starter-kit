import click
import os

from lib import settings as s
from lib.utils import bash, template, log

AWS_GLOBAL_CONFIG_DIR = os.path.join(os.path.expanduser('~'), '.aws')
AWS_GLOBAL_CONFIG_LINK = os.path.join(AWS_GLOBAL_CONFIG_DIR, 'config')
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


@setup.command()
def provider_access():
    if not os.path.exists(s.SECRETS_DIR):
        os.makedirs(s.SECRETS_DIR)

    log.info('Setup AWS secrets')

    aws_config_path = os.path.join(s.SECRETS_DIR, 'aws-config')
    template(
        'aws_config.j2',
        aws_config_path,
        template_vars={'aws_profiles': s.AWS_PROFILES.items()}
    )

    log.info('Link AWS secrets to directory used by awscli')
    if not os.path.exists(AWS_GLOBAL_CONFIG_DIR):
        os.makedirs(s.SECRETS_DIR)

    if os.path.exists(AWS_GLOBAL_CONFIG_LINK):
        os.remove(AWS_GLOBAL_CONFIG_LINK)

    os.symlink(aws_config_path, AWS_GLOBAL_CONFIG_LINK)

    log.info('Create file with ansible Vault pass')
    with open(os.path.join(s.SECRETS_DIR, 'vault-pass'), 'w') as f:
        f.write(s.VAULT_PASS)

    log.info('Create Packer credentials file for aws')
    template(
        'packer_credentials.json.j2',
        os.path.join(s.SECRETS_DIR, 'packer_credentials.json'),
        template_vars={
            'id': s.AWS_PROFILES['default']['id'],
            'key': s.AWS_PROFILES['default']['key']
        }
    )


@setup.command()
def remote_store():
    if bash('aws s3 ls | grep %s' % s.REMOTE_STORE_BUCKET).strip() == '':
        bash('aws s3 mb s3://%s' % s.REMOTE_STORE_BUCKET)
    pass


@setup.command()
def develop():
    log.info('Setup workspace repositories')

    if not os.path.exists(s.REPOS_DIR):
        os.makedirs(s.REPOS_DIR)

    for name, src in s.WORKSPACE_REPOS.items():
        repo_dir = os.path.join(s.REPOS_DIR, name)

        if not os.path.isdir(repo_dir):
            bash('git clone %s %s' % (src, repo_dir))
        else:
            log.info('%s repo already exists. Skipping' % name)

    log.info('Setup workspace machines')

    for conf in s.WORKSPACE_MACHINES:
        name = conf['name']
        machine_dir = os.path.join(s.WORKSPACE_DIR, 'machines', name)

        if name in s.WORKSPACE_REPOS:
            conf['repo_dir'] = os.path.join(s.REPOS_DIR, name)

        if not os.path.exists(machine_dir):
            os.makedirs(machine_dir)

        machine_type = conf.get('type', 'docker')
        if machine_type == 'docker':
            template(
                'Dockerfile.j2',
                os.path.join(machine_dir, 'Dockerfile'),
                template_vars=conf
            )
            # copy docker and docker_run
            template(
                'docker_run.sh.j2',
                os.path.join(machine_dir, 'docker_run.sh'),
                template_vars=conf
            )
        elif machine_type == 'vagrant':
            template(
                'Vagrantfile.j2',
                os.path.join(machine_dir, 'Vagrantfile'),
                template_vars=conf
            )

    log.info('Setup local networking')
    tmp_hosts_file_path = os.path.join(s.TMP_DIR, 'hosts')
    template(
        os.path.join('etc', 'hosts.j2'),
        tmp_hosts_file_path,
        template_vars={'hostname': bash('hostname')}
    )
    bash('cp %s %s' % (tmp_hosts_file_path, os.path.join('/', 'etc', 'hosts')), sudo=True)

    for machine in s.WORKSPACE_MACHINES:
        bash('ssh-keygen -f "~/.ssh/known_hosts" -R %s' % machine['url'])

    local_env_dir = os.path.join(s.PROVIDERS_DIR, 'local')
    if not os.path.exists(local_env_dir):
        os.makedirs(local_env_dir)

    template(
        'inventory.j2',
        os.path.join(local_env_dir, 'inventory')
    )

    # TODO: move this to environment foundation setup
    log.info('Setup local networking')

    if bash('docker network ls --filter name=%s -q' % s.PROJECT_NAME) == '':
        bash('docker network create --subnet=%s %s' % (s.DOCKER_LOCAL_NETWORK_SUBNET, s.PROJECT_NAME))

    log.info('Setup ansible config')
    template(
        'ansible.cfg.j2',
        os.path.join(s.ANSIBLE_DIR, 'ansible.cfg'),
        template_vars={'ansible_dir': s.ANSIBLE_DIR}
    )


@setup.command()
def ansible_roles():
    vendor_roles_dir = os.path.join(s.ANSIBLE_DIR, 'roles', 'vendor')
    requirements_file = os.path.join(s.TMP_DIR, 'role_requirements.yml')

    if not os.path.isdir(vendor_roles_dir):
        os.makedirs(vendor_roles_dir)

    template(
        'role_requirements.yml.j2',
        requirements_file,
        template_vars={'requirements': s.ANSIBLE_VENDOR_ROLES}
    )

    log.info('Installing Ansible Galaxy roles')
    bash('ansible-galaxy install -r %s -p %s' % (requirements_file, vendor_roles_dir))

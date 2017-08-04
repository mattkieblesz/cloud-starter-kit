import click
import os

from lib import settings as s
from lib.components.environments import LocalEnvironment
from lib.utils import run_script, bash, cd, template, log


@click.group()
def configure():
    pass


@configure.command()
def update_roles():
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
    bash('ansible-galaxy install -r "%s" --force --no-deps -p "%s"' % (requirements_file, vendor_roles_dir))


@configure.command()
def development():
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

    hostname = bash('hostname')
    template(
        'etc/hosts.j2',
        os.path.join('/', 'etc', 'hosts'),
        template_vars={'hostname': hostname}
    )
    for machine in s.WORKSPACE_MACHINES:
        bash('ssh-keygen -f "~/.ssh/known_hosts" -R %s' % machine['url'])

    local_env_dir = os.path.join(s.ENVS_DIR, 'local')
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

import click
import contextlib
import os
import subprocess

from jinja2 import Environment, FileSystemLoader

from lib import settings as s


class Logger:
    def info(self, msg):
        click.secho('--> %s' % msg, fg='green')

    def error(self, msg):
        click.secho('--> %s' % msg, fg='red')

    def warnning(self, msg):
        click.secho('--> %s' % msg, fg='orange')


log = Logger()


@contextlib.contextmanager
def cd(path):
    old_path = os.getcwd()
    os.chdir(path)

    try:
        yield
    finally:
        os.chdir(old_path)


def bash(cmd, sudo=False, user=None):
    if sudo:
        cmd = 'sudo ' + cmd
    process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    output, error = process.communicate()

    return output.split('\n')[0]


def run_script(name, sudo=False):
    with cd(s.SCRIPTS_DIR):
        bash('./%s' % name, sudo=True)


def template(src, dest, template_vars=None, template_dir=None):
    if template_vars is None:
        template_vars = {}
    if not template_dir:
        template_dir = os.path.join(s.PROJECT_ROOT, 'lib', 'templates')

    env = Environment(loader=FileSystemLoader(template_dir))

    template = env.get_template(src)

    extra_vars = {
        'project_name': s.PROJECT_NAME,
        'project_root': s.PROJECT_ROOT,
        'local_store_dir': s.LOCAL_STORE_DIR,
        'workspace_machines': s.WORKSPACE_MACHINES,
        'managed_message': s.MANAGED_MESSAGE
    }
    template_vars.update({
        k: v
        for k, v in extra_vars.items()
        if k not in template_vars
    })

    result = template.render(**template_vars)

    with open(dest, "w") as f:
        f.write(result)

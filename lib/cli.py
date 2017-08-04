import click

from lib.commands import setup
from lib.commands import configure
from lib.commands import provision
from lib.commands import test
from lib.commands import build
from lib.commands import infra


@click.group()
def cli():
    '''Cloud command line tool.'''
    pass


cli.add_command(setup.setup)
cli.add_command(configure.configure)
cli.add_command(provision.provision)
cli.add_command(test.test)
cli.add_command(infra.infra)
cli.add_command(build.build)

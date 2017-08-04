import click

from lib.utils import run_script


@click.group()
def setup():
    '''Repo installation commands.'''
    pass


@setup.command()
def install():
    run_script('install.sh')

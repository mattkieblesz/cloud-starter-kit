import click


@click.group()
def setup():
    '''Repo installation commands.'''
    pass


@setup.command()
def install():
    click.echo('install')


@setup.command()
def configure():
    click.echo('configure')


@setup.command()
def update_roles():
    click.echo('update roles')


@setup.command()
def development():
    click.echo('setup development')

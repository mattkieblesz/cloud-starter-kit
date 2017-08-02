import click


@click.group()
def infra():
    '''Infrastructure management commands.'''
    pass


@infra.command()
def create():
    click.echo('create')


@infra.command()
def destroy():
    click.echo('destroy')


@infra.command()
def start():
    click.echo('start')


@infra.command()
def stop():
    click.echo('stop')

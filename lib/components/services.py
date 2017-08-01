from .base import Component


class BaseService(Component):
    def deploy(self):
        pass

    def provision(self):
        pass

    def setup(self):
        '''Sets up local workspace'''
        pass


class DatastoreService(BaseService):
    def backup(self):
        pass

    def restore_backup(self, backup=None):
        if backup is None:
            backup = "latest"

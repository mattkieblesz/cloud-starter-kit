from .base import Component


class BaseFile(Component):
    pass


class File(BaseFile):
    def push(self):
        pass


class StoreFile(BaseFile):
    store = None

    def pull(self):
        pass

    def transfer_to_store(self):
        pass


class VersionableFile(StoreFile):
    pass

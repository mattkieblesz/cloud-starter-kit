from .base import BaseComponent


class BaseEnvironment(BaseComponent):
    def setup(self):
        pass

    def create(self):
        '''Sets up environment's foundation and services'''
        pass

    def destroy(self):
        '''Destroys environment'''
        pass

    def reload_state(self):
        '''Renders state files locally'''
        pass

    def update_state(self):
        '''Updates local state files'''
        pass


class LocalEnvironment(BaseEnvironment):
    def create(self):
        pass


class RemoteEnvironment(BaseEnvironment):
    provider = None

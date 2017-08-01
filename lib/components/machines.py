from .base import Component


class BaseMachine(Component):
    provider = None


class BareMetalMachine(BaseMachine):
    pass


class VirtualMachine(BaseMachine):
    parent = None


class ContainerMachine(BaseMachine):
    parent = None

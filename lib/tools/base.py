class BaseTool(object):
    def install(self):
        raise NotImplementedError()

    def configure(self):
        raise NotImplementedError()


class CmdTool(BaseTool):
    pass


class ProvisionerTool(CmdTool):

    def roles_update(self):
        raise NotImplementedError()

    def provision(self):
        raise NotImplementedError()


class VmManager(BaseTool):
    pass

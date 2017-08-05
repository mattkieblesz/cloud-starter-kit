class BaseTool(object):
    def install(self):
        raise NotImplementedError()

    def uninstall(self):
        raise NotImplementedError()

    def configure(self):
        raise NotImplementedError()


class CmdTool(BaseTool):
    pass


class ProvisionerTool(CmdTool):

    def provision(self):
        raise NotImplementedError()


class VmManager(BaseTool):
    pass

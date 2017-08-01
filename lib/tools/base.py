import subprocess


class BaseTool(object):
    def install(self):
        raise NotImplementedError()

    def configure(self):
        raise NotImplementedError()

    def bash(self, cmd):
        # run from: host & dir
        # run as user
        print subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE).stdout.read()


class CmdTool(BaseTool):
    pass


class ProvisionerTool(CmdTool):

    def roles_update(self):
        raise NotImplementedError()

    def provision(self):
        raise NotImplementedError()


class VmManager(BaseTool):
    pass

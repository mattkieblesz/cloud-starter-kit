from lib import settings as s

from .base import ProvisionerTool


class AnsibleProvisioner(ProvisionerTool):
    def provision(self, env='local', services=None):
        if not services:
            services = s.SERVICES

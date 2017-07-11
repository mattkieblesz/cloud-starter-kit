## Installation

You need to setup your remote store for all current configuration/management purposes. For this we use s3 bucket so you
need to update your global aws credentials and config file (located in `conf` directory). Also update `conf/services.yml` file which will be used to setup local environment. Then run `make configure`
to link files.

Then just run `sudo make setup` to install all requirements and update vendor roles with `make update-roles`. Done.


## Layout

    .gitignore (exclude all secrets/images/resource state)
    Makefile                    # Management interface

    conf/                       # all confs in one place
      ansible.cfg               # global ansible config
      aws-config                # secret variables excluded from git
      aws-config-template       # aws config template
      vpass                     # ansible vault password file which is excluded from git

    files/                      # Files to share for all envs
      ssh_keys/                 # list of ssh keys
        id_username.pub

    plays/
      dev_setup.yml             # setup local development environment
      play1.yml                 # playbooks should have just services roles dependencies
      play2.yml                 # --||--
      performancetestplay.yml   # --||--
      jenkinsplay.yml           # --||--
      gocdplay.yml              # --||--
      testplay.yml              # --||--
      dataplay.yml              # --||--

    roles/
      services/                 # All the roles that are specific to a service
        role1/
          rolestuff
        role2/
          rolestuff
        role3/
          rolestuff
        role4/
          rolestuff
        role5/
          rolestuff
        role6/
          rolestuff
        role7/
          rolestuff
        role8/
          rolestuff
        role9/
          rolestuff
        role10/
          rolestuff
      support/                  # All other roles
        dev_setup/              # Sets up local development environment
          rolestuff
      vendor/                   # All the roles that are in git or ansible galaxy (excluded from git)
        role11/
          rolestuff
        role12/
          rolestuff

    envs/                       # Main entry point to infrastructure setup
      local/
        vars.yml
        secrets-plain.yml
        secrets.yml
      dev/
        store/                  # local storage directory which has same structure as remote store (s3 bucket)
          backups/              # backups/snapshots etc.
          images/               # all playbook images are stored in this folder
          state.tfstate         # current terraform state in prd environment
          inventory.ini         # current ansible inventory file for prd environment
        vars.yml                # File with all vars to services
        secrets-plain.yml       # Secret file template (not used)
        secrets.yml             # One file with secrets for environment
        terraform.tf            # Environment infra as code setup
      stg
        ...
        terraform.tf            # Linked from prd environment (will be used with different vars)
      prd
        ...
      mgt
        ...
      tst
        ...
      prf
        ...

    scripts/                    # utility scripts used by Makefile targets

    workspace/                  # all repos which are developed and used in the cloud will be cloned here
      webapp/                   # webbapp repo
      proxy/                    # proxy repo
      ...

## Resource naming convention

In order to simplify life we assume one resource provider account will be used. Therefore there needs to be naming
which will include:
- environment
- location
- role
- resource number

Examples: `prd-lo-web-1`, `dev-ir-db-1`, `prf-fr-db-1`, `stg-lo-celery-3`, `mgt-lo-ci-1`

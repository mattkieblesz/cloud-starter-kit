## Installation

You need to setup your remote store for all current configuration/management purposes. For this we use s3 bucket so you
need to update your global aws credentials and config file (located in `conf` directory). Then run `make configure`
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

    group_vars/                 # for default role setup
      all/                      # variables under this directory belongs all the groups
        role1.yml               # role1 variable file for all groups
        role2.yml               # role2 variable file for all groups
      play1/                    # here we assign variables to play1 groups
        role1.yml               # Each file will correspond to a role i.e. role1.yml
        role2.yml               # --||--
      play2/                    # here we assign variables to play2 groups
        role3.yml               # Each file will correspond to a role i.e. role3.yml
        role4.yml               # --||--
      testplay/                 # here we assign variables to testplay groups
        role5.yml               # Each file will correspond to a role i.e. role5.yml
        role6.yml               # --||--
      performancetestplay/      # here we assign variables to performancetestplay groups
        role7.yml               # Each file will correspond to a role i.e. role7.yml
        role8.yml               # --||--
      jenkinsplay/              # here we assign variables to jenkinsplay groups
        role9.yml               # Each file will correspond to a role i.e. role9.yml
        role10.yml              # --||--
      gocdplay/                 # here we assign variables to gocdplay groups
        role11.yml              # Each file will correspond to a role i.e. role11.yml
        role12.yml              # --||--

    plays/
      play1.yml                 # playbooks should have just services roles dependencies
      play2.yml                 # --||--
      performancetestplay.yml   # --||--
      jenkinsplay.yml           # --||--
      gocdplay.yml              # --||--
      testplay.yml              # --||--

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
      js_roles/                 # All the roles that common to different roles
        commonrole1/
          rolestuff
      vendor/                   # All the roles that are in git or ansible galaxy (excluded from git)
        role11/
          rolestuff
        role12/
          rolestuff
      requirements.yml          # All the information about external roles

    envs/                       # Main entry point to infrastructure setup
      dev/
        vars/                   # Folder with vars specific to environment (simple flat file structure)
          all.yml
          play1.yml
          play2.yml
          secret-plain.yml      # Secret file template (not used)
          secrets.yml           # One file with secrets for environment
        inventory.ini           # Dynamic inventory file which includes location
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
      setup.sh                  # setup devops script
      update_roles.sh           # update vendor roles
      create_role.sh            # create new common/service role
      create_env.sh             # create new environment

    store/                      # local storage directory which has same structure as remote store (s3 bucket)
      dev/backups/              # backups/snapshots etc.
      dev/images/               # all playbook images are stored in this folder
      dev/terraform.tfstate     # current terraform state in prd environment
      dev/inventory.ini         # current ansible inventory file for prd environment
      stg/                      # ...
      prd/                      # ...

    templates/                  # templates used in this repo
      Vagrant.j2                # vagrant template used for this environment


## Resource naming convention

In order to simplify life we assume one resource provider account will be used. Therefore there needs to be naming
which will include:
- environment
- location
- role
- resource number

Examples: `prd-lo-web-1`, `dev-ir-db-1`, `prf-fr-db-1`, `stg-lo-celery-3`, `mgt-lo-ci-1`

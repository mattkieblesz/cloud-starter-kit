- transform cloud-starter-kit to `cloud` program
    - lib/ under which put all commands which will use different tools like provisioners as classes
    - scripts/
    - repo/
        - commands/
            install.py (installs `cloud` program first and then calls its install command)
            deploy.py (calling provision command)
            backup.py (calling provision command)
        - envs/
            - dev/
                - secrets/
                    vault-pass
                    ovh-config
                inventory
                terraform.tf
            - stg/
                - secrets/
                    vault-pass
                    ovh-config
                vars.yml
                secrets.yml
                inventory
                terraform.tf
            - prd/
                - secrets/
                    vault-pass
                    aws-config
                    credentials.json
                    aws_privkey.pem
                    aws_pubkey.pem
                inventory
                terraform.tf
            - prf/
                - secrets/
                    vault-pass
                    aws-config
                    credentials.json
                    aws_privkey.pem
                    aws_pubkey.pem
                inventory
                terraform.tf
            - mgt/
                - secrets/
                    vault-pass
                    ovh-config
                inventory
                cloudformation.json
            - lcl/ (it is in ansible/local/roles/local/dev_setup)
                inventory
        - ansible/
            - files/
            - roles/
                - services/
                - common/ (common roles used by services)
                - local/ (roles executed only on local computer)
                - vendor/
            - plays/ (service plays)
            - vars/ (global vars)
            ansible.cfg
        - puppet/
        - chef/
        - saltstack/
        - .gitignore
        - .editorconfig
        - dev-config.yml (development workspace config - excluded from git)
        - manage.py
    - .kitchen.yml (for vagrant testing)
    - setup.py
- create abstract classes in lib/:
    - provisioner (ansible/puppet/chef/saltstack)
    - infrastructure manager (terraform/cloudformation/local)
    - vm manager (vagrant/docker)
    - infrastructure provider (aws/ovh/azure/local)
    - environment
    - local config file (with secret)
    - service (with git)
    - store (remote or local by using infra provider)
    - cloud store
    - environment store
    - image builder (packer/local-aws-builder)
- commands in `cloud-starter-kit` program
    - cloud init (creates config in current directory for cloud from template)
    - cloud start --config=<config-path but optional> (creates initial repo)
- commands available in cloud repo
    - setup (install, configure and update roles)
        - install (install deps - provisioner/infra manager/infra provider/)
        - configure (prompt for all configs and automatically configure)
        - update-roles (update all vendor dependencies like roles)
        - development-setup (setup workspaces, local dns etc.)
    - infra (--environment)
        - create (starts automatically)
        - destroy
        - start
        - stop
    - provision (--tag, --service, --environment)
    - build (--service, --build-type, --push-local, --push-remote)
    - save ()
    - test (--service, --type=<integration|unit|acceptance|behavioural>)
- commands available in workspace/<service-name> dir
    - same as with cloud repo, but with --service flag already filled


- create mkitdevelopment-company:
    - mkitdevelopment service (using wagtail cms)
    - hello-world service (simple server using language package)
        - python
        - ruby
        - scala
        - go
        - clojure
        - nodejs
        - PL-SQL
        - Erlang
        - haskel
        - Perl
        - php
        - java
        - c
        - c++
        - c#
        - lua
        - bash
        - assembley
        - matlab
        - Visual Basic .NET
        - pascal
        - Rust
        - ASP.net
    - frameworks service (hello world page served by framework)
        - use one from each language https://en.wikipedia.org/wiki/Comparison_of_web_frameworks
        - or this https://github.com/showcases/web-application-frameworks
    - software service (requiring multiple services)
        - hadoop
        - HBase
        - spark
        - hive
        - cassandra
        - jenkins
        - gocd
        - solr
        - elk
        - RabbitMQ
        - openstack
        - sentry
        - Kubernetes
        - Kafka
        - Oozie
        - ZooKeeper
        - Tomcat
        - Datadog
        - WordPress
        - Neo4j
        - graphana
        - gitlab enterprise
    - helipoland service (using django-starter-kit)

INSTALLATION:
1. Clone project.
2. Edit config.
3. Run python startproject.py

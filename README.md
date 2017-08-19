# Cloud Starter Kit

Cloud Starter Kit project aims to provide basic organisation structure for design, development and maintenance of complex cloud infrastructures. It provides many server and infrastructure stacks configurations ready out of the box.

## Feautres

Structure supports following features.

### Providers

* multiple providers
* multiple regions per provider
* multiple envs per region
* different IaC tooling, including custom

### Secrets

All secret files kept in one directory. All provider secrets are kept inside `lib/local_settings.py` file.

### Provisioners

* multiple provisioners
* each env can have different provisioner
* full configuration stack from users up to application configuration, deployment and backups
* global inventory of currently deployed resources

### Command line interface

By default there is neat command line interface built in Python.

```
    - infra (--environment)
        - create
        - destroy
        - start
        - stop
    - provision (--tag, --service, --environment)
    - build (--service, --build-type, --push-local, --push-remote)
    - pull ()
    - test (--service, --type=<integration|unit|acceptance|behavioural>)
```

### Development

It is assumed that developers will use current repo to setup local environment on working machine and use infrastructure commands in order to build images for specific services or even provision them if permissions were granted. Thanks to this developers can focus on particular scope of tools they will need to work with, instead of everything cloud provides.

Hybrid environment for local development is provided out of the box using Docker, Vagrant and Docker within Vagrant. All images are built using provisioning tools, not Dockerfiles or Vagrantfiles. This ensures that any changes to provisioning configuration files will be easy to apply in local Docker or Vagrant environments.


### Available stacks

* foundation network based on region or environment
    * bastion
    * vpc
    * openvpn
    * nat
    * private subnet
    * public subnet

### Amazon Web Services stacks

- [ ] compute stack
    * ec2
    * ecs with ecr
    * lambda
- [ ] big data stack
    * emr
    * elasticsearch service
    * kinesis
    * cloudsearch
    * data pipeline
- [ ] storage stack
    * rds
    * s3
    * efs
    * storage gateway
    * glacier
- [ ] dns stack
    * route53
    * vps
- [ ] messenging stack
    * sqs
    * ses
    * sns
- [ ] managemnt stack
    * cloudwatch
    * cloudformation
    * opsworks
- [ ] security stack
    * waf
    * shield

# Self configured software stacks
- [ ] services
    * django webapp
    * flask webapp
    * mysql database
    * postgresql database
    * haproxy
    * redis
    * solr search
    * elasticsearch search
    * sphinx search
    * RabbitMQ
    * Tomcat
    * Neo4j database
    * MongoDB database
    * hello-world service (simple server using language package)
        - python
        - ruby
        - scala
        - go
        - clojure
        - javascript
        - Erlang
        - haskel
        - Perl
        - php
        - java
        - c
        - c++
        - c#
        - lua
        - Visual Basic .NET
        - pascal
        - Rust
        - ASP.net
    * codecata python exercices service
- [ ] management stack
    * jenkins
    * gocd
    * elk
    * openstack
    * sentry
    * kubernetes
    * zookeeper
    * datadog
    * graphana
    * gitlab enterprise
    * kafka
- [ ] big data stack
    * hadoop
    * HBase
    * Spark
    * Hive
    * Cassandra
    * Oozie

# Cloud Starter Kit

This project is in active development.


The goal of this project is to provide an easy way to start your own feature rich cloud with as little overhead as possible. Some of the desired objectives of this project are following.

* quickly compose your tech stack for desired, user testable, production ready features
* fast configuration using component/container based approach
* always latest stable version of everything
* best coding standards
* easily create and allow to change infrastructure
* vendor agnostic
* user testable example for each component of tech stack
* cost effective production resource provider
* secure workflow ready to use by larger teams
* development, staging and production environments with just a few commands
* make it interesting


## Cloud web service solutions

* isomorphic mvc app on client and server side
* HTML/CSS framework of your choice
* designed for screens of all sizes


**Server**

* restful API
* oauth2 server implementation
* search of your choice
* isomorphic MVC app thanks to client framework of your choice
* queuing infrastructure
* email server
* message queuing
* test first setup

**Development workflow**

* continuous integration with code reviews, test coverage checks and linting
* production error reporting
* debugging & optimization tools
* A/B testing
* automation system of your choice

**High scalability**

* load balancing
* relational database clustering and sharding
* NoSQL solutions

## Cloud architecture

Cloud architecture consists containers and components. Containers are built from components and can be distributed in whatever way is necessary - all depends on configuration. Titles are chosen using following naming convention: `role>-<role type>-<technology name>`, each part lowercase and with no dots or dashes. Of course after choosing technologies for the project you can rename those in order to make more project specific, but this convention is useful for quick adoption purposes - you know technology in the stack does, how it does and what is it's name.

**Resource providers**

- [x] local - Vagrant with VirtualBox
- [ ] Kimsufi
- [ ] Amazon Web Services

**Production container tools**

- [ ] Docker

**Software Managers**

- [x] Ansible
- [ ] Puppet
- [ ] Chef
- [ ] Salt

**Task Managers**

- [ ] npm
- [ ] fabric

**Client (browser)**

- [ ] css: Semantic UI, Bootstrap
- [ ] mvc: React + libs, Angular, Backbone, Ember

**Client & Web Server**

- [ ] isomorphic-mvc: React + libs

**Proxy**

- [ ] proxy-loadbalancer: HAProxy
- [ ] proxy-server: nGINX
- [ ] proxy-cache: Varnish

**Web**

- [ ] web-api: Django + Django Rest Framework
- [ ] web-app: ExpressJS, uWSGI, Gunicorn

**Storage**

- [ ] storage-sql: PostgreSQL
- [ ] storage-nosql: Redis, Memchached, MongoDB
- [ ] storage-graph: Neo4j
- [ ] storage-bigdata: Cassandra, BigTable
- [ ] storage-search: Elasticsearch, Solr
- [ ] storage-message-broker: RabbitMQ

**Processing**

- [ ] proc-queue-manager: Celery
- [ ] proc-bigdata: Hadoop, HBase, Hive

**Monitoring**

- [ ] analytics: New Relic Server
- [ ] error-log: Sentry Server
- [ ] log-monitor: Garylog2

**Management**

- [ ] service-manager: Supervisor
- [ ] virtualization: Vagrant + VirtualBox
- [ ] continuous-integration: Jenkins, Phabricator

**Development**

- [ ] static-bundler: Webpack

**Extra**

- [ ] mail: Postfix

**Business**:

- [ ] business-analytics: Google Analytics


## Dependency tree between components

To allow one command build and deploy for testing example features components needs to autoconfigure themselves depending on other chosen components and how they are grouped.. This requires dependency tree - enable use of one component in application requires every of it's dependencies bindings reconfiguration to it. It's a tricky thing to do and major contribution of this project is solving this problem - simply structural solution to easily spawn feature rich cloud ready to test by users.


===========================================

**Development & Devops**

* Vagrant - create local deployment environments
* Ansible - provisioning and deployment tool written in Python

**Backend**

* nginx - reverse proxy server
* Express - web application server rendering client site isomorphically
* Gunicorn - API server
* Django and Django Rest Framework - backend framework for API

**Backend development**

* Fabric - Python task and deployment automation tool
* djagno-debug-toolbar - API debug tools

**Frontend**

* ReactJS - client view framework
* Semantic-UI - customizable HTML/CSS framework
* semantic-react - semantic-ui components rewritten in react
* react-redux - client model library
* react-router - routing library for react
* react-router-redux - storing route history in redux
* redux-form - keeping form state in redux store
* lru-memoize to speed up form validation
* react-helmet to manage title and meta tag information on both server and client
* react-addons-test-utils - test utilities for React

**Frontend development**

* Babel - JavaScript compiler
* Grunt - JavaScript task automation tool
* Webpack - JavaScript and CSS module builder
* webpack-dev-server & webpack-bundle-tracker - tools for hot page reload
* redux-dev-tools - redux inspector and time travel
* ESlint - JavaScript code linter
* mocha - unit testing
* jsdom - JavaScript implementation of the WHATWG DOM and HTML standards
* sinon - mocking for unit tests
* enzyme - test utilities by Airbnb

## Installation

1. Ubuntu 14.04 LTS with 16GM of ram is current system requirement.
2. Make sure you have NodeJS and npm installed.
3. Clone and cd to this repo.
4. Run `sudo npm run setup-kit` which installs base requirements for cloud-starter-kit and provisioner.
6. Rename `cloud_config.json.template` to `cloud_config.json` and edit your cloud starter kit configuration.
7. Run `npm run configure` which modifies cloud-starter-kit files accordingly to configuration file you edited.
8. Setup remote repo with providers like gitlab.com and push changes.

### Local development

When it comes to more sophisticated or even simple clouds we don't recommend installing all requirements on your system. It's better to use effective virtualization techniques in order to completely separate your home PC from work, hence we are using virtualization techniques. If you want to install cloud locally just do it manually.

1. Run `npm run build_cloud dev` to build your development infrastructure on your local machine (if it doesn't apply you can easily change default `cloud_dev_resources.json` to provide external vendor).
2. Run `npm run deploy dev` to deploy your cloud on virtual machine set up on your local.

### Stage environment

1. Rename `cloud_stage_resources.json.template` to `cloud_stage_resources.json` and define your staging resources.
2. Run `npm run build_cloud stage` to build your staging infrastructure.
3. Run `npm run deploy stage` to deploy your cloud.

### Production environment

1. Rename `cloud_prod_resources.json.` to `cloud_prod_resources.json` and define your production resources.
2. Run `npm run build_cloud prod` to build your staging infrastructure.
3. Run `npm run deploy prod` to deploy your cloud.

NPM act here just as normal script runner. You can use fabric to do the same thing or write it in your own favorite tool.

## Contributing

When something breaks or doesn't run as intended please create new issue.

Before submitting pull request please follow guide on how to [contribute](CONTRIBUTING.md).

## Thank you

I'm looking at many starter kits during development of this project and many chunks were implemented here. Here is a list you might want to look at and use if you don't like this implementation.t and use if you don't like this implementation.
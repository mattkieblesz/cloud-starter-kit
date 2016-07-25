# Cloud Starter Kit

The goal of this project is to provide full stack for robust web application development and deployment yet allow to make tech stack changes very easy.

Another intention is to make it interesting, easy to play with and learn. This is desired project features which will be implemented as times goes by.

**General**

* always latest stable versions of everything
* easily customizable tech stack
* plug and play
* optimized for high traffic
* cost effective cloud production provider
* secure workflow ready to use by larger teams
* you don't need to spend a buck to test simulated production and development environments

**Client**

* MVC on client side
* HTML/CSS framework of your choice
* designed for screens of all sizes
* test first setup

**Server**

* restful API
* oauth2 server implementation
* search of your choice
* isomorphic MVC thanks to client framework of your choice
* queuing infrastructure
* email service
* robust caching
* test first setup

**Development workflow**

* development, staging and production environments with just a few commands
* continuous integration with code reviews, test coverage checks and linting
* production error reporting
* using gitflow
* debugging & optimization tools
* A/B testing
* automation system of your choice

**High scalability**

* load balancing
* relational database clustering and sharding
* NoSql solutions

## Current tech stack

**Development & Devops**

* Vagrant - create local deployment environments
* Ansible - provisioning and deployment tool written in Python
<!-- * Jenkins - continuous integration tool -->

**Backend**

* nginx - reverse proxy server
* Express - web application server rendering client site isomorphically
* Gunicorn - API server
* Django and Django Rest Framework - backend framework for API

**Backend development**

* Fabric - Python task and deployment automation tool
* djagno-debug-toolbar - debug API

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
3. Clone this repo.
4. Edit `secure_config` file.
5. Run `sudo npm run build`.
6. Run `npm install`.
7. Run `npm configure`.

## Local development

## Production environment

## Contributing

When something breaks or doesn't run as intended please create new issue.

Before submitting pull request please follow guide on how to [contribute](CONTRIBUTING.md).

## Thank you

I'm looking at many starter kits during development of this project and many chunks were implemented here. Here is a list you might want to look at and use if you don't like this implementation.
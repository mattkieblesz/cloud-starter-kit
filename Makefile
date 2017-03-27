.PHONY: all test build clean configure


#########
# LOCAL #
#########
install:  # setup devops toolset on current machine
	./scripts/install.sh

update-roles:  # update ansible vendor roles
	./scripts/update_roles.sh

configure:  # configure credentials
	./scripts/configure.sh

dev_setup:  # creates and runs local environment machines
	ANSIBLE_CONFIG=conf/ansible.cfg ansible-playbook plays/dev_setup.yml

setup: install update-roles configure dev_setup


##############
# MANAGEMENT #
##############
create:  # mgt tool to create infrastructure as code
	./scripts/manage.sh create --env=$(ENV) --play=$(PLAY) --image-type=$(IMAGE_TYPE) --store=$(STORE) --version=$(VERSION)

run:  # mgt tool to run already created infrastructure
	./scripts/manage.sh run --env=$(ENV) --play=$(PLAY) --image-type=$(IMAGE_TYPE) --store=$(STORE) --version=$(VERSION)

halt:  # mgt tool to stop running infrastructure
	./scripts/manage.sh halt --env=$(ENV) --play=$(PLAY) --image-type=$(IMAGE_TYPE) --store=$(STORE) --version=$(VERSION)

destroy:  # mgt tool to destroy infrastructure as code
	./scripts/manage.sh destroy --env=$(ENV) --play=$(PLAY) --image-type=$(IMAGE_TYPE) --store=$(STORE) --version=$(VERSION)

deploy:  # mgt tool to deploy code using prebuild image/running provision command
	./scripts/manage.sh deploy --env=$(ENV) --play=$(PLAY) --image-type=$(IMAGE_TYPE) --store=$(STORE) --version=$(VERSION)

provision:  # mgt tool to provision to already created infrastructure
	./scripts/manage.sh provision --env=$(ENV) --play=$(PLAY) --image-type=$(IMAGE_TYPE) --store=$(STORE) --version=$(VERSION)

build:  # mgt tool to build images
	./scripts/manage.sh build --env=$(ENV) --play=$(PLAY) --image-type=$(IMAGE_TYPE) --store=$(STORE) --version=$(VERSION)

test:  # mgt tool to run test suite
	./scripts/manage.sh test --env=$(ENV) --play=$(PLAY) --image-type=$(IMAGE_TYPE) --store=$(STORE) --version=$(VERSION)

backup:  # mgt tool to backup data
	./scripts/manage.sh backup --env=$(ENV) --play=$(PLAY) --image-type=$(IMAGE_TYPE) --store=$(STORE) --version=$(VERSION)

.PHONY: all test build clean configure


#########
# LOCAL #
#########
setup:  # setup devops toolset on current machine
	./scripts/local/setup.sh

configure: update-roles  # configure credentials
	./scripts/local/configure.sh

update-roles:  # update ansible vendor roles
	./scripts/local/update_roles.sh

create-service:  # creates new role
	./scripts/local/create_service.sh

local_setup:  # creates and runs local environment machines
	./scripts/local/local_setup.sh

##############
# MANAGEMENT #
##############
build:  # mgt tool to build images
	./scripts/management/build_image.sh --play=$(PLAY) --type=$(TYPE) --store=$(STORE) --version=$(VERSION)

test:  # mgt tool to run test suite
	echo "--> pass"

create:  # mgt tool to create infrastructure as code
	./scripts/management/create.sh --play=$(PLAY) --type=$(TYPE) --store=$(STORE) --version=$(VERSION)

destroy:  # mgt tool to destroy infrastructure as code
	echo "--> pass"

provision:  # mgt tool to provision to already created infrastructure
	echo "--> pass"

backup:  # mgt tool to backup data
	echo "--> pass"

provision-tag:  # mgt tool to provision specific task to already created infrastructure like collectstatic in remote, deploy code, migrate ...
	echo "--> pass"

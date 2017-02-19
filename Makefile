.PHONY: all test build clean configure

# configure credentials
configure:
	./scripts/local/configure.sh

# setup devops toolset on current machine
setup:
	./scripts/local/setup.sh

# update ansible vendor roles
update-roles:
	./scripts/local/update_roles.sh

# creates new role
create-service:
	./scripts/local/create_service.sh

# mgt tool to build images
build:
	./scripts/management/build_image.sh --play=$(PLAY) --type=$(TYPE) --store=$(STORE) --version=$(VERSION)

# mgt tool to run test suite
test:
	echo "--> pass"

# mgt tool to create infrastructure as code
create:
	echo "--> pass"

# mgt tool to destroy infrastructure as code
destroy:
	echo "--> pass"

# mgt tool to provision to already created infrastructure
provision:
	echo "--> pass"

# mgt tool to backup data
backup:
	echo "--> pass"

# mgt tool to provision specific task to already created infrastructure like collectstatic in remote, deploy code, migrate ...
provision-tag:
	echo "--> pass"

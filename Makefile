.PHONY: all test build clean configure

# configure credentials
configure:
	./scripts/configure.sh

# setup devops toolset on current machine
setup:
	./scripts/setup.sh

# update ansible vendor roles
update-roles:
	./scripts/update_roles.sh

# creates new role
create-role:
	./scripts/create_role.sh

# creates new env
create-env:
	./scripts/create_env.sh

# mgt tool to build images
build:
	./scripts/build_image.sh --play=$(PLAY) --type=$(TYPE) --store=$(STORE) --version=$(VERSION)

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

# mgt tool to provision specific task to already created infrastructure like collectstatic in remote, deploy code, migrate ...
provision-tag:
	echo "--> pass"

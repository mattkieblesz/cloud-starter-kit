.PHONY: all test run build clean configure


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
	ANSIBLE_CONFIG=conf/ansible.cfg ansible-playbook envs/local/dev_setup.yml

setup: install update-roles configure dev_setup


##############
# MANAGEMENT #
##############
create:  # create infrastructure as code
	./scripts/manage.sh create --service=$(SERVICE) --env=$(ENV)

destroy:  # destroy infrastructure as code
	./scripts/manage.sh destroy --service=$(SERVICE) --env=$(ENV)

run:  # run already created infrastructure
	./scripts/manage.sh run --service=$(SERVICE) --env=$(ENV)

halt:  # stop running infrastructure
	./scripts/manage.sh halt --service=$(SERVICE) --env=$(ENV)

provision:  # provision to already created infrastructure
	./scripts/manage.sh provision --service=$(SERVICE) --env=$(ENV)

deploy:  # deploy code using prebuild image/running provision command
	./scripts/manage.sh deploy --service=$(SERVICE) --env=$(ENV)

backup:  # backup data
	./scripts/manage.sh backup --service=$(SERVICE) --env=$(ENV)

build:  # build images
	./scripts/manage.sh build --service=$(SERVICE) --build-type=$(BUILD_TYPE)

test:  # run test suite
	echo "Test"

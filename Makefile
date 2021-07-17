OS=$(shell uname -s)

all: install-packages no-packages

no-packages: create-dotfiles create-acfiles enable-ssh

install-packages:
	./scripts/install_packages.sh

create-dotfiles:
	./scripts/create_dotfiles.sh

create-acfiles:
	./scripts/create_acfiles.sh

enable-ssh:
	./scripts/enable_ssh.sh


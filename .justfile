## Beginning of Setup
site := env_var_or_default('SITE', 'nexus')
editor := env_var_or_default('EDITOR', 'code --wait')

export ANSIBLE_HOST_KEY_CHECKING := 'false'
export SITE := site

UID := `id -u`
GUID := `id -g`

prereqs_exists := path_exists('.prereqs')

## End of Setup

# Default lists all recipes
default:
  just --list

# Checks for existence of .prereqs, if not found installs requirements.
prereqs: vault-password
	@if ! {{prereqs_exists}} = 'true'; then \
		ansible-galaxy install -r prereqs/requirements.yml; \
		pip install -r prereqs/requirements.txt; \
		touch .prereqs; \
	fi

# Checks for existence of .vault-password file, creates if not found.
vault-password:
	@`if ! test -f .vault-password; then touch .vault-password-test;	fi`

# Fixes ssh permissions on .ssh directory.
fix-ssh-perms:
	sudo chown -R {{UID}}:{{GUID}} ~/.ssh
	chmod 600 ~/.ssh/*
	chmod 700 ~/.ssh

# Displays sorted environment variables
show-env:
	@env | sort

# Decrypts the ansible vault for the current site.
decrypt: vault-password
	@ansible-vault decrypt --vault-password-file .vault-password sites/{{SITE}}/vault.yml

# Encrypts the ansible vault for the current site.
encrypt: vault-password
	@ansible-vault encrypt --vault-password-file .vault-password sites/{{SITE}}/vault.yml

# Brings up in an editor the current site's ansible vault.
edit-vault: vault-password
	@EDITOR='{{editor}}' ansible-vault edit --vault-password-file .vault-password sites/{{SITE}}/vault.yml

inventory: vault-password 
	ansible-playbook -i sites/{{SITE}}/inventory ./books/update-known-hosts.yml --vault-password-file .vault-password

# Runs a playbook
# Example usage: 																						just update-servers
run-book PLAYBOOK: prereqs
	ansible-playbook -i sites/{{SITE}}/inventory ./books/{{PLAYBOOK}}.yml --vault-password-file .vault-password

# Example usage to limit hosts run against: 								just update-servers svc-core
# Example usage to limit usage to more than a single host:  just update-servers svc-core:svc-mgmt
run-book-targeted PLAYBOOK HOSTS='': prereqs
	ansible-playbook -i sites/{{SITE}}/inventory ./books/{{PLAYBOOK}}.yml --extra-vars "ansible_override_hosts={{HOSTS}}" --vault-password-file .vault-password

role ROLENAME HOSTS='': prereqs
	ansible {{HOSTS}} --inventory-file sites/{{SITE}}/inventory  --playbook-dir books/ --module-name include_role --args name={{ROLENAME}}

#  List all hosts for the site.
list-hosts:
  ansible  all -i sites/{{SITE}}/inventory --list-hosts

# List all inventory for the site.
list-inventory:
	ansible-inventory -i sites/{{SITE}}/inventory --list -y
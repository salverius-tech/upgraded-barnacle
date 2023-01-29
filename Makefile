decrypt:
	ansible-vault decrypt --vault-password-file .vault-password group_vars/all.yml

encrypt:
	ansible-vault encrypt --vault-password-file .vault-password group_vars/all.yml

reqs:
	ansible-galaxy install -r requirements.yml

facts:
	ansible all -m gather_facts --vault-password-file .vault-password

hosts:
	ansible all --list-hosts

inv:
	ansible-inventory --list -y --vault-password-file .vault-password 

server-deploy-proxmox:
	ansible-playbook site.yml -b --vault-password-file .vault-password

update-servers:
	ansible-playbook ./playbooks/update_servers.yml -b --vault-password-file .vault-password

check-syntax:
	ansible-playbook site.yml -b --vault-password-file .vault-password --syntax-check

reset:
	ansible-playbook reset.yml -b --vault-password-file .vault-password
	
prepare-localhost:
	ansible-playbook ./playbooks/prepare-localhost.yml -b --vault-password-file .vault-password

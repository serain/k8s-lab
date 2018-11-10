SHELL = /bin/sh

.DEFAULT_GOAL:=build

TERRAFORM_DIR = tf/environment
ANSIBLE_DIR = as
TERRAFORM_STATE = -state=$(TERRAFORM_DIR)/terraform.tfstate
TERRAFORM_VARS = -var-file=$(TERRAFORM_DIR)/env.tfvars
TERRAFORM_VARS += -var-file=$(TERRAFORM_DIR)/secrets.tfvars

BUILDS:=build destroy terraform ansible

build: terraform ansible output

terraform:
	terraform init $(TERRAFORM_DIR)
	terraform apply $(TERRAFORM_STATE) $(TERRAFORM_VARS) -auto-approve $(TERRAFORM_DIR)
	terraform output $(TERRAFORM_STATE) ansible_hosts > $(ANSIBLE_DIR)/hosts
	terraform output $(TERRAFORM_STATE) ssh_config > $(ANSIBLE_DIR)/ssh_config

ansible:
	cd $(ANSIBLE_DIR); ansible-playbook main.yml

output:
	$(eval ENDPOINT := `terraform output $$(TERRAFORM_STATE) ansible_hosts | grep k8s_public_ip | cut -d "=" -f 2`)
	
	@printf "\n"
	@printf "=%.0s" {1..80}
	@printf "\n\nThe Kubernetes endpoint is: https://${ENDPOINT}:6443/"
	@printf "\n\nCA cert is in: $(ANSIBLE_DIR)/certs/ca/ca.pem"
	@printf "\n\nAdmin user cert and key are in: $(ANSIBLE_DIR)/certs/admin/admin(-key).pem"
	@printf "\n\nkubectl has been configured for the cluster"
	@printf "\n\nSSH:"
	@printf "\n  ssh -F $(ANSIBLE_DIR)/ssh_config jumpbox"
	@printf "\n  ssh -F $(ANSIBLE_DIR)/ssh_config k8s-controller-vm-0"
	@printf "\n  ssh -F $(ANSIBLE_DIR)/ssh_config k8s-worker-vm-0\n\n"
	@printf "=%.0s" {1..80}

destroy:
	terraform destroy $(TERRAFORM_STATE) $(TERRAFORM_VARS) -force $(TERRAFORM_DIR)

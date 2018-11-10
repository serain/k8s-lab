provider "azurerm" {
  subscription_id                  = "${var.subscription_id}"
  client_id                        = "${var.client_id}"
  client_secret                    = "${var.client_secret}"
  tenant_id                        = "${var.tenant_id}"
}

/*
  Azure variables
*/

variable "subscription_id"         {}
variable "client_id"               {}
variable "client_secret"           {}
variable "tenant_id"               {}

/*
  General project varibles
*/

variable project {}
variable loc {}
variable vm_user {}
variable vm_ssh_key {}

/*
  Jumpbox variables
*/

variable jumpbox_cidr {}
variable jumpbox_vm_size {}

/*
  Controller variables
*/

variable k8s_controller_cidr {}
variable k8s_controller_vm_count {}
variable k8s_controller_vm_size {}

/*
  Worker variables
*/

variable k8s_worker_cidr {}
variable k8s_worker_vm_count {}
variable k8s_worker_vm_size {}
variable k8s_worker_cidr_prefix {}
variable pod_cidr_prefix {}
